Date: Thu, 31 Aug 2006 10:39:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/9] ia64 generic PAGE_SIZE
In-Reply-To: <1157045910.31295.23.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608311039260.12416@schroedinger.engr.sgi.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
 <20060830221607.1DB81421@localhost.localdomain>
 <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
 <1157045910.31295.23.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Aug 2006, Dave Hansen wrote:

> > #define KERNEL_STACK_SIZE_ORDER (max(0, 15 - PAGE_SHIFT)) 
> 
> My next series will be to clean up stack size handling.  Do you mind if
> it waits until then?

I am not in a hurry on this one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
