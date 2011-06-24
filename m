Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D289B900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 06:24:41 -0400 (EDT)
Message-ID: <4E0465D8.3080005@draigBrady.com>
Date: Fri, 24 Jun 2011 11:24:24 +0100
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com> <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com>
In-Reply-To: <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Lutomirski <luto@mit.edu>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>

On 24/06/11 10:27, Minchan Kim wrote:
> Hi Andrew,
> 
> Sorry but right now I don't have a time to dive into this.
> But it seems to be similar to the problem Mel is looking at.
> Cced him.
> 
> Even, PA!draig Brady seem to have a reproducible scenario.
> I will look when I have a time.
> I hope I will be back sooner or later.

My reproducer is (I've 3GB RAM, 1.5G swap):
  dd bs=1M count=3000 if=/dev/zero of=spin.test

To stop it spinning I just have to uncache the data,
the handiest way being:
  rm spin.test

To confirm, the top of the profile I posted is:
  i915_gem_object_bind_to_gtt
    shrink_slab

cheers,
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
