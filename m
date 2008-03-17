Date: Mon, 17 Mar 2008 10:59:55 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [18/18] Implement hugepagesz= option for x86-64
Message-ID: <20080317095955.GB12405@basil.nowhere.org>
References: <20080317258.659191058@firstfloor.org> <20080317015832.2E3DF1B41E0@basil.firstfloor.org> <20080317042939.051e76ff.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080317042939.051e76ff.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 04:29:39AM -0500, Paul Jackson wrote:
> Andi wrote:
> +	hugepages=	[HW,X86-32,IA-64] HugeTLB pages to allocate at boot.
> +	hugepagesz=	[HW,IA-64,PPC,X86-64] The size of the HugeTLB pages.
> +			On x86 this option can be specified multiple times
> +			interleaved with hugepages= to reserve huge pages
> +			of different sizes. Valid pages sizes on x86-64
> +			are 2M (when the CPU supports "pse") and 1G (when the
> +			CPU supports the "pdpe1gb" cpuinfo flag)
> +			Note that 1GB pages can only be allocated at boot time
> +			using hugepages= and not freed afterwards.
> 
> This seems to say that hugepages are required for hugepagesz to be

Yes, but that was already there before. I didn't change it.

I agree it should be fixed, but i would prefer to not mix 
PPC specific patches into my patchkit so I hope someone 
else will do that afterwards.

> useful, but hugepagesz is supported on PPC, whereas hugepages is not
> supported on PPC ...odd.
> 
> Should those two HW lists be the same (and sorted in the same order,
> for ease of reading)?

Not all architectures support hugepagesz=, in particular i386 
does not and possibly others. It is implemented by arch specific
code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
