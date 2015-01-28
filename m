Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id BC20D6B006C
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:13:47 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id v8so16211146qal.7
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:13:47 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com. [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id v7si6056551qas.110.2015.01.28.06.13.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 06:13:47 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id x12so16226364qac.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:13:46 -0800 (PST)
Message-ID: <54C8EE99.80107@gmail.com>
Date: Wed, 28 Jan 2015 09:13:45 -0500
From: John Moser <john.r.moser@gmail.com>
MIME-Version: 1.0
Subject: Re: OOM at low page cache?
References: <54C2C89C.8080002@gmail.com> <54C77086.7090505@suse.cz> <20150128062609.GA4706@blaptop> <54C8D7B0.7030803@redhat.com>
In-Reply-To: <54C8D7B0.7030803@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------080800070009030305080906"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

This is a multi-part message in MIME format.
--------------080800070009030305080906
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 01/28/2015 07:36 AM, Rik van Riel wrote:
> On 01/28/2015 01:26 AM, Minchan Kim wrote:
> > Hello,
>
> > On Tue, Jan 27, 2015 at 12:03:34PM +0100, Vlastimil Babka wrote:
> >> CC linux-mm in case somebody has a good answer but missed this in
> >> lkml traffic
> >>
> >> On 01/23/2015 11:18 PM, John Moser wrote:
> >>> Why is there no tunable to OOM at low page cache?
>
> > AFAIR, there were several trial although there wasn't acceptable at
> > that time. One thing I can remember is min_filelist_kbytes. FYI,
> > http://lwn.net/Articles/412313/
>
> The Android low memory killer does exactly what you want, and
> for very much the same reasons.
>
> See drivers/staging/android/lowmemorykiller.c
>

Haven't seen that; it's been a long time since I bothered myself with
kernel code, so I'm out-of-touch.

Wow lots of good responses coming quick.
> However, in the mainline kernel I think it does make sense to
> apply something like the patch that Minchan cooked up with, to OOM
> if freeing all the page cache could not bring us back up to the high
> watermark, across all the memory zones.
>
>



--------------080800070009030305080906
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    On 01/28/2015 07:36 AM, Rik van Riel wrote:<br>
    <blockquote type="cite">On 01/28/2015 01:26 AM, Minchan Kim wrote:<br>
      &gt; Hello,<br>
      <br>
      &gt; On Tue, Jan 27, 2015 at 12:03:34PM +0100, Vlastimil Babka
      wrote:<br>
      &gt;&gt; CC linux-mm in case somebody has a good answer but missed
      this in<br>
      &gt;&gt; lkml traffic<br>
      &gt;&gt;<br>
      &gt;&gt; On 01/23/2015 11:18 PM, John Moser wrote:<br>
      &gt;&gt;&gt; Why is there no tunable to OOM at low page cache?<br>
      <br>
      &gt; AFAIR, there were several trial although there wasn't
      acceptable at<br>
      &gt; that time. One thing I can remember is min_filelist_kbytes.
      FYI,<br>
      &gt; <a class="moz-txt-link-freetext" href="http://lwn.net/Articles/412313/">http://lwn.net/Articles/412313/</a><br>
      <br>
      The Android low memory killer does exactly what you want, and<br>
      for very much the same reasons.<br>
      <br>
      See drivers/staging/android/lowmemorykiller.c<br>
      <br>
    </blockquote>
    <br>
    Haven't seen that; it's been a long time since I bothered myself
    with kernel code, so I'm out-of-touch.<br>
    <br>
    Wow lots of good responses coming quick.<br>
    <blockquote type="cite">However, in the mainline kernel I think it
      does make sense to<br>
      apply something like the patch that Minchan cooked up with, to OOM<br>
      if freeing all the page cache could not bring us back up to the
      high<br>
      watermark, across all the memory zones.<br>
      <br>
    </blockquote>
    <span style="white-space: pre;">&gt;</span><br>
    <br>
    <br>
  </body>
</html>

--------------080800070009030305080906--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
