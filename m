Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64079C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 21:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 109A420823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 21:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lb8HwWNG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 109A420823
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99BEA8E005E; Mon,  4 Feb 2019 16:37:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94B2F8E001C; Mon,  4 Feb 2019 16:37:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 860648E005E; Mon,  4 Feb 2019 16:37:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45DE08E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 16:37:11 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so849623plb.1
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 13:37:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=Dic7IWoaVvn5yE0p8pv7TgQLnMU5uq2/jKAUkywWc04=;
        b=PvCRn+h9yYQBA7gmC+txXuwqbW3qF2x4cwuDmpYVqZFr/InO0myWiaXdNbemO5lr1P
         0fMR4bNvfMojXC9pBEjrr0JqFZp/FAkw5sVzivdxJ83bhsNrixS1WBHhCiS8ad2pXcNm
         D8LYwvPrqsSl6RIf0JXgm570S55KK/94dOiEz/zZu4I8bpi/OxkTHO9xhXmsDqU2pRBc
         KLD4sEH8UzBBPGU6CXXlZMESNsV2V3IKqPjOL6BJ6/tBrwXMnMWIphh95fgtEIu+La68
         rWNrSdiXC6AINu0PH26BmVN05hdAHAsH76pvatuA8UXE0agoVdGHP2qbW126ju7hoahF
         Ps6w==
X-Gm-Message-State: AHQUAuaoxatB72ohplyGlAc2guUNrvVSekzVuvkM/DcSaTx5XfgtPjmW
	6KRYvbGAy47MOkegX1SgcXzvrpNTqNq+5SZVuWWhylxam0XKTN/TlpNwXrkQ9E7id4ArMf6Lw6F
	TsKg79cxydf+ON1GPUoC/HwhI9pQiMDUr0GslmPcBHfOw7H+JNQfWQBG4/Wn64NgHRF8/vleYZQ
	G2AQtmMgEo05RDIbm0wnGFuJyfTbeGxBb6pgQIitS2PvdS7G/z4SISLs9hF0nEGXbJ5syBk3baI
	LYcXyhzzs7432qVjcsT65qzZXGPrDjyY6OgWdfM8Zm1pMDaAhMbFAmccLJkStM+CQbqdOrHnUMw
	tdDHWAneHad8II8n8fSzH9NN8GBqjioMVTcDNBAhXJ+53S/bpQUvhQDaU+GVUxRRpMb2bkGVuMZ
	Z
X-Received: by 2002:a63:68c4:: with SMTP id d187mr1333572pgc.11.1549316230837;
        Mon, 04 Feb 2019 13:37:10 -0800 (PST)
X-Received: by 2002:a63:68c4:: with SMTP id d187mr1333524pgc.11.1549316230009;
        Mon, 04 Feb 2019 13:37:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549316230; cv=none;
        d=google.com; s=arc-20160816;
        b=Qb8NOruReMiIpbL1CKbP3AqUfhEZNPi2dVVnYK6vr5hCc8LDgwCug6TkPufdaXPiTh
         q5FpjENrzo1vZ/TfxVQbaYpnf1xxWckzbySXicxuM07b1qNYkGCpH5b3GG+JwkF+ytED
         JHxVwTNAQBYVotnZosNHS8SjN7Eani97VzIbYAPPnBf0U8j9ebWvU1BlUZGS1A2WjomT
         oklrH74VX9IhbB+pZItkSMkHUNFsBWjAeer/tQuXF266jMCPB34bvpGyvne/deXLZ7/p
         izmL0D/czTX11bTd4cw6hVbjVJaFJ6br14EPYETTiArfEV0rkr3AGwGk3cosu43BDwV7
         1jyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=Dic7IWoaVvn5yE0p8pv7TgQLnMU5uq2/jKAUkywWc04=;
        b=jyTWPvHu/nYnLYcMRUP5ey5So8qtPKWUNfSyBXCCk1g2ERY/F1XflE6KRbaq3LUhgG
         d+KrSI+GJVuwHAi5XIHSVspXNcvJJqtk4jZClTnTsATJyn2Oea6fUwNrUFd5wdFKJgrH
         9oMZntn3NCRpT8vZSh59ONm1myx738CsMltt5SwXDyGLXrpZOTa96zVBEwOEJ1iRFY27
         nYTb9Hy9VNgrr1nICQwTsqaANLpMloSKIULe4j1Irt2XWRNXnaa8oDYW34dZq6L51zXE
         nQWfpnKs012FG1ls2HysximVRhb+AWleORHCEUGxZE7pbuogmKigozEF7n5wAZuLeKVX
         s+Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lb8HwWNG;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u67sor2001345pgc.55.2019.02.04.13.37.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 13:37:10 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lb8HwWNG;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=Dic7IWoaVvn5yE0p8pv7TgQLnMU5uq2/jKAUkywWc04=;
        b=lb8HwWNGugEbhyHCedSwvZpJ215sVVPiStce4PR41K0APztq2alOI7x6D7vlVsnFfs
         3/OW92Fh5XOFJ/3jIzYFDBpMj7b0qgRK4ZiKDhTdMamayDAa53BdJWYjv7+5xobQzw6t
         q6LL0Al8BvrO5iTFi358y5M38jsokLI4aGMQkQ3wk9p/FDYmw5lHAEcTriigsOJpjaZ4
         H0DCYNBSrz+tsNEa3CE/swzKU46tqVe9ETzZyjwDN3oQfgs3VYVYE2puirHyKyIdFuTn
         e0eQ0DtnEnRLjzDxJXlpqr4+O6xh5wzd/SDIsi6a6GozuDrnyTOf39OuIFVOuImzXbuP
         KNJw==
