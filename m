Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 5EB706B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 02:16:40 -0400 (EDT)
Date: Wed, 3 Jul 2013 16:16:26 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V3 4/4] powerpc/kvm: Use 256K chunk to track both RMA
 and hash page table allocation.
Message-ID: <20130703061626.GB25034@drongo>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1372743918-12293-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372743918-12293-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, agraf@suse.de, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

On Tue, Jul 02, 2013 at 11:15:18AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Both RMA and hash page table request will be a multiple of 256K. We can use
> a chunk size of 256K to track the free/used 256K chunk in the bitmap. This
> should help to reduce the bitmap size.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
