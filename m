Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8F218E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:53:24 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id u40-v6so31920505otc.0
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:53:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z54-v6si2683003oti.293.2018.09.26.05.53.24
        for <linux-mm@kvack.org>;
        Wed, 26 Sep 2018 05:53:24 -0700 (PDT)
Date: Wed, 26 Sep 2018 13:53:18 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 06/18] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20180926125318.GF2979@brain-police>
References: <20180926113623.863696043@infradead.org>
 <20180926114800.822722731@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926114800.822722731@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

On Wed, Sep 26, 2018 at 01:36:29PM +0200, Peter Zijlstra wrote:
> Needed for ia64 -- alternatively we drop the entire hook.

Ack for dropping the hook.

Will