X-Google-Smtp-Source: AHgI3IbSEm8P9RgNeh0FNyjNrnd9pmVtCxHW0XAbQECkBVcmG22Z4FeguS5VSaS2Qah21d3noZw9gg==
X-Received: by 2002:a63:fb15:: with SMTP id o21mr1322623pgh.211.1549316228551;
        Mon, 04 Feb 2019 13:37:08 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id u123sm1858577pfb.1.2019.02.04.13.37.06
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 13:37:07 -0800 (PST)
Date: Mon, 4 Feb 2019 13:37:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: "Huang, Ying" <ying.huang@intel.com>, 
    Daniel Jordan <daniel.m.jordan@oracle.com>, dan.carpenter@oracle.com, 
    andrea.parri@amarulasolutions.com, dave.hansen@linux.intel.com, 
    sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org, ak@linux.intel.com, 
    linux-mm@kvack.org, kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com, 
    stern@rowland.harvard.edu, peterz@infradead.org, willy@infradead.org, 
    will.deacon@arm.com, hughd@google.com
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds
 check swap_info accesses to avoid NULL derefs)
In-Reply-To: <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com> <20190115002305.15402-1-daniel.m.jordan@oracle.com> <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org> <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
 <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Andrew Morton wrote:
> On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> > Andrew Morton <akpm@linux-foundation.org> writes:
> > > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> > > stuck so can you please redo this against mainline?
> > 
> > Allow me to be off topic, this patch has been in mm tree for quite some
> > time, what can I do to help this be merged upstream?

Wow, yes, it's about a year old.

> 
> I have no evidence that it has been reviewed, for a start.  I've asked
> Hugh to look at it.

I tried at the weekend.  Usual story: I don't like it at all, the
ever-increasing complexity there, but certainly understand the need
for that fix, and have not managed to think up anything better -
and now I need to switch away, sorry.

The multiple dynamically allocated and freed swapper address spaces
have indeed broken what used to make it safe.  If those imaginary
address spaces did not have to be virtually contiguous, I'd say
cache them and reuse them, instead of freeing.  But I don't see
how to do that as it stands.

find_get_page(swapper_address_space(entry), swp_offset(entry)) has
become an unsafe construct, where it used to be safe against corrupted
page tables.  Maybe we don't care so much about crashing on corrupted
page tables nowadays (I haven't heard recent complaints), and I think
Huang is correct that lookup_swap_cache() and __read_swap_cache_async()
happen to be the only instances that need to be guarded against swapoff
(the others are working with page table locked).

The array of arrays of swapper spaces is all just to get a separate
lock for separate extents of the swapfile: I wonder whether Matthew has
anything in mind for that in XArray (I think Peter once got it working
in radix-tree, but the overhead not so good).

(I was originally horrified by the stop_machine() added in swapon and
swapoff, but perhaps I'm remembering a distant past of really stopping
the machine: stop_machine() today looked reasonable, something to avoid
generally like lru_add_drain_all(), but not as shameful as I thought.)

Hugh

