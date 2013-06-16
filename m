Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DF8B56B0034
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 00:31:34 -0400 (EDT)
Message-ID: <1371357080.21896.115.camel@pasglop>
Subject: Re: [PATCH 2/4] powerpc: Prepare to support kernel handling of
 IOMMU map/unmap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 16 Jun 2013 14:31:20 +1000
In-Reply-To: <1371356818.21896.114.camel@pasglop>
References: <1370412673-1345-1-git-send-email-aik@ozlabs.ru>
	 <1370412673-1345-3-git-send-email-aik@ozlabs.ru>
	 <1371356818.21896.114.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Alexander Graf <agraf@suse.de>, Paul Mackerras <paulus@samba.org>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 2013-06-16 at 14:26 +1000, Benjamin Herrenschmidt wrote:
> > +int realmode_get_page(struct page *page)
> > +{
> > +     if (PageCompound(page))
> > +             return -EAGAIN;
> > +
> > +     get_page(page);
> > +
> > +     return 0;
> > +}

Shouldn't it be get_page_unless_zero ?

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
