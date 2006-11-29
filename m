Received: by ug-out-1314.google.com with SMTP id s2so1501592uge
        for <linux-mm@kvack.org>; Tue, 28 Nov 2006 23:08:28 -0800 (PST)
Message-ID: <84144f020611282308x748c451fn6887e477b38e525@mail.gmail.com>
Date: Wed, 29 Nov 2006 09:08:28 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <Pine.LNX.4.64.0611281629250.11531@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
	 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
	 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0611281109150.9370@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0611282118140.1597@sbz-30.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0611281123400.9465@schroedinger.engr.sgi.com>
	 <84144f020611281132p5f3f042dq36728c78521efb57@mail.gmail.com>
	 <Pine.LNX.4.64.0611281629250.11531@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On 11/29/06, Christoph Lameter <clameter@sgi.com> wrote:
> Patch on top of the other to remove the #ifdefs. Also add some annotation
> on the other ifdefs.

Thanks! For both of them:

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
