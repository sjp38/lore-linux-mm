Date: Fri, 14 Jan 2005 08:59:55 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050113215955.GB6309@krispykreme.ozlabs.ibm.com>
References: <20050113210624.GG20738@wotan.suse.de> <20050113212912.93033.qmail@web14308.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050113212912.93033.qmail@web14308.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
Hi Kanoj,

> Okay, I think I see what you and wli meant. But the assumption that
> spin_lock will order memory operations is still correct, right?

A spin_lock will only guarantee loads and stores inside the locked
region dont leak outside. Loads and stores before the spin_lock may leak
into the critical region. Likewise loads and stores after the
spin_unlock may leak into the critical region.

Also they dont guarantee ordering for cache inhibited loads and stores.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
