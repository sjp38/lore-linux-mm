Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83815C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 378372080C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="1SzaizZl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 378372080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE71E8E0003; Mon, 17 Jun 2019 05:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B701D8E0001; Mon, 17 Jun 2019 05:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A114D8E0003; Mon, 17 Jun 2019 05:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEE28E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:08:41 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f22so11426459ioh.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:08:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wRdvOfPDETJvARv+zW+J5HAlYTlZLHmPl7FzG8lv1Ps=;
        b=irtp3kAdFcjvKKNT4KNj6rQ0xOeMy777DpVgD4Hq90SCwlgB/wJRIJdY4L1rWxYOAS
         CNRfHL8/7GQ4z3HDMuiLyRrouMhvb5rOQEJL3bfUx5Kq1KX7C3+6pw5oMKXjfFVYxIdJ
         kk69A7kQfm2nfUSEaKga1MHrM401mVLPEsQEjM+aO08IntQFsiXolittkfNjTZ/MAJJt
         pprHdHggMV68HSXT3ksL23kgnka7lZ79oHOjkD5mDYlYZ687d/m0nYaGO+HRTQv1bL0j
         8kdFQCTGHVvAIbsTav7s02jDjLVGkMxBKqn8jItZV5CfYPBRRaals1yIiTtp/k8vDYB0
         roWQ==
X-Gm-Message-State: APjAAAW4Ltr9uq2J9CY/ArSoezUbkHQbKWaElE2RGlergk3PMLrrbJBl
	KwS0ifwb3OOncUqIH5oGIKg8eFm4Lxbf1ZzJjQvrQNQVwUBKEe6cBtwEtW7dj8zhQ0dRG4XoAsF
	m1n7OhErxcfTUXXLprtDAAJLWYcejKmoGGX2YIOiuIszOZ3MRs4NIZdeEswsguhswqQ==
X-Received: by 2002:a02:ce52:: with SMTP id y18mr77338584jar.78.1560762521271;
        Mon, 17 Jun 2019 02:08:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzl0rjS122srMzehU4afQiqLHFDAbk6fRLBKCoihlexwb//yFo3tje1V/p+bkmzCUZ6R3ZU
X-Received: by 2002:a02:ce52:: with SMTP id y18mr77338541jar.78.1560762520646;
        Mon, 17 Jun 2019 02:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560762520; cv=none;
        d=google.com; s=arc-20160816;
        b=deYkA2vWjq9uBvfVX1+ANORti2u0MS6JdGqVFIMsM/kye46iyFlAsKqLJCtK12DT4o
         cXqp9vLgkJ+QTxYNqMyQiNGNiQ5WLSeBXF64MOi1UtyQGyrK1yRpVuEprG3Jxgzg6s1n
         C8liV+yvcw56S03R8vznwgCh92zZmGr12/K6qCXBNAjsjlSkVvEz00gDKCD54Oo9rDGn
         eRdh28i84AI/LaDIJK/EOxexTZAMZppTo7exLAO6mIHXVoakOIKegMWldNkPp5Cxxt7x
         aajb95igE1JYnqxxuIpdLZeGXngyEibE3zl/gBGDm1nBiMWugwnU47VfgONWYof7HYsJ
         mzzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wRdvOfPDETJvARv+zW+J5HAlYTlZLHmPl7FzG8lv1Ps=;
        b=jID0HS0aDO7l6Q4wBBZopevyVCdahqjKLicmKz+X0epnVQunAzPKKNyi08UT/VvVuy
         8rZxyvZHF1WdD+OJrpLqtXsa6OGQHuyXp1m8CsHZ/oUeagzqrkOXQ75FDKx1DZFcmdm3
         MuQSxmSBotYDDvuTr3G62ndmSPxfCY8UO6mGTfGK16GjbLu2x9Et0z741JH3Iih91CnW
         fvuKm2GffpOmFf3MoboM7JFxx1Y4BcHSgff5tHYlfzEpX0e57VEgcw90US7FN7jHs85p
         zmFmDk0Fjutgihwpv5r//GdgsU0jQl5FWtDOEKbXPfKauo9twi/VkW0n1LD2IyV32k3Y
         IihQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1SzaizZl;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i10si12868947iol.68.2019.06.17.02.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 02:08:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1SzaizZl;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=wRdvOfPDETJvARv+zW+J5HAlYTlZLHmPl7FzG8lv1Ps=; b=1SzaizZlFZrcso1vWkqcGDQl+
	3GTCltkdhp6F4a07txN0iCkbOsUS3i2IcD+SBI6D6d9SwZsu4Oycx+PvZZikN/HOdKTZel19mOF2J
	+peAXjqfCZilEMVgF0K7ZJwWBaqoYufu0uC0+iuDeKKct2mo+pCFPu/C1lPHumKWDgt7haPR9GIgQ
	TBo8KuIZVoi+uAFMs/Z1tHQ3wg+4yhY5/sfjUYVByRFDQ9XvfpYTwgHraXRrjLA1aP+Bk0x0UN4An
	y0z13wfIJsgXhGdYqGoUMe0nZyQTlF1QGFr2mKt6F9CN05mSKBVY3Glim/3cO/Ed3NCdpaqW/QkYQ
	ElKV/y6YQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcncs-0005vu-7b; Mon, 17 Jun 2019 09:08:30 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D430F2025A803; Mon, 17 Jun 2019 11:08:27 +0200 (CEST)
Date: Mon, 17 Jun 2019 11:08:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alison Schofield <alison.schofield@intel.com>
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
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190617090827.GY3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <20190614115137.GF3436@hirez.programming.kicks-ass.net>
 <20190615003231.GA15479@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615003231.GA15479@alison-desk.jf.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 05:32:31PM -0700, Alison Schofield wrote:
> On Fri, Jun 14, 2019 at 01:51:37PM +0200, Peter Zijlstra wrote:
> > On Wed, May 08, 2019 at 05:44:05PM +0300, Kirill A. Shutemov wrote:
> snip
> > >  /*
> > > - * When pkey==NO_KEY we get legacy mprotect behavior here.
> > > + * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
> > > + * for Protection Keys and Memory Encryption Keys. These extensions are
> > > + * mutually exclusive and the behavior is:

Well, here it states that the extentions are mutually exclusive.

> > > + *	(pkey==NO_KEY && keyid==NO_KEY) ==> legacy mprotect
> > > + *	(pkey is valid)  ==> legacy mprotect plus Protection Key extensions
> > > + *	(keyid is valid) ==> legacy mprotect plus Encryption Key extensions
> > >   */
> > >  static int do_mprotect_ext(unsigned long start, size_t len,
> > > -		unsigned long prot, int pkey)
> > > +			   unsigned long prot, int pkey, int keyid)
> > >  {
> 
> snip
> 
> >
> > I've missed the part where pkey && keyid results in a WARN or error or
> > whatever.
> > 
> I wasn't so sure about that since do_mprotect_ext()
> is the call 'behind' the system calls. 
> 
> legacy mprotect always calls with: NO_KEY, NO_KEY
> pkey_mprotect always calls with:  pkey, NO_KEY
> encrypt_mprotect always calls with  NO_KEY, keyid
> 
> Would a check on those arguments be debug only 
> to future proof this?

But you then don't check that, anywhere, afaict.

