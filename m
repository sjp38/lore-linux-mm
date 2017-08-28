Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2770B6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 18:35:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v22so2648453pfk.4
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 15:35:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 97si1100791ple.533.2017.08.28.15.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 15:35:13 -0700 (PDT)
Date: Mon, 28 Aug 2017 15:35:11 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170828223511.GM28715@tassilo.jf.intel.com>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <20170828093727.5wldedputadanssh@hirez.programming.kicks-ass.net>
 <1503954877.4850.19.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503954877.4850.19.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

> That makes me extremely nervous... there could be all sort of
> assumptions esp. in arch code about the fact that we never populate the
> tree without the mm sem.
> 
> We'd have to audit archs closely. Things like the page walk cache
> flushing on power etc...

Yes the whole thing is quite risky. Probably will need some
kind of per architecture opt-in scheme?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
