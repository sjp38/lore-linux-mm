Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A732B6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 18:28:51 -0400 (EDT)
Message-ID: <1372804109.4122.25.camel@pasglop>
Subject: Re: [PATCH -V3 2/4] powerpc/kvm: Contiguous memory allocator based
 hash page table allocation
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 03 Jul 2013 08:28:29 +1000
In-Reply-To: <51D2EDD7.9060205@suse.de>
References: 
	<1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1372743918-12293-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <51D2EDD7.9060205@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

On Tue, 2013-07-02 at 17:12 +0200, Alexander Graf wrote:
> Is CMA a mandatory option in the kernel? Or can it be optionally 
> disabled? If it can be disabled, we should keep the preallocated 
> fallback case around for systems that have CMA disabled.

Why ? More junk code to keep around ...

If CMA is disabled, we can limit ourselves to dynamic allocation (with
limitation to 16M hash table).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
