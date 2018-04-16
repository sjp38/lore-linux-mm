Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 643BD6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 00:36:18 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d9-v6so641171plj.4
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 21:36:18 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u9-v6si11686871plz.10.2018.04.15.21.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 21:36:17 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-5-bhe@redhat.com>
 <5dd3942a-cf66-f749-b1c6-217b0c3c94dc@intel.com>
 <20180408082038.GB19345@localhost.localdomain>
 <7cc53287-4570-84d6-502c-c3dfbd279b78@intel.com>
 <20180415021940.GA1750@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <11c4796f-865e-9e0c-076a-f750d5da0ea7@intel.com>
Date: Sun, 15 Apr 2018 21:36:16 -0700
MIME-Version: 1.0
In-Reply-To: <20180415021940.GA1750@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 04/14/2018 07:19 PM, Baoquan He wrote:
>>> Yes, this place is the hardest to understand. The temorary arrays are
>>> allocated beforehand with the size of 'nr_present_sections'. The error
>>> paths you mentioned is caused by allocation failure of mem_map or
>>> map_map, but whatever it's error or success paths, the sections must be
>>> marked as present in memory_present(). Error or success paths happened
>>> in alloc_usemap_and_memmap(), while checking if it's erorr or success
>>> paths happened in the last for_each_present_section_nr() of
>>> sparse_init(), and clear the ms->section_mem_map if it goes along error
>>> paths. This is the key point of this new allocation way.
>> I think you owe some commenting because this is so hard to understand.
> I can arrange and write a code comment above sparse_init() according to
> this patch's git log, do you think it's OK?
> 
> Honestly, it took me several days to write code, while I spent more
> than one week to write the patch log. Writing patch log is really a
> headache to me.

I often find the same: writing the code is the easy part.  Explaining
why it is right is the hard part.
