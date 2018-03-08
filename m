Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC0486B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 13:23:23 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id h61-v6so3164475pld.3
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 10:23:23 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id s61-v6si15043750plb.381.2018.03.08.10.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 10:23:22 -0800 (PST)
Subject: Re: [PATCH 1/2] x86/mm: Give each mm a unique ID
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
 <3351ba53a3b570ba08f2a0f5a59d01b7d80a8955.1520026221.git.tim.c.chen@linux.intel.com>
 <20180307173036.GJ7097@kroah.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <9b0d1195-23bd-5bf9-0dd8-b2ca29165bbb@linux.intel.com>
Date: Thu, 8 Mar 2018 10:23:21 -0800
MIME-Version: 1.0
In-Reply-To: <20180307173036.GJ7097@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/07/2018 09:30 AM, Greg Kroah-Hartman wrote:
> On Fri, Mar 02, 2018 at 01:32:09PM -0800, Tim Chen wrote:
>> From: Andy Lutomirski <luto@kernel.org>
>> commit: f39681ed0f48498b80455095376f11535feea332
>>
>> This adds a new variable to mmu_context_t: ctx_id.
>> ctx_id uniquely identifies the mm_struct and will never be reused.
>>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
>> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Arjan van de Ven <arjan@linux.intel.com>
>> Cc: Borislav Petkov <bp@alien8.de>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: linux-mm@kvack.org
>> Link: http://lkml.kernel.org/r/413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org
>> Signed-off-by: Ingo Molnar <mingo@kernel.org>
>> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
>> ---
>>  arch/x86/include/asm/mmu.h         | 15 +++++++++++++--
>>  arch/x86/include/asm/mmu_context.h |  5 +++++
>>  arch/x86/mm/tlb.c                  |  2 ++
>>  3 files changed, 20 insertions(+), 2 deletions(-)
>>
> 
> Does not apply to 4.4.y :(
> 
> Can you provide a working backport for that tree?
> 

Okay. Will do.  Thanks.

Tim
