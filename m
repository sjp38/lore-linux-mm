Date: Tue, 25 Jul 2006 13:25:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <44C518D6.3090606@redhat.com>
Message-ID: <Pine.LNX.4.64.0607251324140.30939@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com>
 <Pine.LNX.4.64.0607241109190.25634@schroedinger.engr.sgi.com>
 <44C518D6.3090606@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jul 2006, Rik van Riel wrote:

> > I think there may be a way with less changes to the way the VM functions to
> > get there:
> 
> That approach probably has way too many state changes going
> between the guest OS and the hypervisor...

An increment of a VM counter causes a state change in the hypervisor?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
