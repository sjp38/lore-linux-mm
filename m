Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 2E07F6B0075
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 08:05:05 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so4427obq.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 05:05:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206144534.23d26318.akpm@linux-foundation.org>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
	<20121206144534.23d26318.akpm@linux-foundation.org>
Date: Fri, 7 Dec 2012 22:05:04 +0900
Message-ID: <CAAmzW4OUivQy+KUuDMhL7Dkgdb2yGAxjUC-R5a5+RGViMJJ-fA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

Hello, Andrew.

2012/12/7 Andrew Morton <akpm@linux-foundation.org>:
> On Fri,  7 Dec 2012 01:09:27 +0900
> Joonsoo Kim <js1304@gmail.com> wrote:
>
>> This patchset remove vm_struct list management after initializing vmalloc.
>> Adding and removing an entry to vmlist is linear time complexity, so
>> it is inefficient. If we maintain this list, overall time complexity of
>> adding and removing area to vmalloc space is O(N), although we use
>> rbtree for finding vacant place and it's time complexity is just O(logN).
>>
>> And vmlist and vmlist_lock is used many places of outside of vmalloc.c.
>> It is preferable that we hide this raw data structure and provide
>> well-defined function for supporting them, because it makes that they
>> cannot mistake when manipulating theses structure and it makes us easily
>> maintain vmalloc layer.
>>
>> I'm not sure that "7/8: makes vmlist only for kexec" is fine.
>> Because it is related to userspace program.
>> As far as I know, makedumpfile use kexec's output information and it only
>> need first address of vmalloc layer. So my implementation reflect this
>> fact, but I'm not sure. And now, I don't fully test this patchset.
>> Basic operation work well, but I don't test kexec. So I send this
>> patchset with 'RFC'.
>>
>> Please let me know what I am missing.
>>
>> This series based on v3.7-rc7 and on top of submitted patchset for ARM.
>> 'introduce static_vm for ARM-specific static mapped area'
>> https://lkml.org/lkml/2012/11/27/356
>> But, running properly on x86 without ARM patchset.
>
> This all looks rather nice, but not mergeable into anything at this
> stage in the release cycle.
>
> What are the implications of "on top of submitted patchset for ARM"?
> Does it depens on the ARM patches in any way, or it it independently
> mergeable and testable?
>

Yes. It depends on ARM patches.
There is a code to manipulate a vmlist in ARM.
So without applying ARM patches, this patchset makes compile error for ARM.
But, build for x86 works fine with this patchset :)

In ARM patches, a method used for removing vmlist related code is same
as 1/8 of this patchset.
But, it includes some optimization for ARM, so I sent it separately.
If it can't be accepted, I can rework ARM patches like as 1/8 of this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
