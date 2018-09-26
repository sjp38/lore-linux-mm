Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE0458E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:48:00 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e17-v6so14023517otk.10
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:48:00 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e20-v6si552777oib.82.2018.09.26.05.47.59
        for <linux-mm@kvack.org>;
        Wed, 26 Sep 2018 05:47:59 -0700 (PDT)
Date: Wed, 26 Sep 2018 13:47:53 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 00/18] my generic mmu_gather patches
Message-ID: <20180926124752.GC2979@brain-police>
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926113623.863696043@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, fengguang.wu@intel.com

Hi Peter,

On Wed, Sep 26, 2018 at 01:36:23PM +0200, Peter Zijlstra wrote:
> Here is my current stash of generic mmu_gather patches that goes on top of Will's
> tlb patches:

FWIW, patches 1,2,15,16,17 and 18 look fine to me, so:

Acked-by: Will Deacon <will.deacon@arm.com>

for those.

I'll leave some minor comments on a few of the others.

Will
