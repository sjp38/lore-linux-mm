Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51590C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1184720657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:25:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iagTfw8x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1184720657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 941A28E0005; Mon, 17 Jun 2019 05:25:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CBFF8E0001; Mon, 17 Jun 2019 05:25:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71E2A8E0005; Mon, 17 Jun 2019 05:25:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE1A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:25:44 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s83so11524985iod.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:25:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R5E4jvXEvZihQlXT71dalQ2LmxCFvADw8lOr0h8eEyE=;
        b=GBlwI8kgZeDJ3WvWY0shL2Ddc3uTTyAZACDuGhUU/dXfbIs3Exn/gy7M85aueKeybO
         XlPziQsowTZ/G5M71Vy4pQxeNLCLGyDWHBeQ9dyXULZfDCtP2h8AfuMANf39SyoqBleA
         pqoOOnLQ/gE5G3gbBAPEKp2ek7r4qY/viAW4uur5jqfmiSPy67s5Rt9h7qqnQvCyNwPv
         CNU/6+2rD72JUpRMmfCeovDACFqhetulFYOBKjBVZkPXDsPHePvjkt2LVWqn3KA/iQU+
         Wf7637rAJbIKyNAFigYDPKKN5xZpneCnc5Sv4YRiq9USD0/hjZWuvnIuT3B4TXChoXAh
         OwlA==
X-Gm-Message-State: APjAAAWR7jqSPgK3m5sinXpKNspw1bEJ/0WicCJx12I3ydsteE5dBrrt
	cYlhzeuR4tEbL3NrTOe/TdlKFmk8uW53rJwALIh3HbPvjOOIIvuHX2JQ+5U7FeN9At04vJjhS7O
	0kgTUXSgflWcfdjLcwoy7uRQdAWzkR1iLIsblP33b48wg/6oKaT9jz1x+jRarCGlN2Q==
X-Received: by 2002:a02:ce37:: with SMTP id v23mr20036745jar.2.1560763544120;
        Mon, 17 Jun 2019 02:25:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/pFGtdskUUV58lJ6KalIr9vO9heQXCgtRQjQpBV5kQiE4OFLeS0e5ekESBCQCMkq8RpMH
X-Received: by 2002:a02:ce37:: with SMTP id v23mr20036708jar.2.1560763543607;
        Mon, 17 Jun 2019 02:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560763543; cv=none;
        d=google.com; s=arc-20160816;
        b=BsKlZwu2YjYQhObu7Xv9BvNDTSkshn8FX29QUdXDWwbC7Fl68yFbvejHGAiLXgFs3Q
         +PeFgxA0y+KiaFDNFd9evlgLTK1tSncbomQf1gsxT+FVP6CWlokKyGeYk+DvmN5yydea
         nLPWnG/ApsgvnT5jxjS5TxIZVgWD84DPmpkwNf2LzAOWI83bDrA62P1/gNF76/8plhRd
         qEXonV0b4UEAs4v07PPB1EHy4pbJfnMB6EYSW6niW3MLfUYm2qG/4SqTTzQuuWGbZKO9
         /1M79qMRa8PzPnISuDwCXGx/4vtcxJTFRivvMfTu2IntW7/d6eYTKCGwKOtU6WHvYaLn
         3cNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R5E4jvXEvZihQlXT71dalQ2LmxCFvADw8lOr0h8eEyE=;
        b=v2HJ38JpQMzvXqbTZZhEI4hELLN6wLi2Dkwf4mCoS/lKIDbnD7qKQjpRPE7gRTFkHi
         avPd3uopIeHQGxgjxyYxW/gb8w+lI064m6Kio8AnnFja9OdZBF/f1mcgpJnQ2nrsi+j/
         pVIaP6AkyuEk2mr9IYk9kBjuDPeqerISx/6R79v4sTGzdf8GW7maIETLzvWFtjDPM/cZ
         RtIWEK1LGRUuh6WFn9G/VVR4gi1ku3Lyu9Ysd3sIdqFxr72ZsxhFe7oedujQsKYGpxJj
         hKfvADIuek6jmC4xcBl5dmT7N8O5leaIxfOBfFlqKH6f9InPm3eswtIbZzuJ7X1nPN9F
         gd8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=iagTfw8x;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n123si15012328iod.129.2019.06.17.02.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 02:25:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=iagTfw8x;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=R5E4jvXEvZihQlXT71dalQ2LmxCFvADw8lOr0h8eEyE=; b=iagTfw8xds9QY4p8IF0ieCpv7
	R6fN48j9Es6f93Yz2tldjKCQ+ntXSefyw3kNrKsMbUbjUqA84TeJzXrLEdQObSICB1iVXJGOQ8+Eq
	9IRMyOs8kYnpBHcGb6vewf6hYAdf+YhVjHqsNPjXmadLMxaRTZ6GUT5fPqBsFdBcRwSDu4jLiRB2u
	6hge9UbGUNfEwOyQAh3M2OUPuxWisqxTqIyBh9HT1+DrBhloyWAbYW5EX6+6oHX7zl1J1JhlESdAl
	mw0BwUkVul1GvsVfBbz0Hn28CVedvWeDc9DPhTlTajB0W4zdU5IGdxqqA1USUGiTQ/EKg+tF/qlYo
	U1JjgEeQA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcntN-00063N-3A; Mon, 17 Jun 2019 09:25:34 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C392220144538; Mon, 17 Jun 2019 11:25:31 +0200 (CEST)
Date: Mon, 17 Jun 2019 11:25:31 +0200
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
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190617092531.GZ3419@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
 <20190614110458.GN3463@hirez.programming.kicks-ass.net>
 <20190614132836.spl6bmk2kkx65nfr@box>
 <20190614134335.GU3436@hirez.programming.kicks-ass.net>
 <20190614224131.q2gjai32la4zb42p@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614224131.q2gjai32la4zb42p@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 01:41:31AM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 14, 2019 at 03:43:35PM +0200, Peter Zijlstra wrote:

> > Not really, it all 'works' because clflush_cache_range() includes mb()
> > and page_address() has an address dependency on the store, and there are
> > no other sites that will ever change 'keyid', which is all kind of
> > fragile.
> 
> Hm. I don't follow how the mb() in clflush_cache_range() relevant...
> 
> Any following access of page's memory by kernel will go through
> page_keyid() and therefore I believe there's always address dependency on
> the store.
> 
> Am I missing something?

The dependency doesn't help with prior calls; consider:

	addr = page_address(page);

	*addr = foo;

	page->key_id = bar;

	addr2 = page_address(page);


Without a barrier() between '*addr = foo' and 'page->key_id = bar', the
compiler is allowed to reorder these stores.

Now, the clflush stuff we do, that already hard orders things -- we need
to be done writing before we start flushing -- so we can/do rely on
that, but we should explicitly mention that.

Now, for the second part, addr2 must observe bar, because of the address
dependency, the compiler is not allowed mess that up, but again, that is
something we should put in a comment.

