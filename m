Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1232B6B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:26:30 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2256863pad.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:26:29 -0800 (PST)
Date: Fri, 16 Nov 2012 11:26:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] x86: convert update_mmu_cache() and update_mmu_cache_pmd()
 to functions
In-Reply-To: <1353059717-9850-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211161122070.2788@chino.kir.corp.google.com>
References: <1353059717-9850-1-git-send-email-kirill.shutemov@linux.intel.com> <1353059717-9850-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Joe Perches <joe@perches.com>, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri, 16 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Converting macros to functions unhide type problems before changes will
> be integrated and trigger problems on other architectures.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

[routing to x86 maintainers]

Acked-by: David Rientjes <rientjes@google.com>

Do you want to fix arch/s390/include/asm/pgtable.h in the same way in a 
separate patch and send it to Martin Schwidefsky <schwidefsky@de.ibm.com> 
and Heiko Carstens <heiko.carstens@de.ibm.com>?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
