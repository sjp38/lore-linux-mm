Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 558A16B0425
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:08:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so255394823pgd.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:08:26 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e6si8417332pgf.47.2016.11.18.06.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 06:08:24 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH v2 0/7] Speculative page faults
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
	<cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2016 06:08:24 -0800
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com> (Laurent
	Dufour's message of "Fri, 18 Nov 2016 12:08:44 +0100")
Message-ID: <871sy8284n.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> This is a port on kernel 4.8 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore.

One of the big problems with patches like this today is that it is
unclear what mmap_sem actually protects. It's a big lock covering lots
of code. Parts in the core VM, but also do VM callbacks in file systems
and drivers rely on it too?

IMHO the first step is a comprehensive audit and then writing clear
documentation on what it is supposed to protect. Then based on that such
changes can be properly evaluated.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
