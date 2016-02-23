Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id DE6A56B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:43:43 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id x1so806005qkc.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:43:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c8si253481qkb.35.2016.02.23.15.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 15:43:43 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
	<56CA1CE7.6050309@plexistor.com>
	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
	<20160221223157.GC25832@dastard>
	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
	<20160222174426.GA30110@infradead.org>
	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
	<20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<56CCD54C.3010600@plexistor.com>
	<CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
	<x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
Date: Tue, 23 Feb 2016 18:43:40 -0500
In-Reply-To: <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
	(Dan Williams's message of "Tue, 23 Feb 2016 15:34:52 -0800")
Message-ID: <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> On Tue, Feb 23, 2016 at 3:28 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
>>> The crux of the problem, in my opinion, is that we're asking for an "I
>>> know what I'm doing" flag, and I expect that's an impossible statement
>>> for a filesystem to trust generically.
>>
>> The file system already trusts that.  If an application doesn't use
>> fsync properly, guess what, it will break.  This line of reasoning
>> doesn't make any sense to me.
>
> No, I'm worried about the case where an app specifies MAP_PMEM_AWARE
> uses fsync correctly, and fails to flush cpu cache.

I don't think the kernel needs to put training wheels on applications.

>>> If you can get MAP_PMEM_AWARE in, great, but I'm more and more of the
>>> opinion that the "I know what I'm doing" interface should be something
>>> separate from today's trusted filesystems.
>>
>> Just so I understand you, MAP_PMEM_AWARE isn't the "I know what I'm
>> doing" interface, right?
>
> It is the "I know what I'm doing" interface, MAP_PMEM_AWARE asserts "I
> know when to flush the cpu relative to an fsync()".

I see.  So I think your argument is that new file systems (such as Nova)
can have whacky new semantics, but existing file systems should provide
the more conservative semantics that they have provided since the dawn
of time (even if we add a new mmap flag to control the behavior).

I don't agree with that.  :)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
