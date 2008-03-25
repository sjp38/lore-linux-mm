Subject: Re: [RFC 5/8] x86_64: Add UV specific header for MMR definitions
References: <20080324182116.GA28285@sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 25 Mar 2008 11:06:37 +0100
In-Reply-To: <20080324182116.GA28285@sgi.com>
Message-ID: <87iqzbi0cy.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jack Steiner <steiner@sgi.com> writes:

> 
> 	Signed-off-by: Jack Steiner <steiner@sgi.com>

Not sure why you indent that? Normally it is not. 
Some tools get confused by it I think.

> ---
>  include/asm-x86/uv_mmrs.h |  373 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 373 insertions(+)
> 
> Index: linux/include/asm-x86/uv_mmrs.h

I personally would consider it cleaner to put these into a asm-x86/uv/ 
sub directory

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
