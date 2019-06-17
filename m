Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A267CC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5119B20820
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:28:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tNis53xz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5119B20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFB058E0005; Mon, 17 Jun 2019 05:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAC258E0001; Mon, 17 Jun 2019 05:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9A188E0005; Mon, 17 Jun 2019 05:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8E818E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id z19so11530327ioi.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:28:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dgc1wrW0fGZnefyMKVMTGRnzP9OVcereHagkOu/cG+U=;
        b=kMuGhkcHvch3MoajUoIeKNRwuJMed2QtXGQc+KssuZHKgQc2EKNhpA1iR9eYLLMvzW
         kMRE+uX0b0EDQwu7gk5pNSGe2FYTz8OTw9GPR1nY0WTg/y8pxjBaenqgNfpnSvZ+KRQP
         oQsuIImTIVFaZkN0/ZbMXxKtaeaY2mbhAD32T5ruPWJdMBXByOObvVv6n6F95AKC82I0
         Rm+WoNLHmltLE8Y7MxkTTttFLH5Mr7SUBZ5m5ARAMAjLzF8re9z1aTYjlAyxgGAF34n/
         wYOWeODwU+8KwIxol6zb/1/UcjguTCrEd/mf2aoT9s2i22Cw0WHcCXHNhqQLu/fLfiEq
         qJrw==
X-Gm-Message-State: APjAAAUcZQV6H+0Pl11XPPFktnf/unvNpxQR4Yp5IbepzmFzyyn8avQ0
	p0tk6+SQv0zyP0afYQPzPckUZPW2emRRH5QKvSwX96SwYr/+FxkyeinzmhwAVkPU+s1sygMVczJ
	m2h4DG7yRG9vF/bC8uMJf70Lz8UC+0zwrAar/lPsZ9rK/PsQKqThYNkUDGT9YBj07VQ==
X-Received: by 2002:a5d:9ad6:: with SMTP id x22mr23203697ion.136.1560763682396;
        Mon, 17 Jun 2019 02:28:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+gfOmlc8fAABckeb82tkoymr33Qx8qHIOeZCkyFGXtEOg79cJsazWyV8Xl8FGlXEbSQDX
X-Received: by 2002:a5d:9ad6:: with SMTP id x22mr23203665ion.136.1560763681843;
        Mon, 17 Jun 2019 02:28:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560763681; cv=none;
        d=google.com; s=arc-20160816;
        b=YI3Os2+3wvU4KeefoD/cBP3MTL5C8TSJbjsR1p3y/jGY4dBfVZJzgoHtTOe9Mui/bH
         T1NStW2i8y0b2McL60KP/Wwn11kSc8flCTMy5vkv9OBss9H9PbV9bzJLGYiGkDjyRuC3
         GE5cYi5+fNBwUECiKbe1XwbXYq7jt6itk8gS1L6EjyvXi013rnZne9ooB17pQf8UiNOC
         YFjgVp6Tk5GbF843gbt5Cn9WkBT2K2dd4HIb97le2fIEavR0mGwc30CagYnnwBKoyzMX
         zl2XxhTyXYdAC1fQcm0szUZR/EgKllqcFvvuaLMba9oK5KD91WfmjKh918/oiZZWmAJy
         /VFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dgc1wrW0fGZnefyMKVMTGRnzP9OVcereHagkOu/cG+U=;
        b=WM3B8SgRFhoSt43Sg8AAXcfO1l9WJTYdnOHQhveapbf/AD5usWM7i4oXIMrPaePwxi
         RGhctNz76STSMQkiV7MohDhgIXeVbrXJuxUDXBFcNnRXw0oIswERKBUD/IAG6Ioxj2vi
         gWbVxGwXYV0Cqd9pu6CCfU7b7NCdYZxg8OEQ4Bun/V2ODD8pK7KabhWplN9EjXXmdxuX
         47DwDmBJC1GpzpaqXUaNPCzRin+PI0ijedchXV8V/ySqLRd03tB1IayyAziFNGdOzMaq
         p4iA8Dv/LD87ijbzJ4FONvq0vjXLyx9dd4htmaatVvuMV5zqW/QYm9wEl2iPS34QS709
         jw0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=tNis53xz;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q43si16135726jac.118.2019.06.17.02.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 02:28:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=tNis53xz;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dgc1wrW0fGZnefyMKVMTGRnzP9OVcereHagkOu/cG+U=; b=tNis53xzbQZR2aMou732pL582
	h2akG0bu1oJD0boOM5O1W+C0s/uo2BPwL2h95A/DatIXLmF24M5kUTq5iR+N43yTObBeopwaVaxKn
	2nyApRRc4cq0QWGQ4eXdncto7ClkcpAUYNrlnlbDdza8rSK/kBXlSeBxAhvv5FCtBL040+RjOyOjM
	4ad3gCXje4n/dXRLEh1tL/eSnuQFt9NL5CU71x/rFfcOmYDWS3enCKObsN4l92/S0BqKzeGp1naQd
	yBRlZCgxDMG2X35QxX+BlO0FEQi92zBN+WPMgg5U2bstpzAL2WGHPx32nJGquwCUnxnNyY8pGSzjJ
	GpXI6zT9w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcnvg-00064Q-QK; Mon, 17 Jun 2019 09:27:57 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 91C3120144538; Mon, 17 Jun 2019 11:27:55 +0200 (CEST)
Date: Mon, 17 Jun 2019 11:27:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190617092755.GA3419@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
 <20190614095131.GY3436@hirez.programming.kicks-ass.net>
 <20190614224309.t4ce7lpx577qh2gu@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614224309.t4ce7lpx577qh2gu@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 01:43:09AM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 14, 2019 at 11:51:32AM +0200, Peter Zijlstra wrote:
> > On Wed, May 08, 2019 at 05:43:38PM +0300, Kirill A. Shutemov wrote:
> > > For MKTME we use per-KeyID direct mappings. This allows kernel to have
> > > access to encrypted memory.
> > > 
> > > sync_direct_mapping() sync per-KeyID direct mappings with a canonical
> > > one -- KeyID-0.
> > > 
> > > The function tracks changes in the canonical mapping:
> > >  - creating or removing chunks of the translation tree;
> > >  - changes in mapping flags (i.e. protection bits);
> > >  - splitting huge page mapping into a page table;
> > >  - replacing page table with a huge page mapping;
> > > 
> > > The function need to be called on every change to the direct mapping:
> > > hotplug, hotremove, changes in permissions bits, etc.
> > 
> > And yet I don't see anything in pageattr.c.
> 
> You're right. I've hooked up the sync in the wrong place.
> > 
> > Also, this seems like an expensive scheme; if you know where the changes
> > where, a more fine-grained update would be faster.
> 
> Do we have any hot enough pageattr users that makes it crucial?
> 
> I'll look into this anyway.

The graphics people would be the most agressive users of this I'd think.
They're the ones that yelled when I broke it last ;-)

