Date: Wed, 29 Nov 2006 11:18:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <84144f020611282308x748c451fn6887e477b38e525@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611291117110.16189@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0611281109150.9370@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282118140.1597@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0611281123400.9465@schroedinger.engr.sgi.com>
 <84144f020611281132p5f3f042dq36728c78521efb57@mail.gmail.com>
 <Pine.LNX.4.64.0611281629250.11531@schroedinger.engr.sgi.com>
 <84144f020611282308x748c451fn6887e477b38e525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Pekka Enberg wrote:

> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

Thanks. I intend to rediff this against the upcoming mm release given the 
other changes going in right now (2.6.19-rc6-mm2?) and submit at that 
point. I hope I can carry the ack forward from the RFC to the actual 
patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
