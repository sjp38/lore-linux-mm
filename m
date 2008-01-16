Date: Wed, 16 Jan 2008 10:08:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
In-Reply-To: <478DB4B3.2000505@qumranet.com>
Message-ID: <Pine.LNX.4.64.0801161008010.9061@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
 <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
 <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
 <47891A5C.8060907@qumranet.com> <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>
 <478C62F8.2070702@qumranet.com> <Pine.LNX.4.64.0801150938260.9893@schroedinger.engr.sgi.com>
 <478CF30F.1010100@qumranet.com> <Pine.LNX.4.64.0801150956040.10089@schroedinger.engr.sgi.com>
 <478CF609.3090304@qumranet.com> <Pine.LNX.4.64.0801151011380.10265@schroedinger.engr.sgi.com>
 <478DB4B3.2000505@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008, Avi Kivity wrote:

> Yes, that was poorly phrased.  The page and its page struct may
be reallocated
> for other purposes.

Its better to say "reused". Otherwise one may think that an allocation of 
page structs is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
