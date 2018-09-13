Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38A268E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 12:26:05 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m207-v6so9082511itg.5
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 09:26:05 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i16-v6si2980754jam.12.2018.09.13.09.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 09:26:04 -0700 (PDT)
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680532635.453305.11297363695024516117.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <f011859e-eab3-acea-9498-246f791922ff@deltatee.com>
Date: Thu, 13 Sep 2018 10:25:58 -0600
MIME-Version: 1.0
In-Reply-To: <153680532635.453305.11297363695024516117.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v5 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/09/18 08:22 PM, Dan Williams wrote:
> devm_memremap_pages() is a facility that can create struct page entries
> for any arbitrary range and give drivers the ability to subvert core
> aspects of page management.
> 
> Specifically the facility is tightly integrated with the kernel's memory
> hotplug functionality. It injects an altmap argument deep into the
> architecture specific vmemmap implementation to allow allocating from
> specific reserved pages, and it has Linux specific assumptions about
> page structure reference counting relative to get_user_pages() and
> get_user_pages_fast(). It was an oversight and a mistake that this was
> not marked EXPORT_SYMBOL_GPL from the outset.
> 
> Again, devm_memremap_pagex() exposes and relies upon core kernel
> internal assumptions and will continue to evolve along with 'struct
> page', memory hotplug, and support for new memory types / topologies.
> Only an in-kernel GPL-only driver is expected to keep up with this
> ongoing evolution. This interface, and functionality derived from this
> interface, is not suitable for kernel-external drivers.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Mostly to say that I agree with you and Christoph on this debate and
that the change to GPL does not affect my P2PDMA work.

Logan
