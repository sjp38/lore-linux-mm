Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8CD26B0003
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 09:19:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i14-v6so7714624wrq.1
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 06:19:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 17-v6si4117533wrv.412.2018.06.24.06.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 24 Jun 2018 06:19:43 -0700 (PDT)
Date: Sun, 24 Jun 2018 15:19:18 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
In-Reply-To: <20180516233207.1580-1-toshi.kani@hpe.com>
Message-ID: <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, mingo@redhat.com, hpa@zytor.com, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Wed, 16 May 2018, Toshi Kani wrote:

> This series fixes two issues in the x86 ioremap free page handlings
> for pud/pmd mappings.
> 
> Patch 01 fixes BUG_ON on x86-PAE reported by Joerg.  It disables
> the free page handling on x86-PAE.
> 
> Patch 02-03 fixes a possible issue with speculation which can cause
> stale page-directory cache.
>  - Patch 02 is from Chintan's v9 01/04 patch [1], which adds a new arg
>    'addr', with my merge change to patch 01.
>  - Patch 03 adds a TLB purge (INVLPG) to purge page-structure caches
>    that may be cached by speculation.  See the patch descriptions for
>    more detal.

Toshi, Joerg, Michal!

I'm failing to find a conclusion of this discussion. Can we finally make
some progress with that?

Can someone give me a hint what to pick up urgently please?

Thanks,

	tglx
