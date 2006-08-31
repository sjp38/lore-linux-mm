MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17654.11889.933070.539839@cargo.ozlabs.ibm.com>
Date: Thu, 31 Aug 2006 10:33:53 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC][PATCH 0/9] generic PAGE_SIZE infrastructure (v4)
In-Reply-To: <20060830221604.E7320C0F@localhost.localdomain>
References: <20060830221604.E7320C0F@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Hansen writes:

> Why am I doing this?  The OpenVZ beancounter patch hooks into the
> alloc_thread_info() path, but only in two architectures.  It is silly
> to patch each and every architecture when they all just do the same
> thing.  This is the first step to have a single place in which to
> do alloc_thread_info().  Oh, and this series removes about 300 lines
> of code.

... at the price of making the Kconfig help text more generic and
therefore possibly confusing on some platforms.

I really don't see much value in doing all this.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
