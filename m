Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCE48E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:57:43 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id z6so2439802qtj.21
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:57:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t82si1134564qkl.141.2018.12.20.08.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:57:42 -0800 (PST)
Date: Thu, 20 Dec 2018 11:57:38 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 07/19] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v5
Message-ID: <20181220165738.GE3963@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-8-jglisse@redhat.com>
 <CAA9_cmeag7n4yeiP6pYZSz80KyxqfwbsXJCWvyNE4PSaxCKA3A@mail.gmail.com>
 <20181220161538.GA3963@redhat.com>
 <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Dec 20, 2018 at 08:47:39AM -0800, Dan Williams wrote:
> On Thu, Dec 20, 2018 at 8:15 AM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > Rather than try to figure out how to forward declare pmd_t, how about
> > > just move dev_page_fault_t out of the generic dev_pagemap and into the
> > > HMM specific container structure? This should be straightfoward on top
> > > of the recent refactor.
> >
> > Fine with me.
> 
> I was hoping you would reply with a patch. I'll take a look...

Bit busy right now but i can do that after new years :)

Cheers,
J�r�me
