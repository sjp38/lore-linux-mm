Received: by ik-out-1112.google.com with SMTP id c21so922729ika.6
        for <linux-mm@kvack.org>; Fri, 24 Oct 2008 17:20:49 -0700 (PDT)
Date: Sat, 25 Oct 2008 04:24:06 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
Message-ID: <20081025002406.GA20024@x200.localdomain>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org> <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx> <20081024220750.GA22973@x200.localdomain> <Pine.LNX.4.64.0810241829140.25302@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810241829140.25302@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 06:29:47PM -0500, Christoph Lameter wrote:
> On Sat, 25 Oct 2008, Alexey Dobriyan wrote:
>
>> Fault occured at slab_destroy in KVM guest kernel.
>
> Please switch on all SLAB debug options and rerun.

They're already on!

New knowledge: turning off just DEBUG_PAGEALLOC makes oops dissapear,
other debugging options don't matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
