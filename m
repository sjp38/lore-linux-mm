Date: Fri, 24 Oct 2008 18:29:47 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
In-Reply-To: <20081024220750.GA22973@x200.localdomain>
Message-ID: <Pine.LNX.4.64.0810241829140.25302@quilx.com>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org>
 <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx>
 <20081024220750.GA22973@x200.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Oct 2008, Alexey Dobriyan wrote:

> Fault occured at slab_destroy in KVM guest kernel.

Please switch on all SLAB debug options and rerun.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
