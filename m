Received: by ug-out-1314.google.com with SMTP id 34so230558ugf.19
        for <linux-mm@kvack.org>; Mon, 27 Oct 2008 07:20:31 -0700 (PDT)
Date: Mon, 27 Oct 2008 17:23:53 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
Message-ID: <20081027142353.GA32490@x200.localdomain>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org> <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx> <20081024220750.GA22973@x200.localdomain> <Pine.LNX.4.64.0810241829140.25302@quilx.com> <20081025002406.GA20024@x200.localdomain> <20081025025408.GA27684@x200.localdomain> <490462FC.7040107@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <490462FC.7040107@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 26, 2008 at 02:30:52PM +0200, Avi Kivity wrote:
> Alexey Dobriyan wrote:
>> Same picture for different guest kernels: 2.6.26, 2.6.27, 2.6.28-rc1
>> and different host kernels: 2.6.26-1-686 from to be Debian Lenny, 2.6.27.3
>> and 2.6.28-rc1.
>>   
>
> Does this go away with !CONFIG_KVM_GUEST on the guest kernel?
>
> This only makes sense if you're using the kvm modules from kvm-77.  If  
> so, you can also try http://userweb.kernel.org/~avi/kvm-78rc1.tar.gz  
> which fixes a bug with CONFIG_KVM_GUEST.

Er, which commmit exactly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
