Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1153C6B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 01:43:56 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id at20so2043247iec.6
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 22:43:55 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id rs7si4103859igb.13.2014.09.12.22.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 22:43:55 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id h15so1635118igd.10
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 22:43:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140912170616.cb4c832a09cc2b221453ad32@linux-foundation.org>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164127.29066.99498.stgit@zurg>
	<20140912170404.f14663cc823691cab36bf793@linux-foundation.org>
	<20140912170616.cb4c832a09cc2b221453ad32@linux-foundation.org>
Date: Sat, 13 Sep 2014 09:43:54 +0400
Message-ID: <CALYGNiM-ArE2+M+xjSbDjLyNc_Rr0C=6TKBKPi4bEwxFfeU_tA@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] mm/balloon_compaction: general cleanup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Sep 13, 2014 at 4:06 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 12 Sep 2014 17:04:04 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Sat, 30 Aug 2014 20:41:27 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>
>> > * move special branch for balloon migraion into migrate_pages
>> > * remove special mapping for balloon and its flag AS_BALLOON_MAP
>> > * embed struct balloon_dev_info into struct virtio_balloon
>> > * cleanup balloon_page_dequeue, kill balloon_page_free
>>
>> Not sure what's going on here - your include/linux/balloon_compaction.h
>> seems significantly different from mine.
>
> OK, I worked it out.
>
>> I think I'll just drop this patch - it's quite inconvenient to have a
>> large "general cleanup" coming after a stack of significant functional
>> changes.  It makes review, debug, fix, merge and reversion harder.
>> Let's worry about it later.
>
> But I'm still thinking we should defer this one?

It seems in this case massive cleanup before fixies leads to much bigger mess.
I've separated fixes specially for merging into stable kernels.

The rest patches mostly rewrites this code using new approatch.
I don't know how to make it more reviewable, it's easier to write a
new version from the scratch.
Probably rework should be untied form fixes and sent as separate patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
