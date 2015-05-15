Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB9CA6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 10:23:49 -0400 (EDT)
Received: by wghe15 with SMTP id e15so1000793wgh.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 07:23:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id fy6si3986925wib.38.2015.05.15.07.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 07:23:48 -0700 (PDT)
Date: Fri, 15 May 2015 16:23:31 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v1 00/15] decouple pagefault_disable() from
 preempt_disable()
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1505151620390.4225@nanos>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

On Mon, 11 May 2015, David Hildenbrand wrote:
> 
> Any feedback very welcome!

Thanks for picking that up (again)!

We've pulled the lot into RT and unsurprisingly it works like a charm :)

Works on !RT as well. 

Reviewed-and-tested-by: Thomas Gleixner <tglx@linutronix.de>

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
