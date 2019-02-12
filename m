Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA2BC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:06:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06DE8218D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:06:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06DE8218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 819A98E0014; Tue, 12 Feb 2019 05:06:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C96B8E0012; Tue, 12 Feb 2019 05:06:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BA2D8E0014; Tue, 12 Feb 2019 05:06:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 440188E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:06:33 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so2132284qte.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:06:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IghLfPK9voST0pZo26DQoOKWqr6P65VBAWg+jOA7etM=;
        b=WXfmw8NCUxhtx1Z4LjIc1a7WDOBF5aI53dr1/hDimRIuTFO6Dz34XTJ33njJF9KUq/
         /mJP2tsTj4ty28VzOaLvITni88Wv0lMDJUvxB+4fyGmjDl9tUXZDL28uRjPysIFjED/U
         GcLlbyf5CNVAUuS6hrZB9bzYCxMY08jG3z5NJfJG+nIimbwmeNYGXSdQ6ZzZrQwtCPJk
         rghevn6cYZPCpu1Gv5PfBa2NkYfOZwzVZhTQSbq90mV46afLAU9EY1TulKwJxiMxEBD1
         Rdacoyzu3IVT24MGD0WND482/ANZ0QfJBulhI/tsRTqF2Xm+oEeo6b8jmf/7Z2OPklsc
         2yug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYFtANgjyKRd9YIOl8P1f+l7wRvm7nfWhCtnpX9JowbSHf5VAK2
	5ilepAT76+LTm1ySOZWNuGwJpKCFhr76poHFTtJE8lO2Yj6HkXyMQVmQWu51zfqgrjbutTRAcug
	jcV5PLdMg1TnJLI7Vw9yv2H2yr0hpa4lvugKZy8vfd/Elm/R6TW17KU9oxiNYvhFnUg==
X-Received: by 2002:aed:3574:: with SMTP id b49mr2093080qte.235.1549965993020;
        Tue, 12 Feb 2019 02:06:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IboMsCkfCY3LRGY0wHE0FPYjc0AhWyqNVk0NmG/J/stGAim7PUCUy/paluKj1c4dLMefaln
X-Received: by 2002:aed:3574:: with SMTP id b49mr2093045qte.235.1549965992354;
        Tue, 12 Feb 2019 02:06:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549965992; cv=none;
        d=google.com; s=arc-20160816;
        b=njZlMMMDdp1WYBYC11XN4HjDgKU6MmCtk0obqNrorxVSMfWc6TpdmLh1+O7t9xZaUo
         icRXVF/RDFEgt6LqEK4SK5ZDPiHyknqTKfWyxVj5llODfwNQWZOBr0kLtmIhH0EXh/Wo
         0s9MJnPxUJACUmu5j0fY0bw6UUUuk4uzaOHpVxiZTLDFyG7JmQN8nnejelKChzTPonvQ
         3/2BvjlIvEV557gWlyNIuTYrTq1Ywz24sCGfv/cr7GLWVG/2wKdY/WScOSsiLKbmu1Mj
         SIcgdDukCVrEuyYasNHUjlWV0b9lRFHd56u0ShZSmZlmdUQh8LlbeBnEvrtgAQANZjTp
         FWtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IghLfPK9voST0pZo26DQoOKWqr6P65VBAWg+jOA7etM=;
        b=mkZkBfHeAt3KbGFhcXMTSInJCT3eOQukz5GPpnvMEAdZZj1TJpDuJ/TF5YkG6Z2UiP
         ImT9hX34T5WGYxNEsNUF/BkEVusfmz0W7ZOvArUId0G3hd65M/aFiJ+mCQwiTHXI9zgK
         oSJ0GzZQacYZQVcGf4quwp0q35uAwDzrsP+ndE86ELGRHsQkBVasK6v8ceZxq507YnFC
         VLJjsAJdu1ZJuVPkOGNRdntzfo0vnRr6mby4bpetzr8LfQ1Oyd/N1dwEFsei5rIxxiWx
         WFwfi94ambrZ3Uq3TkUHvorEmM2hQXDBFDaUXrx9//ZcNJx9qM66RIAmRAmH5+zhszjB
         G+FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z32si2537560qtb.234.2019.02.12.02.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:06:32 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2824C49DDD;
	Tue, 12 Feb 2019 10:06:30 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CAD275C21A;
	Tue, 12 Feb 2019 10:06:22 +0000 (UTC)
