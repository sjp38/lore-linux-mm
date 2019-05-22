Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EFBDC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13B552081C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:43:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13B552081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91B136B000A; Wed, 22 May 2019 15:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AD5A6B000C; Wed, 22 May 2019 15:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7931D6B000D; Wed, 22 May 2019 15:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3CA6B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:43:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w3so1644826wrr.6
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Fmg2iGQ2QOU8aycVFt1PBF/LG/OCJFeJteK+WquArzs=;
        b=dAMmu4Ubt1AOwi3sUzIlOpkJtG3QoE7+rsanZjux8ll/j3zUfCa/iB/mz+v7AjezIb
         9OpBCL5vVyj7efIPBQXkFvz4eJjOQ3XM6MwGdrE99BGoaaOp1rsfvZi1kOYfEAW1jv73
         J3p1gILaEGlFVSheV8CXxTkz608hpE4lqdKTUMhXiENg8uK6Oqy51Kz2fznatgDko78Y
         LRK77J+KC52NPtNbh23Yc6vVJesbfIcD/xy9ycm13/BRNFee7bUXRqcCIwdQnJVHeSHZ
         M2F2Oi+rj8P0YT7A25EFWybwDB1K8EfoaVAG91vpb0baYioB75NQRnrzLomUkwhrbJcp
         iKbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAUAxfM0tS/BXyVrQkaScrG0u0JjNMjwzzyLo7JRfeVL86wqrvs8
	h64O0G8UyZ+htQlko0gtlkg6L9kO3dgNSWEpCnYTeLLs8qtwMcpcQhtmCKmYO+MydrgNhFBPFco
	mwgBoBFGPL1WxLZDCUf79scmW840Pkue+p77TcjNrKThbwuT6NlFPqMv05ndnMQkMPg==
X-Received: by 2002:a1c:ba54:: with SMTP id k81mr8171214wmf.70.1558554211727;
        Wed, 22 May 2019 12:43:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu7gUQJoxOR62E+O0fv2t7WPzitqWtngFNlwE0H8Z9sRTT5mvPVRssUnxb2CH+Ag/MMPqN
X-Received: by 2002:a1c:ba54:: with SMTP id k81mr8171172wmf.70.1558554210916;
        Wed, 22 May 2019 12:43:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558554210; cv=none;
        d=google.com; s=arc-20160816;
        b=phLJ+cOndErER3c9bC+3LbIDZemGqyCvauHYNXWfUE3nz9/HjOX/Ak6RfNqdJCUYOT
         C9RRQzEjayX7o+Y11ANjKKJCP07u7Nk1rMRz0XrOaRjyvwuh1AAEDAWKIzleEI752zGa
         oacvjouDjUpAFsv45dEQXWFHygBSMsBjrnUR08srRb1/2iGlUAuA4YFgq4BaMV/gw9+W
         yIVa83+A7ho8VogR03iNKz4XaD2iXH8XKh36bpiDj2k0Si9i8TvxZNQm8fuzQXA80L6v
         qgymt6IkMNVewGry5jmh/iDcexHE6yFuXfAOyMYh54Dx/dMYj9O3u7sQECEiM9TNLSP4
         nQbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Fmg2iGQ2QOU8aycVFt1PBF/LG/OCJFeJteK+WquArzs=;
        b=pTlpomUqPc9eVxfl4QJeToi1C2VcEOnfnAgm5+qmdGPobyWZar+kLjTUofKO3Bq85w
         i4ORt5ghMORlBGV5u/1ner6d7/TBbjqRoj+5aJILITcoT7zjtDIwWLqMfsl5F82LqFhJ
         7gB76jTFRkcRmkM/pHHhDnPftjac8RPCLXoSIlpr//lzooohcBRIhj8URf1iSW4KtxaZ
         NNgzWmbvx+qCkN5IR8KVAiwHy7XYPFK7Djq1tyanr/c2slsCNVCbLgttGzFl8h6v0KCT
         7VEVkBIhuanSebqtoE1o3yh+TMpkHvqXqLMl0fPcusPf0/Wj6diUn3h9FMmjV/F5TS08
         aQ2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x187si4372469wmb.33.2019.05.22.12.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 22 May 2019 12:43:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hTX93-00050n-IX; Wed, 22 May 2019 21:43:25 +0200
Date: Wed, 22 May 2019 21:43:24 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-ID: <20190522194322.5k52docwgp5zkdcj@linutronix.de>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-22 12:21:13 [-0700], Andrew Morton wrote:
> On Tue, 14 May 2019 17:29:55 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> > When get_user_pages*() is called with pages = NULL, the processing of
> > VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> > the pages.
> > 
> > If the pages in the requested range belong to a VMA that has userfaultfd
> > registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> > has populated the page, but for the gup pre-fault case there's no actual
> > retry and the caller will get no pages although they are present.
> > 
> > This issue was uncovered when running post-copy memory restore in CRIU
> > after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> > copy_fpstate_to_sigframe() fails").
> > 
> > After this change, the copying of FPU state to the sigframe switched from
> > copy_to_user() variants which caused a real page fault to get_user_pages()
> > with pages parameter set to NULL.
> 
> You're saying that argument buf_fx in copy_fpstate_to_sigframe() is NULL?

buf_fx is user stack pointer and it should not be NULL.

> If so was that expected by the (now cc'ed) developers of
> d9c9ce34ed5c8923 ("x86/fpu: Fault-in user stack if
> copy_fpstate_to_sigframe() fails")?
> 
> It seems rather odd.  copy_fpregs_to_sigframe() doesn't look like it's
> expecting a NULL argument.

exactly, this is not expected.

> Also, I wonder if copy_fpstate_to_sigframe() would be better using
> fault_in_pages_writeable() rather than get_user_pages_unlocked().  That
> seems like it operates at a more suitable level and I guess it will fix
> this issue also.

It looks, like fault_in_pages_writeable() would work. If this is the
recommendation from the MM department than I can switch to that.

> > In post-copy mode of CRIU, the destination memory is managed with
> > userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> > causes a crash of the restored process.
> > 
> > Making the pre-fault behavior of get_user_pages() the same as the "normal"
> > one fixes the issue.
> 
> Should this be backported into -stable trees?

Sebastian

