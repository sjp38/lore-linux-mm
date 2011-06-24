Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F418D900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 08:15:36 -0400 (EDT)
Message-ID: <4E047FD7.60004@draigBrady.com>
Date: Fri, 24 Jun 2011 13:15:19 +0100
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com> <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com> <4E0465D8.3080005@draigBrady.com>
In-Reply-To: <4E0465D8.3080005@draigBrady.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Lutomirski <luto@mit.edu>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 24/06/11 11:24, PA!draig Brady wrote:
> On 24/06/11 10:27, Minchan Kim wrote:
>> Hi Andrew,
>>
>> Sorry but right now I don't have a time to dive into this.
>> But it seems to be similar to the problem Mel is looking at.
>> Cced him.
>>
>> Even, PA!draig Brady seem to have a reproducible scenario.
>> I will look when I have a time.
>> I hope I will be back sooner or later.
> 
> My reproducer is (I've 3GB RAM, 1.5G swap):
>   dd bs=1M count=3000 if=/dev/zero of=spin.test
> 
> To stop it spinning I just have to uncache the data,
> the handiest way being:
>   rm spin.test
> 
> To confirm, the top of the profile I posted is:
>   i915_gem_object_bind_to_gtt
>     shrink_slab

BTW I just tried this patch,
but it didn't change anything.

http://marc.info/?l=linux-kernel&m=130890263124399&w=2

cheers,
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
