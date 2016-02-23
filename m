Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 18FBF6B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:07:10 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so110937687pac.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:07:10 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id e68si46366153pfj.170.2016.02.23.02.07.09
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 02:07:09 -0800 (PST)
From: "Rudoff, Andy" <andy.rudoff@intel.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Date: Tue, 23 Feb 2016 10:07:07 +0000
Message-ID: <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>,<20160223095225.GB32294@infradead.org>
In-Reply-To: <20160223095225.GB32294@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


> [Hi Andy - care to properly line break after ~75 character, that makes
> ready the message a lot easier, thanks!]

My bad.=20

>> The instructions give you very fine-grain flushing control, but the
>> downside is that the app must track what it changes at that fine
>> granularity.  Both models work, but there's a trade-off.
>=20
> No, the cache flush model simply does not work without a lot of hard
> work to enable it first.

It's working well enough to pass tests that simulate crashes and
various workload tests for the apps involved. And I agree there
has been a lot of hard work behind it. I guess I'm not sure why you're
saying it is impossible or not working.

Let's take an example: an app uses fallocate() to create a DAX file,
mmap() to map it, msync() to flush changes. The app follows POSIX
meaning it doesn't expect file metadata to be flushed magically, etc.
The app is tested carefully and it works correctly.  Now the msync()
call used to flush stores is replaced by flushing instructions.
What's broken?

Thanks,

-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