Date: Tue, 12 Feb 2019 11:06:20 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, Toke =?UTF-8?B?SMO4aWxh?=
 =?UTF-8?B?bmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, Saeed Mahameed <saeedm@mellanox.com>, Andrew
 Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, "David S.
 Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>,
 brouer@redhat.com, Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [net-next PATCH 1/2] mm: add dma_addr_t to struct page
Message-ID: <20190212110620.5ceb5366@carbon>
In-Reply-To: <20190211165551.GD12668@bombadil.infradead.org>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
	<154990120685.24530.15350136329514629029.stgit@firesoul>
	<20190211165551.GD12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 12 Feb 2019 10:06:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 08:55:51 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, Feb 11, 2019 at 05:06:46PM +0100, Jesper Dangaard Brouer wrote:
> > The page_pool API is using page->private to store DMA addresses.
> > As pointed out by David Miller we can't use that on 32-bit architectures
> > with 64-bit DMA
> > 
> > This patch adds a new dma_addr_t struct to allow storing DMA addresses
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>  
> 
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> 
> > +		struct {	/* page_pool used by netstack */
> > +			/**
> > +			 * @dma_addr: Page_pool need to store DMA-addr, and  
> 
> s/need/needs/
> 
> > +			 * cannot use @private, as DMA-mappings can be 64-bit  
> 
> s/DMA-mappings/DMA addresses/
> 
> > +			 * even on 32-bit Architectures.  
> 
> s/A/a/

Yes, that comments needs improvement. I think I'll use AKPMs suggestion.


> > +			 */
> > +			dma_addr_t dma_addr; /* Shares area with @lru */  
> 
> It also shares with @slab_list, @next, @compound_head, @pgmap and
> @rcu_head.  I think it's pointless to try to document which other fields
> something shares space with; the places which do it are a legacy from
> before I rearranged struct page last year.  Anyone looking at this should
> now be able to see "Oh, this is a union, only use the fields which are
> in the union for the type of struct page I have here".

I agree, I'll strip that comment.

 
> Are the pages allocated from this API ever supposed to be mapped to
> userspace?

I would like to know what fields on struct-page we cannot touch if we
want to keep this a possibility?

That said, I hope we don't need to do this. But as I integrate this
further into the netstack code, we might have to support this, or
at-least release the page_pool "state" (currently only DMA-addr) before
the skb_zcopy code path.  First iteration will not do zero-copy stuff,
and later I'll coordinate with Willem how to add this, if needed.

My general opinion is that if an end-user want to have pages mapped to
userspace, then page_pool (MEM_TYPE_PAGE_POOL) is not the right choice,
but instead use MEM_TYPE_ZERO_COPY (see enum xdp_mem_type).  We are
generally working towards allowing NIC drivers to have a different
memory type per RX-ring.


> You also say in the documentation:
> 
>  * If no DMA mapping is done, then it can act as shim-layer that
>  * fall-through to alloc_page.  As no state is kept on the page, the
>  * regular put_page() call is sufficient.
> 
> I think this is probably a dangerous precedent to set.  Better to require
> exactly one call to page_pool_put_page() (with the understanding that the
> refcount may be elevated, so this may not be the final free of the page,
> but the page will no longer be usable for its page_pool purpose).

Yes, this actually how it is implemented today, and the comment should
be improved.  Today __page_pool_put_page() in case of refcount is
elevated do call __page_pool_clean_page() to release page page_pool
state, and is in principle no longer "usable" for page_pool purposes.
BUT I have considered removing this, as it might not fit how want to
use the API. In our current RFC we found a need for (and introduced) a
page_pool_unmap_page() call (that call __page_pool_clean_page()), when
driver hits cases where the code path doesn't have a call-back to
page_pool_put_page() but instead end-up calling put_page().

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

