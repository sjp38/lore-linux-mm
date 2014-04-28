Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id A06A76B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:13:21 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id e16so6468662qcx.6
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 02:13:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id a1si7450339qar.28.2014.04.28.02.06.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Apr 2014 02:07:26 -0700 (PDT)
Date: Mon, 28 Apr 2014 11:06:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V3 1/2] mm: move FAULT_AROUND_ORDER to arch/
Message-ID: <20140428090649.GD27561@twins.programming.kicks-ass.net>
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1398675690-16186-2-git-send-email-maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398675690-16186-2-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, mingo@kernel.org, dave.hansen@intel.com

On Mon, Apr 28, 2014 at 02:31:29PM +0530, Madhavan Srinivasan wrote:
> +unsigned int fault_around_order = CONFIG_FAULT_AROUND_ORDER;

__read_mostly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
