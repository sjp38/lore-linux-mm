Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E56D6B01F1
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:43:18 -0400 (EDT)
Date: Tue, 30 Mar 2010 11:43:00 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch v2] slab: add memory hotplug support
In-Reply-To: <84144f021003300201x563c72vb41cc9de359cc7d0@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003301141190.24717@router.home>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>  <20100226155755.GE16335@basil.fritz.box>  <alpine.DEB.2.00.1002261123520.7719@router.home>  <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>  <20100305062002.GV8653@laptop>  <alpine.DEB.2.00.1003081502400.30456@chino.kir.corp.google.com>  <20100309134633.GM8653@laptop>  <alpine.DEB.2.00.1003271849260.7249@chino.kir.corp.google.com>
  <alpine.DEB.2.00.1003271940190.8399@chino.kir.corp.google.com> <84144f021003300201x563c72vb41cc9de359cc7d0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Pekka Enberg wrote:

> Nick, Christoph, lets make a a deal: you ACK, I merge. How does that
> sound to you?

I looked through the patch before and slabwise this seems to beok but I am
still not very sure how this interacts with the node and cpu bootstrap.
You can have the ack with this caveat.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
