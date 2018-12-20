Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8A078E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:47:52 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so1610890otk.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:47:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 66sor2966515oid.172.2018.12.20.08.47.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 08:47:51 -0800 (PST)
MIME-Version: 1.0
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817000548.32038-8-jglisse@redhat.com>
 <CAA9_cmeag7n4yeiP6pYZSz80KyxqfwbsXJCWvyNE4PSaxCKA3A@mail.gmail.com> <20181220161538.GA3963@redhat.com>
In-Reply-To: <20181220161538.GA3963@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Dec 2018 08:47:39 -0800
Message-ID: <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
Subject: Re: [HMM-v25 07/19] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v5
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Dec 20, 2018 at 8:15 AM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > Rather than try to figure out how to forward declare pmd_t, how about
> > just move dev_page_fault_t out of the generic dev_pagemap and into the
> > HMM specific container structure? This should be straightfoward on top
> > of the recent refactor.
>
> Fine with me.

I was hoping you would reply with a patch. I'll take a look...
