Date: Wed, 7 May 2008 06:30:05 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
In-Reply-To: <b6a2187b0805062140i2546a1a8pc3fa65227a9873ab@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0805070625200.3983@blonde.site>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
 <20080506124946.GA2146@elte.hu>  <Pine.LNX.4.64.0805061435510.32567@blonde.site>
  <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
 <b6a2187b0805062140i2546a1a8pc3fa65227a9873ab@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 May 2008, Jeff Chua wrote:
> 
> Thanks for the patch. It's in Linus's git now and I just booted 2 Dell

Thanks for reporting and reporting back: from your contentment ...

> 2950 and both are no showing the errors.
                      ^ 
... I'll assume the missing letter is "t" rather than "w" ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
