Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 521488E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:56:44 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id c46-v6so4258332otd.12
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:56:44 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n24-v6si1468217otf.209.2018.09.14.09.56.43
        for <linux-mm@kvack.org>;
        Fri, 14 Sep 2018 09:56:43 -0700 (PDT)
Date: Fri, 14 Sep 2018 17:57:00 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC][PATCH 06/11] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20180914165700.GJ6236@arm.com>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.190579217@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913092812.190579217@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 11:21:16AM +0200, Peter Zijlstra wrote:
> Needed for ia64 -- alternatively we drop the entire hook.

s/hook/architecture/

/me runs away for the weekend

Will
