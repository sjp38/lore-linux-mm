Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A87E46B000C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 02:06:14 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v205-v6so23679573oie.20
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 23:06:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t80-v6sor9814983oij.32.2018.07.08.23.06.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Jul 2018 23:06:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2581eec7-ad1e-578b-d0cd-7076a4f88776@linux.ibm.com>
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
 <20180706082911.13405-2-aneesh.kumar@linux.ibm.com> <CAPcyv4gjrsswcakSog7jxT+agH7NrBEvwxe9jT0ycU3RZV5sWA@mail.gmail.com>
 <CAOSf1CFuxga8BAbnvPdZvutgpAxmzgjiqxzHFuVTVLOkMwKO+A@mail.gmail.com>
 <CAPcyv4ihixEN9LV6TMqax3Qa2huiPnR-kFyhtO0H51GvGu2C2Q@mail.gmail.com> <2581eec7-ad1e-578b-d0cd-7076a4f88776@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 8 Jul 2018 23:06:12 -0700
Message-ID: <CAPcyv4hbPTYkvzOjM7zYXgZ_7NnW4UJ0sUxP-fbCx4mjHDy1FA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Oliver <oohall@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Jul 8, 2018 at 10:17 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
> On 07/07/2018 11:06 PM, Dan Williams wrote:
[..]
> What we need is the ability to run with fsdax on hypervisor other than KVM.

That sounds like a production use case? How can it be actual
persistent memory if the kernel is picking the physical address
backing the range?
