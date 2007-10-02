MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
Date: Wed, 3 Oct 2007 08:56:07 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC] PPC64 Exporting memory information through /proc/iomem
In-Reply-To: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty writes:

> I am trying to get hotplug memory remove working on ppc64.
> In order to verify a given memory region, if its valid or not -
> current hotplug-memory patches used /proc/iomem. On IA64 and
> x86-64 /proc/iomem shows all memory regions. 
> 
> I am wondering, if its acceptable to do the same on ppc64 also ?

I am a bit hesitant to do that, since /proc/iomem is user visible and
is therefore part of the user/kernel ABI.  Also it feels a bit weird
to have system RAM in something whose name suggests it's about MMIO.

> Otherwise, we need to add arch-specific hooks in hotplug-remove
> code to be able to do this.

Isn't it just a matter of abstracting the test for a valid range of
memory?  If it's really hard to abstract that, then I guess we can put
RAM in iomem_resource, but I'd rather not.

Thanks,
Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
