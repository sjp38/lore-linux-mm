Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3EC6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:29:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d20-v6so9927040pfn.16
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:29:16 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id g59-v6si15159946plb.381.2018.05.21.15.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:29:15 -0700 (PDT)
Subject: Re: Why do we let munmap fail?
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
 <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
Date: Mon, 21 May 2018 15:29:13 -0700
MIME-Version: 1.0
In-Reply-To: <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On 05/21/2018 03:20 PM, Daniel Colascione wrote:
>> VMAs consume kernel memory and we can't reclaim them.  That's what it
>> boils down to.
> How is it different from memfd in that respect?

I don't really know what you mean.  I know folks use memfd to figure out
how much memory pressure we are under.  I guess that would trigger when
you consume lots of memory with VMAs.

VMAs are probably the most similar to things like page tables that are
kernel memory that can't be directly reclaimed, but do get freed at
OOM-kill-time.  But, VMAs are a bit harder than page tables because
freeing a page worth of VMAs does not necessarily free an entire page.
