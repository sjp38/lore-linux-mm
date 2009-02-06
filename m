Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 158686B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 05:06:35 -0500 (EST)
Received: by gxk13 with SMTP id 13so722918gxk.14
        for <linux-mm@kvack.org>; Fri, 06 Feb 2009 02:06:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090206080354.GA6516@barrios-desktop>
References: <20090206031125.693559239@cmpxchg.org>
	 <20090206031324.004715023@cmpxchg.org>
	 <20090206080354.GA6516@barrios-desktop>
Date: Fri, 6 Feb 2009 19:06:34 +0900
Message-ID: <28c262360902060206h78c15a1dsf52b481c5cc1bc74@mail.gmail.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 6, 2009 at 5:03 PM, MinChan Kim <minchan.kim@gmail.com> wrote:
> Hi, Johannes.
> I have some questions.
> Just out of curiosity. :)
>
> On Fri, Feb 06, 2009 at 04:11:28AM +0100, Johannes Weiner wrote:
>> File cache pages are saved to disk either through normal writeback by
>> reclaim or by including them in the suspend image written to a
>> swapfile.
>>
>> Writing them either way should take the same amount of time but doing
>> normal writeback and unmap changes the fault behaviour on resume from
>> prefault to on-demand paging, smoothening out resume and giving
>
> What do you mean "unmap"?
> Why normal writeback and unmap chnages the fault behavior on resume ?

Please, Ignore poor first my question. :(
I agree with your opinion.

>> previously cached pages the chance to stay out of memory completely if
>> they are not used anymore.
>>
>> Another reason for preferring file page eviction is that the locality
>> principle is visible in fault patterns and swap might perform really
>> bad with subsequent faulting of contiguously mapped pages.
>
> Why do you think that swap might perform bad with subsequent faulting
> of contiguusly mapped page ?
> You mean normal file system is faster than swap due to readahead and
> smart block of allocation ?

But, I still can't understand this issue.
what mean "page eviction" ? Is it reclaim or swap out ?

>
> --
> Kinds Regards
> MinChan Kim
>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
