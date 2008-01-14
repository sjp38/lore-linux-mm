Date: Mon, 14 Jan 2008 11:49:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
In-Reply-To: <47891A5C.8060907@qumranet.com>
Message-ID: <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
 <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
 <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
 <47891A5C.8060907@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Sat, 12 Jan 2008, Avi Kivity wrote:

> Two kvm instances mmap() the file (from anywhere) into the guest address
> space.  That memory is shared, and will be backed by the same page structs at
> the same offset.

Duh. Impossible. Two instances of Linux cannot share page structs. So how 
are you doing this? Or is this just an idea?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
