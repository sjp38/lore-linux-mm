Message-ID: <490462FC.7040107@redhat.com>
Date: Sun, 26 Oct 2008 14:30:52 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org> <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx> <20081024220750.GA22973@x200.localdomain> <Pine.LNX.4.64.0810241829140.25302@quilx.com> <20081025002406.GA20024@x200.localdomain> <20081025025408.GA27684@x200.localdomain>
In-Reply-To: <20081025025408.GA27684@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Alexey Dobriyan wrote:
> Same picture for different guest kernels: 2.6.26, 2.6.27, 2.6.28-rc1
> and different host kernels: 2.6.26-1-686 from to be Debian Lenny, 2.6.27.3
> and 2.6.28-rc1.
>   

Does this go away with !CONFIG_KVM_GUEST on the guest kernel?

This only makes sense if you're using the kvm modules from kvm-77.  If 
so, you can also try http://userweb.kernel.org/~avi/kvm-78rc1.tar.gz 
which fixes a bug with CONFIG_KVM_GUEST.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
