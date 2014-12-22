<%@ WebService Language="C#" Class="SocialMediaAggregator" %>

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Security.Cryptography;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Xml.Linq;

[WebService(Namespace = "http://www.savannahstate.edu",Description="Returns all social media posts.")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class SocialMediaAggregator : System.Web.Services.WebService 
{
    const String facebookAccount = "savannahstate";
    const String twitterAccount = "@savannahstate";
    const String instagramAccount = "savannahstate";
    String dateCreated = "";
    String url = "";
    String image = "";
    String caption = "";
    List<SocialMediaPost> posts;

    public SocialMediaAggregator()
    {
    }

    [WebMethod(CacheDuration = 3600)]
    public BloggerPost GetBloggerPost(String postId)
    {
        String bloggerFeed = "";
        bloggerFeed = GetAllBloggerFeed();

        if (!string.IsNullOrEmpty(bloggerFeed))
        {
            BloggerPosts bloggerPosts = new JavaScriptSerializer().Deserialize<BloggerPosts>(bloggerFeed);

            if (bloggerPosts.items.Count() > 0)
            {
                BloggerPost post = bloggerPosts.items.Find(p => p.id == postId);
                try
                {
                    post.DatePublished = Convert.ToDateTime(post.published);
                }
                catch (Exception ex)
                {
                    return null;
                }
                return post;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    [WebMethod(CacheDuration = 3600)]
    public List<BloggerPost> GetBloggerPosts(Int16 numberOfPosts)
    {
        String bloggerFeed = "";
        bloggerFeed = GetAllBloggerFeed();

        List<BloggerPost> posts = new List<BloggerPost>();

        if (!string.IsNullOrEmpty(bloggerFeed))
        {
            BloggerPosts bloggerPosts = new JavaScriptSerializer().Deserialize<BloggerPosts>(bloggerFeed);

            if (bloggerPosts.items.Count() > 0)
            {
                if (numberOfPosts > 0)
                {
                    posts = bloggerPosts.items.Take(numberOfPosts).ToList();
                }
                else
                {
                    posts = bloggerPosts.items;
                }
                foreach (BloggerPost post in posts)
                {
                    try
                    {
                        post.DatePublished = Convert.ToDateTime(post.published);
                    }
                    catch (Exception ex)
                    {
                        return null;
                    }
                }
                return posts;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    [WebMethod()]
    public void GetPostsRSS()
    {




        

        Context.Response.Clear();
        Context.Response.ContentType = "application/xml";
        
        

        
        
        
        
        
        
        String bloggerFeed = "";
        bloggerFeed = GetAllBloggerFeed();
        List<BloggerPost> posts = new List<BloggerPost>();

        if (!string.IsNullOrEmpty(bloggerFeed))
        {
            BloggerPosts bloggerPosts = new JavaScriptSerializer().Deserialize<BloggerPosts>(bloggerFeed);

            if (bloggerPosts.items.Count() > 0)
            {
                posts = bloggerPosts.items.Take(10).ToList();

                foreach (BloggerPost post in posts)
                {
                    try
                    {
                        post.DatePublished = Convert.ToDateTime(post.published);
                    }
                    catch (Exception ex)
                    {

                    }

                    try
                    {
                        post.content = Regex.Replace(post.content, @"(<img\/?[^>]+>)", @"", RegexOptions.IgnoreCase);
                    }
                    catch (Exception ex)
                    {

                    }
                }


                
                
                

                
                //temp = temp.Replace("<?xml version=\"1.0\" encoding=\"utf-8\" ?>","");
                //temp = temp.Replace("<string xmlns=\"http://simba.savannahstate.edu/socialstreamservice/\">", "");
                //temp = temp.Replace("</string>","");


                //return temp;
            }
            else
            {
                //return null;
            }
        }
        else
        {
            //return null;
        }
        var rss = new XElement("channel",
                from p in posts
                select new XElement("item",
                               new XElement("title", p.title),
                               new XElement("pubDate", p.DatePublished),
                               new XElement("description", p.content),
                               new XElement("link", "social-media/highlight.shtml?id=" + p.id)
                           ));

        Context.Response.Flush();
        Context.Response.Write("<rss version=\"2.0\">" +  rss.ToString() + "</rss>");
    }

    [WebMethod(CacheDuration = 3600)]
    public List<BloggerPost> QueryBloggerTags(String tag)
    {
        String bloggerFeed = "";
        bloggerFeed = GetAllBloggerFeed();

        List<BloggerPost> posts = new List<BloggerPost>();

        if (!string.IsNullOrEmpty(bloggerFeed))
        {
            BloggerPosts bloggerPosts = new JavaScriptSerializer().Deserialize<BloggerPosts>(bloggerFeed);

            if (bloggerPosts.items.Count() > 0)
            {
                
                posts = bloggerPosts.items.Where(p => p.labels.Contains(tag)).ToList();
                if (posts.Count() > 0)
                {
                    foreach (BloggerPost post in posts)
                    {
                        try
                        {
                            post.DatePublished = Convert.ToDateTime(post.published);
                        }
                        catch (Exception ex)
                        {

                        }

                        try
                        {
                            post.content = Regex.Replace(post.content, @"(<img\/?[^>]+>)", @"", RegexOptions.IgnoreCase);
                        }
                        catch (Exception ex)
                        {

                        }
                    }
                }
                return posts;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }



    [WebMethod(CacheDuration = 40)]
    public List<SocialMediaPost> GetAllSocialPostsFiltered(Int32 numberOfPosts, String mediaType, String hashTag)
    {
        posts = new List<SocialMediaPost>();
        List<SocialMediaPost> filteredPosts;
        List<SocialMediaPost> sortedPosts;
        if (mediaType == "instagram" || mediaType == "all")
        {
            GetInstagramFeed();
        }
        if (mediaType == "facebook" || mediaType == "all")
        {
            GetFacebookFeed();
        }
        if (mediaType == "twitter" || mediaType == "all")
        {
            GetTweetFeed();
        }

        if (posts.Count > 0)
        {
            if(!String.IsNullOrEmpty(hashTag)){
                filteredPosts = posts.Where(p => p.content.ToLower().Contains(hashTag.ToLower())).ToList();
            }else{
                filteredPosts = posts;
            }
            
            
            if (numberOfPosts > 0)
            {
                sortedPosts = filteredPosts.OrderByDescending(o => o.postDate).Take(numberOfPosts).ToList();
            }
            else
            {
                sortedPosts = filteredPosts.OrderByDescending(o => o.postDate).ToList();
            }

        }
        else
        {
            sortedPosts = posts;
        }



        return sortedPosts;
    }
    
    [WebMethod(CacheDuration = 40)]
    public List<SocialMediaPost> GetAllSocialPosts(Int32 numberOfPosts, String mediaType) {
        posts = new List<SocialMediaPost>();
        List<SocialMediaPost> sortedPosts;
        if(mediaType == "instagram" || mediaType == "all"){
            GetInstagramFeed();
        }
        if(mediaType == "facebook" || mediaType == "all"){
            GetFacebookFeed();
        }
        if(mediaType == "twitter" || mediaType == "all")
        {
            GetTweetFeed();
        }

        if (posts.Count > 0)
        {
            if (numberOfPosts > 0)
            {
                sortedPosts = posts.OrderByDescending(o => o.postDate).Take(numberOfPosts).ToList();
            }
            else {
                sortedPosts = posts.OrderByDescending(o => o.postDate).ToList();
            }
            
        } else {
            sortedPosts = posts;
        }
        
        

        return sortedPosts;
    }
    
    private void GetInstagramFeed()
    {
        String feed = "";
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create("https://api.instagram.com/v1/users/455868730/media/recent/?access_token=" + System.Configuration.ConfigurationManager.AppSettings["instagram_access_token"]);

        try
        {
            WebResponse response = request.GetResponse();
            using (Stream responseStream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.UTF8);
                feed = reader.ReadToEnd();
            }
        }
        catch (WebException ex)
        {
            WebResponse errorResponse = ex.Response;
            using (Stream responseStream = errorResponse.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.GetEncoding("utf-8"));
                feed = "";        
            }
        }


        if (!string.IsNullOrEmpty(feed))
        {
            InstagramPosts instagramPosts = new JavaScriptSerializer().Deserialize<InstagramPosts>(feed);
            foreach (var item in instagramPosts.data)
            {
                try
                {
                    dateCreated = item.created_time;
                }
                catch (Exception ex)
                {
                    dateCreated = "";
                }
                if (!string.IsNullOrEmpty(dateCreated))
                {
                    try
                    {
                        url = item.link;
                    }
                    catch (Exception ex)
                    {
                        url = "";
                    }
                    try
                    {
                        image = item.images.standard_resolution.url;
                    }
                    catch (Exception ex)
                    {
                        image = "";
                    }
                    try
                    {
                        caption = item.caption.text;
                    }
                    catch (Exception ex)
                    {
                        caption = "";
                    }
                    if (!string.IsNullOrEmpty(image))
                    {
                        DateTime instagramPostDate = UnixTimeStampToDateTime(item.created_time);
                        SocialMediaPost tempPost = new SocialMediaPost();
                        tempPost.postDate = instagramPostDate;
                        tempPost.type = "instagram";
                        tempPost.url = url;
                        tempPost.content = "<img src='" + image + "' /><p>" + UrlFinder(caption) + "</p>";
                        tempPost.titleLink = "<a href='http://www.instagram.com/" + instagramAccount + "' target='_blank'>" + instagramAccount + "</a>";
                        tempPost.socialLinkText = "Instagram";
                        posts.Add(tempPost);
                    }
                }
            }
        }
    }

    private void GetFacebookFeed()
    {
        String feed = "";
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create("https://graph.facebook.com/v2.2/81383047843/posts?access_token=" + System.Configuration.ConfigurationManager.AppSettings["facebook_access_token"]);
        try
        {
            WebResponse response = request.GetResponse();
            using (Stream responseStream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.UTF8);
                feed = reader.ReadToEnd();
            }
        }
        catch (WebException ex)
        {
            WebResponse errorResponse = ex.Response;
            using (Stream responseStream = errorResponse.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.GetEncoding("utf-8"));
                feed = "";
            }
        }

        if (!String.IsNullOrEmpty(feed))
        {
            FacebookPosts facebookPosts = new JavaScriptSerializer().Deserialize<FacebookPosts>(feed);
            dateCreated = "";
            url = "";
            image = "";
            caption = "";
            foreach (var item in facebookPosts.data)
            {
                try
                {
                    dateCreated = item.created_time;
                }
                catch (Exception ex)
                {
                    dateCreated = "";
                }
                if (!string.IsNullOrEmpty(dateCreated))
                {
                    try
                    {
                        if (item.id.IndexOf("_") != -1)
                        {
                            url = "https://www.facebook.com/" + item.id.Replace("_", "/posts/");
                        }
                        else
                        {
                            url = "https://www.facebook.com/" + item.id;
                        }
                    }
                    catch (Exception ex)
                    {
                        url = "";
                    }
                    try
                    {
                        image = item.picture;
                    }
                    catch (Exception ex)
                    {
                        image = "";
                    }
                    try
                    {
                        caption = item.message;
                    }
                    catch (Exception ex)
                    {
                        caption = "";
                    }

                    if (!string.IsNullOrEmpty(image))
                    {
                        char[] delimiterChars = { '&' };
                        if (item.type == "photo")
                        {
                            if (image.IndexOf("_s") != -1)
                            {
                                image = image.Replace("_s", "_o");
                            }
                            else if (!string.IsNullOrEmpty(item.object_id))
                            {
                                image = "https://graph.facebook.com/" + item.object_id + "/picture?width=9999&height=9999";
                            }
                        }
                        else
                        {
                            string[] qps = image.Split(delimiterChars);
                            foreach (string s in qps)
                            {
                                if (s.IndexOf("url=") != -1)
                                {
                                    image = HttpUtility.UrlDecode(s.Replace("url=", ""));
                                }
                                else
                                {
                                    if (s.IndexOf("src=") != -1)
                                    {
                                        image = HttpUtility.UrlDecode(s.Replace("src=", ""));
                                    }
                                }
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(image) || !string.IsNullOrEmpty(caption))
                    {
                        DateTime facebookDateCreated = Convert.ToDateTime(dateCreated);
                        SocialMediaPost tempPost = new SocialMediaPost();
                        tempPost.postDate = facebookDateCreated;
                        tempPost.type = "facebook";
                        tempPost.url = url;
                        if (image != null)
                        {
                            tempPost.content = "<img src='" + image + "' /><p>" + UrlFinder(caption) + "</p>";
                        }
                        else
                        {
                            tempPost.content = caption;
                        }

                        tempPost.content = FormatPost(tempPost.content, tempPost.type);
                        
                        tempPost.titleLink = "<a href='http://www.facebook.com/" + facebookAccount + "' target='_blank'>" + facebookAccount + "</a>";
                        tempPost.socialLinkText = "Post";
                        posts.Add(tempPost);
                    }
                }
            }
        }
    }

    private void GetTweetFeed()
    {
        String feed = "";
        string url = "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=savannahstate&screen_name=savannahstate";
        string oauthconsumerkey = System.Configuration.ConfigurationManager.AppSettings["twitter_oauthconsumerkey"];
        string oauthtoken = System.Configuration.ConfigurationManager.AppSettings["twitter_oauthtoken"];
        string oauthconsumersecret = System.Configuration.ConfigurationManager.AppSettings["twitter_oauthconsumersecret"];
        string oauthtokensecret = System.Configuration.ConfigurationManager.AppSettings["twitter_oauthtokensecret"];
        string oauthsignaturemethod = "HMAC-SHA1";
        string oauthversion = "1.0";
        string oauthnonce = Convert.ToBase64String(new ASCIIEncoding().GetBytes(DateTime.Now.Ticks.ToString()));
        TimeSpan timeSpan = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
        string oauthtimestamp = Convert.ToInt64(timeSpan.TotalSeconds).ToString();
        SortedDictionary<string, string> basestringParameters = new SortedDictionary<string, string>();
        basestringParameters.Add("user_id", "savannahstate");
        basestringParameters.Add("screen_name", "savannahstate");
        basestringParameters.Add("oauth_version", oauthversion);
        basestringParameters.Add("oauth_consumer_key", oauthconsumerkey);
        basestringParameters.Add("oauth_nonce", oauthnonce);
        basestringParameters.Add("oauth_signature_method", oauthsignaturemethod);
        basestringParameters.Add("oauth_timestamp", oauthtimestamp);
        basestringParameters.Add("oauth_token", oauthtoken);
        //Build the signature string
        string baseString = String.Empty;
        baseString += "GET" + "&";
        baseString += Uri.EscapeDataString(url.Split('?')[0]) + "&";
        foreach (KeyValuePair<string, string> entry in basestringParameters)
        {
            baseString += Uri.EscapeDataString(entry.Key + "=" + entry.Value + "&");
        }

        //Remove the trailing ambersand char last 3 chars - %26
        baseString = baseString.Substring(0, baseString.Length - 3);

        //Build the signing key
        string signingKey = Uri.EscapeDataString(oauthconsumersecret) + "&" + Uri.EscapeDataString(oauthtokensecret);

        //Sign the request
        HMACSHA1 hasher = new HMACSHA1(new ASCIIEncoding().GetBytes(signingKey));
        string oauthsignature = Convert.ToBase64String(hasher.ComputeHash(new ASCIIEncoding().GetBytes(baseString)));

        //Tell Twitter we don't do the 100 continue thing
        ServicePointManager.Expect100Continue = false;

        //authorization header
        HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(@url);
        string authorizationHeaderParams = String.Empty;
        authorizationHeaderParams += "OAuth ";
        authorizationHeaderParams += "oauth_nonce=" + "\"" + Uri.EscapeDataString(oauthnonce) + "\",";
        authorizationHeaderParams += "oauth_signature_method=" + "\"" + Uri.EscapeDataString(oauthsignaturemethod) + "\",";
        authorizationHeaderParams += "oauth_timestamp=" + "\"" + Uri.EscapeDataString(oauthtimestamp) + "\",";
        authorizationHeaderParams += "oauth_consumer_key=" + "\"" + Uri.EscapeDataString(oauthconsumerkey) + "\",";
        authorizationHeaderParams += "oauth_token=" + "\"" + Uri.EscapeDataString(oauthtoken) + "\",";
        authorizationHeaderParams += "oauth_signature=" + "\"" + Uri.EscapeDataString(oauthsignature) + "\",";
        authorizationHeaderParams += "oauth_version=" + "\"" + Uri.EscapeDataString(oauthversion) + "\"";
        webRequest.Headers.Add("Authorization", authorizationHeaderParams);

        webRequest.Method = "GET";
        webRequest.ContentType = "application/x-www-form-urlencoded";

        //Allow us a reasonable timeout in case Twitter's busy
        webRequest.Timeout = 3 * 60 * 1000;
        try
        {
            //Proxy settings
            //webRequest.Proxy = new WebProxy("enter proxy details/address");
            HttpWebResponse webResponse = webRequest.GetResponse() as HttpWebResponse;
            Stream dataStream = webResponse.GetResponseStream();
            // Open the stream using a StreamReader for easy access.
            StreamReader reader = new StreamReader(dataStream);
            // Read the content.
            feed = reader.ReadToEnd();
        }
        catch (Exception ex)
        {
            feed = "";
        }

        if (!string.IsNullOrEmpty(feed))
        {
            Tweets tweets = new JavaScriptSerializer().Deserialize<Tweets>("{\"data\":" + feed + "}");
            dateCreated = "";
            url = "";
            image = "";
            caption = "";
            foreach (var item in tweets.data)
            {
                try
                {
                    dateCreated = item.created_at;
                }
                catch (Exception ex)
                {
                    dateCreated = "";
                }
                if (!string.IsNullOrEmpty(dateCreated))
                {
                    try
                    {
                        url = "https://twitter.com/savannahstate/status/" + item.id;
                    }
                    catch (Exception ex)
                    {
                        url = "";
                    }
                    try
                    {
                        caption = item.text;
                    }
                    catch (Exception ex)
                    {
                        caption = "";
                    }
                    if (!string.IsNullOrEmpty(caption))
                    {
                        DateTime twitterDateCreated = ParseTwitterDateTime(dateCreated);
                        SocialMediaPost tempPost = new SocialMediaPost();
                        tempPost.postDate = twitterDateCreated;
                        tempPost.type = "twitter";
                        tempPost.url = url;
                        tempPost.content = "<p>" + UrlFinder(caption) + "</p>";
                        tempPost.content = FormatPost(tempPost.content, tempPost.type);
                        tempPost.titleLink = "<a href='http://www.twitter.com/" + twitterAccount + "' target='_blank'>" + twitterAccount + "</a>";
                        tempPost.socialLinkText = "Tweet";
                        posts.Add(tempPost);
                    }
                }
            }
        }
        
    }

    private String GetAllBloggerFeed()
    {
        String feed = "";
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create("https://www.googleapis.com/blogger/v3/blogs/5797214299173121016/posts?key="+System.Configuration.ConfigurationManager.AppSettings["blogger_key"]);

        try
        {
            WebResponse response = request.GetResponse();
            using (Stream responseStream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.UTF8);
                feed = reader.ReadToEnd();
                return feed;
            }
        }
        catch (WebException ex)
        {
            WebResponse errorResponse = ex.Response;
            using (Stream responseStream = errorResponse.GetResponseStream())
            {
                StreamReader reader = new StreamReader(responseStream, Encoding.GetEncoding("utf-8"));
                feed = reader.ReadToEnd();
                return feed;
            }
        }
    }
    
    public static DateTime UnixTimeStampToDateTime(string sUnixTimeStamp)
    {

        double unixTimeStamp = Convert.ToDouble(sUnixTimeStamp);

        // Unix timestamp is seconds past epoch
        System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc);
        dtDateTime = dtDateTime.AddSeconds(unixTimeStamp).ToLocalTime();
        return dtDateTime;
    }

    public static DateTime ParseTwitterDateTime(string date)
    {
        const string format = "ddd MMM dd HH:mm:ss zzzz yyyy";
        return DateTime.ParseExact(date, format, System.Globalization.CultureInfo.InvariantCulture);
    }

    public String UrlFinder(String rawText)
    {
        string output = "";
        if (!string.IsNullOrEmpty(rawText))
        {
            Regex linkParser = new Regex(@"\b((https?|ftp|file)://|(www|ftp)\.)[-A-Z0-9+&@#/%?=~_|$!:,.;\(\)]*[A-Z0-9+&@#/%=~_|$]", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            if (linkParser.Matches(rawText).Count > 0)
            {
                output = rawText;
                foreach (Match m in linkParser.Matches(rawText))
                {
                    output = output.Replace(m.Value, "<a target='_blank' href='" + m.Value + "'>" + m.Value + "</a>");
                }
                return output;
            }
            else
            {
                return rawText;
            }
        }
        else
        {
            return rawText;
        }
    }
    
    public String FormatPost(String content, String type){
        if(content!=null){
            var regex = new Regex(@"(?<=#)\w+");
            var matches = regex.Matches(content);
            String hashtagURL = "";
            
            foreach (Match m in matches)
            {
                switch (type){
                    case "twitter":
                        hashtagURL = "http://www.twitter.com/hashtag/";
                        content = content.Replace("#" + m.Value, "<a target='_blank' href='" + hashtagURL + m.Value + "'>#" + m.Value + "</a>");
                        break;
                    case "facebook":
                        hashtagURL = "http://www.facebook.com/hashtag/";
                        content = content.Replace("#" + m.Value, "<a target='_blank' href='" + hashtagURL + m.Value + "'>#" + m.Value + "</a>");
                        break;
                }
            }
        }
        return content;
    }
}



public class SocialMediaPost
{
    public String type {get; set;}
    public DateTime postDate { get; set; }
    public String url { get; set; }
    public String content { get; set; }
    public String titleLink { get; set; }
    public String socialLinkText { get; set; }
}


public class InstagramPosts
{
    public List<InstagramPost> data { get; set; }
}

public class InstagramPost
{
    public string created_time { get; set; }
    public string link { get; set; }
    public InstagramPostImageResolution images { get; set; }
    public InstagramPostCaption caption { get; set; }
}

public class InstagramPostCaption
{
    public string text { get; set; }
}

public class InstagramPostURL
{
    public string url { get; set; }
}

public class InstagramPostImageResolution
{
    public InstagramPostURL standard_resolution { get; set; }
}

public class FacebookPosts
{

    public List<FacebookPost> data { get; set; }
}

public class FacebookPost
{
    public string created_time { get; set; }
    public string id { get; set; }
    public string picture { get; set; }
    public string message { get; set; }
    public string type { get; set; }
    public string object_id { get; set; }
}

public class Tweets
{

    public List<Tweet> data { get; set; }
}

public class Tweet
{
    public string created_at { get; set; }
    public string id { get; set; }
    public string text { get; set; }
}


public class BloggerPosts
{
    public List<BloggerPost> items { get; set; }
}

public class BloggerPost
{
    public String id { get; set; }
    public String published { get; set; }
    public DateTime DatePublished { get; set; }
    public String title { get; set; }
    public String content { get; set; }
    public String[] labels { get; set; }
}
