Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6816E6B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:39:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n63-v6so6159201oig.21
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:39:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u28-v6sor14464428ote.11.2018.06.07.11.39.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 11:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180607141640.GA4518@redhat.com>
References: <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
 <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com>
 <CAPcyv4g2XQtuYGPu8HMbPj6wXqGwxiL5jDRznf5fmW4WgC2DTw@mail.gmail.com>
 <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com>
 <CAPcyv4jTty4k1xXCOWbeRjzv-KjxNH1L4oOkWW1EbJt66jF4_w@mail.gmail.com>
 <20180605184811.GC4423@redhat.com> <CAPM=9twgL_tzkPO=V2mmecSzLjKJkEsJ8A4426fO2Nuus0N_UQ@mail.gmail.com>
 <CAPcyv4gSEYdnJKd=D-_yc3M=sY0HWjYzYhh5ha-v7KA4-40dsg@mail.gmail.com>
 <20180606000822.GE4423@redhat.com> <CAPcyv4gsS4xDXahZdOggURBHS2y-oJ5tPG9vXPDdY2p6jPufxA@mail.gmail.com>
 <20180607141640.GA4518@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 7 Jun 2018 11:39:44 -0700
Message-ID: <CAPcyv4gSn6O+rWYxAfqjkY6pkGAjvTNRUeMY1Ynde3_Vw6gTUA@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Airlie <airlied@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jun 7, 2018 at 7:16 AM, Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> HMM is self contain interface but i doubt i can convince you of that.

I agree that HMM is self contained... after it completely subverts the
core-mm. It's that deep understanding and working around of core
memory management infrastructure that makes devm_memremap_pages() and
derivatives EXPORT_SYMBOL_GPL ("considered an
internal implementation issue, and not really an interface").
