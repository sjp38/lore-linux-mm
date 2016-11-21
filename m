Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAA26B04D1
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:08:36 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b123so49694460itb.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:08:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 37si12395359ioj.191.2016.11.20.21.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 21:08:35 -0800 (PST)
Date: Mon, 21 Nov 2016 00:08:30 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 07/18] mm/ZONE_DEVICE/x86: add support for
 un-addressable device memory
Message-ID: <20161121050829.GD7872@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-8-git-send-email-jglisse@redhat.com>
 <33e9c941-ac57-3dfd-2ed9-c1d058a57d8f@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <33e9c941-ac57-3dfd-2ed9-c1d058a57d8f@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Nov 21, 2016 at 01:08:56PM +1100, Balbir Singh wrote:
> 
> 
> On 19/11/16 05:18, Jerome Glisse wrote:
> > It does not need much, just skip populating kernel linear mapping
> > for range of un-addressable device memory (it is pick so that there
> > is no physical memory resource overlapping it). All the logic is in
> > share mm code.
> > 
> > Only support x86-64 as this feature doesn't make much sense with
> > constrained virtual address space of 32bits architecture.
> > 
> 
> Is there a reason this would not work on powerpc64 for example?
> Could you document the limitations -- testing/APIs/missing features?

It should be straight forward for powerpc64, i haven't done it but i
certainly can try to get access to some powerpc64 and add support for
it.

The only thing to do is to avoid creating kernel linear mapping for the
un-addressable memory (just for safety reasons we do not want any read/
write to invalid physical address).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
