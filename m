From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/PATCH] slab: free pages in a batch in drain_freelist
Date: Thu, 22 Feb 2007 13:57:23 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0702221354380.21962@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702221437400.14523@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751964AbXBVV50@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0702221437400.14523@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wli@holomorphy.com
List-Id: linux-mm.kvack.org

On Thu, 22 Feb 2007, Pekka J Enberg wrote:

> As suggested by William, free the actual pages in a batch so that we
> don't keep pounding on l3->list_lock.

This means holding the l3->list_lock for a prolonged time period. The 
existing code was done this way in order to make sure that the interrupt 
holdoffs are minimal.

There is no pounding. The cacheline with the list_lock is typically held 
until the draining is complete. While we drain the freelist we need to be 
able to respond to interrupts.
