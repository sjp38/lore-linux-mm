Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 121116B0032
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 02:21:00 -0400 (EDT)
Received: by mail-oa0-f67.google.com with SMTP id o17so1103983oag.10
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 23:21:00 -0700 (PDT)
Message-ID: <517B6E46.30209@gmail.com>
Date: Sat, 27 Apr 2013 14:20:54 +0800
From: Mtrr Patt <mtrr.patt@gmail.com>
MIME-Version: 1.0
Subject: Re: Better active/inactive list balancing
References: <517B6DF5.70402@gmail.com>
In-Reply-To: <517B6DF5.70402@gmail.com>
Content-Type: multipart/alternative;
 boundary="------------070705000208000807020303"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------070705000208000807020303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

cc linux-mm

On 04/27/2013 02:19 PM, Mtrr Patt wrote:
> Hi Johannes,
>
> http://lwn.net/Articles/495543/
>
> This link said that "When active pages are considered for eviction, 
> they are first moved to the inactive list and unmapped from the 
> address space of the process(es) using them. Thus, once a page moves 
> to the inactive list, any attempt to reference it will generate a page 
> fault; this "soft fault" will cause the page to be removed back to the 
> active list."
>
> Why I can't find the codes unmap during page moved from active list to 
> inactive list?
>
>
>


--------------070705000208000807020303
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">cc linux-mm<br>
      <br>
      On 04/27/2013 02:19 PM, Mtrr Patt wrote:<br>
    </div>
    <blockquote cite="mid:517B6DF5.70402@gmail.com" type="cite">
      <meta http-equiv="content-type" content="text/html;
        charset=ISO-8859-1">
      Hi Johannes,<br>
      <br>
      <meta http-equiv="content-type" content="text/html;
        charset=ISO-8859-1">
      <a moz-do-not-send="true" href="http://lwn.net/Articles/495543/">http://lwn.net/Articles/495543/</a><br>
      <br>
      This link said that "When active pages are considered for
      eviction, they are first moved to the inactive list and unmapped
      from the address space of the process(es) using them. Thus, once a
      page moves to the inactive list, any attempt to reference it will
      generate a page fault; this "soft fault" will cause the page to be
      removed back to the active list."<br>
      <br>
      Why I can't find the codes unmap during page moved from active
      list to inactive list?<br>
      &nbsp;<br>
      <br>
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------070705000208000807020303--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
