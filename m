Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A56186B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 11:41:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b2so300879364pgc.6
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 08:41:50 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0093.outbound.protection.outlook.com. [104.47.2.93])
        by mx.google.com with ESMTPS id p82si12731656pfd.99.2017.03.20.08.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Mar 2017 08:41:49 -0700 (PDT)
Subject: Re: [PATCH v4 08/13] x86, kasan: clarify kasan's dependency on
 vmemmap_populate_hugepages()
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
 <148964445079.19438.904042108424174547.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ab8e8aa0-1645-2bc3-52ab-8b071a2a135a@virtuozzo.com>
Date: Mon, 20 Mar 2017 18:43:03 +0300
MIME-Version: 1.0
In-Reply-To: <148964445079.19438.904042108424174547.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On 03/16/2017 09:07 AM, Dan Williams wrote:
> Historically kasan has not been careful about whether vmemmap_populate()
> internally allocates a section worth of memmap even if the parameters
> call for less.  For example, a request to shadow map a single page
> results in a full section (128MB) that contains that page being mapped.
> Also, kasan has not been careful to handle cases where this section
> promotion causes overlaps / overrides of previous calls to
> vmemmap_populate().
> 
> Before we teach vmemmap_populate() to support sub-section hotplug,
> arrange for kasan to explicitly avoid vmemmap_populate_basepages().
> This should be functionally equivalent to the current state since
> CONFIG_KASAN requires x86_64 (implies PSE) and it does not collide with
> sub-section hotplug support since CONFIG_KASAN disables
> CONFIG_MEMORY_HOTPLUG.
> 
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Nicolai Stange <nicstange@gmail.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
