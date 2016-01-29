Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 91D1D828E1
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:29:44 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id ba1so51459185obb.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:29:44 -0800 (PST)
Received: from rcdn-iport-3.cisco.com (rcdn-iport-3.cisco.com. [173.37.86.74])
        by mx.google.com with ESMTPS id dp7si10062610obb.40.2016.01.28.17.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 17:29:43 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56AAC085.9060509@cisco.com>
Date: Thu, 28 Jan 2016 17:29:41 -0800
MIME-Version: 1.0
In-Reply-To: <56AABA79.3030103@cisco.com>
Content-Type: multipart/alternative;
 boundary="------------050209090902070508010707"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, Rik van Riel <riel@redhat.com>

This is a multi-part message in MIME format.
--------------050209090902070508010707
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 01/28/2016 05:03 PM, Daniel Walker wrote:
> On 01/28/2016 03:58 PM, Johannes Weiner wrote:
>> On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
>>> "Currently there is no way to figure out the droppable pagecache size
>>> from the meminfo output. The MemFree size can shrink during normal
>>> system operation, when some of the memory pages get cached and is
>>> reflected in "Cached" field. Similarly for file operations some of
>>> the buffer memory gets cached and it is reflected in "Buffers" field.
>>> The kernel automatically reclaims all this cached & buffered memory,
>>> when it is needed elsewhere on the system. The only way to manually
>>> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "
>> [...]
>>
>>> The point of the whole exercise is to get a better idea of free 
>>> memory for
>>> our employer. Does it make sense to do this for computing free memory?
>> /proc/meminfo::MemAvailable was added for this purpose. See the doc
>> text in Documentation/filesystem/proc.txt.
>>
>> It's an approximation, however, because this question is not easy to
>> answer. Pages might be in various states and uses that can make them
>> unreclaimable.
>
>
> Khalid was telling me that our internal sources rejected MemAvailable 
> because it was not accurate enough. It says in the description,
> "The estimate takes into account that the system needs some page cache 
> to function well". I suspect that's part of the inaccuracy. I asked 
> Khalid to respond with more details on this.
>

Some quotes,

"
[regarding MemAvaiable]

This new metric purportedly helps usrespace assess available memory. But,
its again based on heuristic, it takes 1/2 of page cache as reclaimable..

Somewhat arbitrary choice. Maybe appropriate for desktops, where page
cache is mainly used as page cache, not as a first class store which is
the case on embedded systems. Our systems are swap less, they have little
secondary storage, they use in-memory databases/filesystems/shared memories/
etc. which are all setup on page caches).. This metric as it is implemented
in 3.14 leads to a totally mis-leading picture of available memory"

Daniel

--------------050209090902070508010707
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 01/28/2016 05:03 PM, Daniel Walker
      wrote:<br>
    </div>
    <blockquote cite="mid:56AABA79.3030103@cisco.com" type="cite">On
      01/28/2016 03:58 PM, Johannes Weiner wrote:
      <br>
      <blockquote type="cite">On Thu, Jan 28, 2016 at 03:42:53PM -0800,
        Daniel Walker wrote:
        <br>
        <blockquote type="cite">"Currently there is no way to figure out
          the droppable pagecache size
          <br>
          from the meminfo output. The MemFree size can shrink during
          normal
          <br>
          system operation, when some of the memory pages get cached and
          is
          <br>
          reflected in "Cached" field. Similarly for file operations
          some of
          <br>
          the buffer memory gets cached and it is reflected in "Buffers"
          field.
          <br>
          The kernel automatically reclaims all this cached &amp;
          buffered memory,
          <br>
          when it is needed elsewhere on the system. The only way to
          manually
          <br>
          reclaim this memory is by writing 1 to
          /proc/sys/vm/drop_caches. "
          <br>
        </blockquote>
        [...]
        <br>
        <br>
        <blockquote type="cite">The point of the whole exercise is to
          get a better idea of free memory for
          <br>
          our employer. Does it make sense to do this for computing free
          memory?
          <br>
        </blockquote>
        /proc/meminfo::MemAvailable was added for this purpose. See the
        doc
        <br>
        text in Documentation/filesystem/proc.txt.
        <br>
        <br>
        It's an approximation, however, because this question is not
        easy to
        <br>
        answer. Pages might be in various states and uses that can make
        them
        <br>
        unreclaimable.
        <br>
      </blockquote>
      <br>
      <br>
      Khalid was telling me that our internal sources rejected
      MemAvailable because it was not accurate enough. It says in the
      description,
      <br>
      "The estimate takes into account that the system needs some page
      cache to function well". I suspect that's part of the inaccuracy.
      I asked Khalid to respond with more details on this.
      <br>
      <br>
    </blockquote>
    <br>
    Some quotes,<br>
    <br>
    "<span id="OLK_SRC_BODY_SECTION"><span id="OLK_SRC_BODY_SECTION"
        style="color: rgb(0, 0, 0); font-family: Calibri, sans-serif;
        font-size: 14px; font-style: normal; font-variant: normal;
        font-weight: normal; letter-spacing: normal; line-height:
        normal; orphans: auto; text-align: start; text-indent: 0px;
        text-transform: none; white-space: normal; widows: auto;
        word-spacing: 0px; -webkit-text-stroke-width: 0px;"><span
          id="OLK_SRC_BODY_SECTION">
          <div style="font-family: Consolas; font-size: medium;">[regarding
            MemAvaiable]</div>
          <div style="font-family: Consolas; font-size: medium;"><br>
          </div>
          <div style="font-family: Consolas; font-size: medium;">This
            new metric purportedly helps usrespace assess available
            memory. But,</div>
          <div style="font-family: Consolas; font-size: medium;">its
            again based on heuristic, it takes 1/2 of page cache as
            reclaimable..</div>
          <div style="font-family: Consolas; font-size: medium;"><br>
          </div>
          <div style="font-family: Consolas; font-size: medium;">Somewhat
            arbitrary choice. Maybe appropriate for desktops, where page</div>
          <div style="font-family: Consolas; font-size: medium;">cache
            is mainly used as page cache, not as a first class store
            which is</div>
          <div style="font-family: Consolas; font-size: medium;">the
            case on embedded systems. Our systems are swap less, they
            have little</div>
          <div style="font-family: Consolas; font-size: medium;">secondary
            storage, they use in-memory databases/filesystems/shared
            memories/</div>
          <div style="font-family: Consolas; font-size: medium;">etc.
            which are all setup on page caches).. This metric as it is
            implemented</div>
          <div style="font-family: Consolas; font-size: medium;">in 3.14
            leads to a totally mis-leading picture of available memory"</div>
        </span></span></span><br>
    Daniel<br>
  </body>
</html>

--------------050209090902070508010707--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
