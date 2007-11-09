From: Andi Kleen <ak@suse.de>
Subject: Re: Some interesting observations when trying to optimize vmstat handling
Date: Fri, 9 Nov 2007 16:56:26 +0100
References: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com> <200711090007.43424.ak@suse.de> <4733A7A5.9000900@goop.org>
In-Reply-To: <4733A7A5.9000900@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711091656.26908.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

On Friday 09 November 2007 01:19, Jeremy Fitzhardinge wrote:
> Andi Kleen wrote:
> > The only problem is that there might be some code who relies on
> > restore_flags() restoring other flags that IF, but at least for
> > interrupts and local_irq_save/restore it should be fine to change.
>
> I don't think so.  We don't bother to save/restore the other flags in
> Xen paravirt and it doesn't seem to cause a problem.  The semantics
> really are specific to the state of the interrupt flag.

Yes i checked the code and only case I found is actually save_flags, not 
restore_flags

(and that particular case is even unnecessary) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
