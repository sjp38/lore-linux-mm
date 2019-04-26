Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEA74C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A71482084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:51:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E0F6hjuo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A71482084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DAB16B0007; Thu, 25 Apr 2019 20:51:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38B286B0008; Thu, 25 Apr 2019 20:51:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 279C46B000A; Thu, 25 Apr 2019 20:51:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB1846B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 20:51:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r13so857969pga.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:51:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZPxMilL55F88OfnrEUq9EeEkyqqENOE39GSG+Um9TxI=;
        b=St5yeHudpCKFbgdNS5cr7MaR3Dnh2sn13n+oybyH7UUu4vS6GjCyLbVMc/f11/paV7
         RKT6BKSBw4WEBM2+kUwQjAERbtJDn9h+hzWnJEyk8ckhOcRH3jI/76KvFQfrpdRJiOHP
         hurV9eRsHSRTfpG7xlFi5vJGsyiMUKdFv5guTQLeZ9dGMMb3Z4LkNhIm06YTnbYjQmBn
         3Qrp078+tMEQRELxvyC48L8LRom7KjhhhfzwtEBPEsSz7GQ3b3bFfPrwrfNukdwP6Ymm
         XsLPI3O7EQyDHFiU8g5KA7w+aNAhxJAgcBK5Zc6xuVvH9wbapSA4JGNYKVU9ZNCRFbas
         3QtQ==
X-Gm-Message-State: APjAAAVGp3dkt5iKcr+3U08cvcky2696eDqVCbDMf2eaSFjvzmad5Hus
	2AOWNZh1Dh2Q3ZtSeXfvy99EThFn5aV3xuFwTGGlZhwcD3pahgEtf6rMDF+p2da4ktzGDOqUY1z
	oSIJc45hxd50fTFOnAKvDMAFS+jU0RH0vvTtnKbY99tudpZAAy7nD7PwyXkYooKV1IA==
X-Received: by 2002:a17:902:2d04:: with SMTP id o4mr43239463plb.88.1556239890195;
        Thu, 25 Apr 2019 17:51:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxTITPWxrYKCsiGQrjYufch/jY07vEGKquo9VbVvKc8yM5FUVSD8CVMm5uVj6NkjGrIeSF
X-Received: by 2002:a17:902:2d04:: with SMTP id o4mr43239409plb.88.1556239889345;
        Thu, 25 Apr 2019 17:51:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556239889; cv=none;
        d=google.com; s=arc-20160816;
        b=zdTJ3NNl+j2Z5Ismjv8nABhqj/xPVsjT244hWoMnLl1uvC2wPS39Cb0NHQRMADfxuS
         4qgVSZg8zc6Fe1+Y9JiTn3w6rTvB1Lrz/sKDFBvWg2cQFCvI9bwdwj9aSF3vwcWN8ySt
         xiOmfjRM8tLA1asDNPWR4YMkIAgOqcoytSrHIZNr9DlncM1bbFwxfh8bD3yc29ylCLA/
         WXADU+CdtOL2F0i/6ZiAqD5Gjy+XaGgMixuOJYODn//+SOuxrh1lZzRF4IYilozyFYET
         1fEHfJ/p5tMKIL8yR1mxOybs+pA9/LsD5ddoZByGY4jsyggW5OM8oIX/GauyrfdHcD28
         cueA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZPxMilL55F88OfnrEUq9EeEkyqqENOE39GSG+Um9TxI=;
        b=KC9mtwMD5TWxZsQAlM+R1x0d5hArqU015EwAw1dijqmMXxCmO3inTNOA53k8Zf73wP
         BP6QTawdfJItv7Qfvhhtf9eJ5QMw1X3uo9SO7cZkoz1Xg+BLqCHxIBwBVpD9Q6QZaalh
         lxu/rMo++2CUXVIM6fMPZDdJeuA6Psl4Wk7JplZqnVw5w2OPE/6gRTLrPnQ48AxEH4T4
         +zmJVtGE8boVYVRM/qtCNpZ25fBtsi5aKU/ttnLeOx7R75+qX8nEjbirIWtvCj1GMX0T
         IVrMlJDf63IQRZf6gtNXEGxfRqgZZa9lE4e2BDU6dMIVE+WjDd4qdnqjo/xqt73exKYn
         z6Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E0F6hjuo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p9si23754172plo.49.2019.04.25.17.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 17:51:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E0F6hjuo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ZPxMilL55F88OfnrEUq9EeEkyqqENOE39GSG+Um9TxI=; b=E0F6hjuoTiAbr23o8nn5Dpddz
	W2QnBTSDLijahKTNq51dB36Q26RPSHKGDMcbHl3mNZ7/2TB6PcDitNtwEsUH4qjhfqb8NruFV5Bdl
	Zjqr+j73L7y/6aiZCiWrVn1GhBSnczo24TZGBrkITbqsS8D63JOkFxwnhUIDhKlLMD9IVKKfSLHzx
	gFmt8CBd4G4CcrHR5wj3+QsIKwHD7Y49lwsayA6YTkmZ94uV8MHLFIN4ZBtC2M6EEyR2oQ7kcWoLf
	3rayZelRy2skZeQ7D8uS7667hcWZ6TIALxdtMaZlyKVjJ6aAHyJVmXKT0ei21HN6FUBiVyhaDKMU9
	hqLRXyD8A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJp5J-0000Zp-2k; Fri, 26 Apr 2019 00:51:25 +0000
Date: Thu, 25 Apr 2019 17:51:24 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux MM <linux-mm@kvack.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	stable <stable@vger.kernel.org>,
	Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
Message-ID: <20190426005124.GA25606@bombadil.infradead.org>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org>
 <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
 <20190425073149.GA21215@quack2.suse.cz>
 <CAPcyv4iYMP4NWxa08zTdRxtc4UcbFFOCwbMZijB0bc2WcawggQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iYMP4NWxa08zTdRxtc4UcbFFOCwbMZijB0bc2WcawggQ@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 05:33:04PM -0700, Dan Williams wrote:
> On Thu, Apr 25, 2019 at 12:32 AM Jan Kara <jack@suse.cz> wrote:
> > > > We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> > > > that need to change too?
> > >
> > > It wasn't clear to me that it was a problem. I think that one already
> > > happens to be pmd-aligned.
> >
> > Why would it need to be? The address is taken from vmf->address and that's
> > set up in __handle_mm_fault() like .address = address & PAGE_MASK. So I
> > don't see anything forcing PMD alignment of the virtual address...
> 
> True. So now I'm wondering if the masking should be done internal to
> the routine. Given it's prefixed vmf_ it seems to imply the api is
> prepared to take raw 'struct vm_fault' parameters. I think I'll go
> that route unless someone sees a reason to require the caller to
> handle this responsibility.

The vmf_ prefix was originally used to indicate 'returns a vm_fault_t'
instead of 'returns an errno'.  That said, I like the interpretation
you're coming up with here, and it makes me wonder if we shouldn't
change vmf_insert_pfn_pmd() to take (vmf, pfn, write) as arguments
instead of separate vma, address & pmd arguments.

