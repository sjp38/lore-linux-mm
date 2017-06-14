Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6A76B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:18:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o62so12280178pga.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:18:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d11si846945pgt.19.2017.06.14.15.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:18:27 -0700 (PDT)
Subject: Re: [PATCH v2 00/10] PCID and improved laziness
References: <cover.1497415951.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6da4aea9-ef52-694d-9a03-285c32018326@intel.com>
Date: Wed, 14 Jun 2017 15:18:26 -0700
MIME-Version: 1.0
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
> 2. Mms that have been used recently on a given CPU might get to keep
>    their TLB entries alive across process switches with this patch
>    set.  TLB fills are pretty fast on modern CPUs, but they're even
>    faster when they don't happen.

Let's not forget that TLBs are also getting bigger.  The bigger TLBs
help ensure that they *can* survive across another process's timeslice.

Also, the cost to refill the paging structure caches is going up.  Just
think of how many cachelines you have to pull in to populate a
~1500-entry TLB, even if the CPU hid the latency of those loads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
