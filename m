Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C7CB36B0033
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 03:43:31 -0400 (EDT)
Date: Sat, 29 Jun 2013 17:14:32 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 1/4] mm/cma: Move dma contiguous changes into a
 seperate config
Message-ID: <20130629071432.GB8687@iris.ozlabs.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, linuxppc-dev@lists.ozlabs.org

On Fri, Jun 28, 2013 at 02:40:59PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We want to use CMA for allocating hash page table and real mode area for
> PPC64. Hence move DMA contiguous related changes into a seperate config
> so that ppc64 can enable CMA without requiring DMA contiguous.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

When you send out the next version, please cc kvm-ppc@vger.kernel.org,
kvm@vger.kernel.org and Alexander Graf <agraf@suse.de>.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
