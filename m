Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 831566B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:02:31 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id y9so15811371qgd.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 07:02:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e81si3093232qhd.76.2016.02.24.07.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 07:02:30 -0800 (PST)
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
	<x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
Date: Wed, 24 Feb 2016 10:02:26 -0500
In-Reply-To: <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
	(Dan Williams's message of "Tue, 23 Feb 2016 15:56:17 -0800")
Message-ID: <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

>> I see.  So I think your argument is that new file systems (such as Nova)
>> can have whacky new semantics, but existing file systems should provide
>> the more conservative semantics that they have provided since the dawn
>> of time (even if we add a new mmap flag to control the behavior).
>>
>> I don't agree with that.  :)
>>
>
> Fair enough.  Recall, I was pushing MAP_DAX not to long ago.  It just
> seems like a Sisyphean effort to push an mmap flag up the XFS hill and
> maybe that effort is better spent somewhere else.

Given Dave's last response to Boaz, I see what you mean, and I also
understand Dave's reasoning better, now.  FWIW, I never disagreed with
spending effort elsewhere for now.  I did think that the mmap flag was
on the horizon, though.  From Dave's comments, I think the prospects of
that are slim to none.  That's fine, at least we have a definite
direction.  Time to update all of the slide decks.  =)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
