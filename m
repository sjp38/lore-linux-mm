Subject: Re: [patch 0/6] Strong Access Ordering page attributes for POWER7
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20080618223254.966080905@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 09:39:52 +1000
Message-Id: <1215128392.7960.7.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: shaggy@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-18 at 17:32 -0500, shaggy@linux.vnet.ibm.com wrote:
> Andrew,
> 
> The first patch in this series hits architecture independent code, but the
> rest is contained in the powerpc subtree.  Could you pick up the first
> patch into -mm?  I can send the rest of them through the powerpc git tree.
> The first patch and the rest of the set are independent and can be merged
> in either order.

 ../..

I was wondering... how do we inform userspace that this is available ?
Same question with adding the endian bit on 4xx which I plan to do using
your infrastructure...

We haven't defined a user-visible feature bit (and besides, we're really
getting short on these...). This is becoming a bit of concern btw (the
running out of bits). Maybe we should start defining an AT_HWCAP2 for
powerpc and get libc updated to pick it up ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
