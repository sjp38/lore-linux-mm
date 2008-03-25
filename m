Date: Tue, 25 Mar 2008 08:45:00 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [RFC 5/8] x86_64: Add UV specific header for MMR definitions
Message-ID: <20080325134459.GA19668@sgi.com>
References: <20080324182116.GA28285@sgi.com> <87iqzbi0cy.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87iqzbi0cy.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:06:37AM +0100, Andi Kleen wrote:
> Jack Steiner <steiner@sgi.com> writes:
> 
> > 
> > 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
> Not sure why you indent that? Normally it is not. 
> Some tools get confused by it I think.

Fixed.


> 
> > ---
> >  include/asm-x86/uv_mmrs.h |  373 ++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 373 insertions(+)
> > 
> > Index: linux/include/asm-x86/uv_mmrs.h
> 
> I personally would consider it cleaner to put these into a asm-x86/uv/ 
> sub directory

Will change...


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
