Message-ID: <4733A7A5.9000900@goop.org>
Date: Thu, 08 Nov 2007 16:19:49 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Some interesting observations when trying to optimize vmstat
 handling
References: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com> <200711090007.43424.ak@suse.de>
In-Reply-To: <200711090007.43424.ak@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> The only problem is that there might be some code who relies on 
> restore_flags() restoring other flags that IF, but at least for interrupts
> and local_irq_save/restore it should be fine to change.
>   

I don't think so.  We don't bother to save/restore the other flags in
Xen paravirt and it doesn't seem to cause a problem.  The semantics
really are specific to the state of the interrupt flag.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
