Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 17A006B0253
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 20:14:00 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so1618603pfb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 17:14:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xd1si74787688pab.130.2016.01.07.17.13.59
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 17:13:59 -0800 (PST)
Subject: Re: [PATCH v4] memory-hotplug: Fix kernel warning during memory
 hotplug on ppc64
References: <568D9568.1010808@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <568F0D56.5010908@intel.com>
Date: Thu, 7 Jan 2016 17:13:58 -0800
MIME-Version: 1.0
In-Reply-To: <568D9568.1010808@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Allen <jallen@linux.vnet.ibm.com>, gregkh@linuxfoundation.org
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, akpm@linux-foundation.org, Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>Andrew Morton <akpm@linux-foundation.org>

On 01/06/2016 02:30 PM, John Allen wrote:
> On any architecture that uses memory_probe_store to reserve memory, the
> udev rule will be triggered after the first section of the block is
> reserved and will subsequently attempt to online the entire block,
> interrupting the memory reservation process and causing the warning.
> This patch modifies memory_probe_store to add a block of memory with
> a single call to add_memory as opposed to looping through and adding
> each section individually. A single call to add_memory is protected by
> the mem_hotplug mutex which will prevent the udev rule from onlining
> memory until the reservation of the entire block is complete.

Seems sane to me.  Makes the code simpler too, so win win.

Acked-by: Dave Hansen <dave.hansen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
