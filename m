Date: Thu, 10 Jan 2008 11:06:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
In-Reply-To: <47861D3C.6070709@qumranet.com>
Message-ID: <Pine.LNX.4.64.0801101105210.20353@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
 <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
 <47860512.3040607@qumranet.com> <20080110131612.GA1933@sgi.com>
 <47861D3C.6070709@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008, Avi Kivity wrote:

> So this is yet another instance of hardware that has a tlb that needs to be
> kept in sync with the page tables, yes?

Correct. 

> Excellent, the more users the patch has, the easier it will be to justify it.

We'd like to make sure though that we can sleep when the hooks have been 
called. We may have to sent a message to kick remote ptes out when local 
pte changes happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
