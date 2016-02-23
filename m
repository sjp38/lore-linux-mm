Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id A55776B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:34:53 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id j125so1364235oih.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:34:53 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id c80si99680oig.118.2016.02.23.15.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 15:34:53 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id jq7so1791281obb.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:34:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
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
Date: Tue, 23 Feb 2016 15:34:52 -0800
Message-ID: <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 3:28 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
>> The crux of the problem, in my opinion, is that we're asking for an "I
>> know what I'm doing" flag, and I expect that's an impossible statement
>> for a filesystem to trust generically.
>
> The file system already trusts that.  If an application doesn't use
> fsync properly, guess what, it will break.  This line of reasoning
> doesn't make any sense to me.

No, I'm worried about the case where an app specifies MAP_PMEM_AWARE
uses fsync correctly, and fails to flush cpu cache.

>> If you can get MAP_PMEM_AWARE in, great, but I'm more and more of the
>> opinion that the "I know what I'm doing" interface should be something
>> separate from today's trusted filesystems.
>
> Just so I understand you, MAP_PMEM_AWARE isn't the "I know what I'm
> doing" interface, right?

It is the "I know what I'm doing" interface, MAP_PMEM_AWARE asserts "I
know when to flush the cpu relative to an fsync()".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
