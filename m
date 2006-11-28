Received: by ug-out-1314.google.com with SMTP id s2so1376665uge
        for <linux-mm@kvack.org>; Tue, 28 Nov 2006 11:24:51 -0800 (PST)
Message-ID: <84144f020611281124k85785caydbe45a20c4905f48@mail.gmail.com>
Date: Tue, 28 Nov 2006 21:24:50 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <Pine.LNX.4.64.0611282118140.1597@sbz-30.cs.Helsinki.FI>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, Christoph Lameter wrote:
> > There could be other header files used by user space where we would want
> > to switch from slab.h to kmalloc.h in the future.

On 11/28/06, Pekka J Enberg <penberg@cs.helsinki.fi> wrote:
> I think not. An userspace header that depends on <linux/kmalloc.h> would
> be broken by design.

Meaning new ones, of course. The existing ones should be fixed anyway
so I don't see the point of maintaining the mistake done in
<linux/slab.h> long time ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
