Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id k0N8lNWs149758
	for <linux-mm@kvack.org>; Mon, 23 Jan 2006 08:47:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0N8lMsw199300
	for <linux-mm@kvack.org>; Mon, 23 Jan 2006 09:47:22 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k0N8lMI9020666
	for <linux-mm@kvack.org>; Mon, 23 Jan 2006 09:47:22 +0100
Date: Mon, 23 Jan 2006 09:47:15 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [rfc] split_page function to split higher order pages?
Message-ID: <20060123084715.GA9241@osiris.boeblingen.de.ibm.com>
References: <20060121124053.GA911@wotan.suse.de> <1137853024.23974.0.camel@laptopd505.fenrus.org> <20060123054927.GA9960@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060123054927.GA9960@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Arjan van de Ven <arjan@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > Just wondering what people think of the idea of using a helper
> > > function to split higher order pages instead of doing it manually?
> > 
> > Maybe it's worth documenting that this is for kernel (or even
> > architecture) internal use only and that drivers really shouldn't be
> > doing this..
> 
> I guess it doesn't seem like something drivers would need to use
> (and none appear to do anything like it).

And I thought this could/should be used together with vm_insert_page() that
drivers are supposed to use nowadays instead of remap_pfn_range().
Why shouldn't drivers use this?

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
