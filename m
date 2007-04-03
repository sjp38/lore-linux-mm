Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
References: <1175571885.12230.473.camel@localhost.localdomain>
From: Andi Kleen <andi@firstfloor.org>
Date: 03 Apr 2007 11:57:33 +0200
In-Reply-To: <1175571885.12230.473.camel@localhost.localdomain>
Message-ID: <p73lkh9zsoi.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

Rusty Russell <rusty@rustcorp.com.au> writes:
> 2) The wrapper code in xfs might no longer be needed.
> 3) The placing in the x86-64 "hot function list" for seems a little
>    unlikely.  Clearly, Andi was testing if anyone was paying attention.

That came from Arjan. The list is likely quite out of date now
because it hasn't been refreshed for some time. Perhaps should
just remove it again -- was never sure it was worth it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
