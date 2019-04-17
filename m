Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4DFAC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:15:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5130420674
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:15:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nyS/WVic"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5130420674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D07896B0005; Wed, 17 Apr 2019 12:15:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE806B0006; Wed, 17 Apr 2019 12:15:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA5F66B0007; Wed, 17 Apr 2019 12:15:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69B9B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:15:28 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b16so22633946wrq.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:15:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2E2gGWXwlEXHD0EdhjliuzLa0L4LUy3dnmNjJuBPY1M=;
        b=KyyYUYOf5bgW2W2QrqqvB1RKjF7cgcV9OXu0wR0ZjVASqh49jQCQoOJDo8x1vivhfN
         oK40PGoU8z3d5NnbRjFUMt6Y19uECrgijLTb9K62j/Uk3XDqh5NaEMJ7EV6lIB6JoG4q
         2kKf6uTGEBEw34SA1Pi4d06e5BFoyscQuKE+fqKogVmcDmuo4CPEXQrBYBDp8fFuBGoa
         kJSP+VgB2px5Blz9Yv5QTMlEVkKrwk8MrDs5qtz4GjZEPgVKfFEw+8qPU/702NTm1rM4
         m4RFyLrH5AVBoKM+QzOP1ZsbuS9q3D0EN0JZkcPB1Mtua0qqfrlb/nkimkqNX/C5pB69
         DjIQ==
X-Gm-Message-State: APjAAAWeeT30whkYlQKP98RLBzM1zTWybQ26lIeBDYPe4HLCDRdGbHh6
	4tOU3pQO9v0HQa76BNVEWY6k+lft51l7hY6nvqdP+EA3fNo1HxN21/uPT3JyOJpUqwwyjKwP0+n
	s9euvTNi6DOrveGHbYg5fcTXThsQdtjSlBaNVCP8G6Q5VanFsm6enrP6W1jggyeg=
X-Received: by 2002:a5d:4751:: with SMTP id o17mr57808297wrs.121.1555517727995;
        Wed, 17 Apr 2019 09:15:27 -0700 (PDT)
X-Received: by 2002:a5d:4751:: with SMTP id o17mr57808249wrs.121.1555517727170;
        Wed, 17 Apr 2019 09:15:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555517727; cv=none;
        d=google.com; s=arc-20160816;
        b=e9qgb6F4UXZddPZzJHahcrVpFQrSYkfLjX387mni+Rr/01enyq2GdM8n4aLfzA4z1A
         Vf/OxUmfm0/JnjgKl8vN74SbrUG+6cMWnt3OqqEvtGoZr9kMK7xQezZuVis0PTPW9pBG
         3HDwXWVc+c2eAOe4CqUHP6OoQblqfSiKsrGWYaC8TxDJr08fmzoC5shG/TdHmNWUJFT1
         xiAcmJga6moGkR8x25uSpDIldNDzFUdFtsLPR6ucO8O9DfvaoQ+XLUfkvWil7hTe01qI
         S1nLlONRguyS38ZakelNe4ccs3OH9wWLumqjub/1PpF79YbxIMSmaymfxCLD3Yec4bV+
         N3gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=2E2gGWXwlEXHD0EdhjliuzLa0L4LUy3dnmNjJuBPY1M=;
        b=fVxGDE6+DHflEmayxiY4FTkZ9ULkcMj2RLtq71fK/XImgb95m0nSWpXKmRKMd3TBgm
         x3befKM83+dyjyAu/bW9y+8hWZINjBbrMnvMmErVheZDEgBBDnCuDLAFOjssEOb/tVbf
         l19mKa8GcddmeXlqMK9tBKL6168j3gk5TaSs/EPxcbgYv8O55uXZRoqeuvy9RNXzlAqa
         OZsb6Xlz7DABSnpCTGAMGNqHzKUttHQdkdTWUNLgsv7p6vFpFXo7+wB3CJlDnbfPyT3E
         gtN3av1zzflBbqYPz3ZD8l9CXRSCOxHEKbS2QR/HbRV050+4tPa6jsXnegAOPmxDyPGt
         kMiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nyS/WVic";
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor95475wrp.14.2019.04.17.09.15.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 09:15:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nyS/WVic";
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2E2gGWXwlEXHD0EdhjliuzLa0L4LUy3dnmNjJuBPY1M=;
        b=nyS/WViclzZJjR30HVMMB/ma7fcLYSTWP9QxF2Fshf4EJq6uRarq3jSaxiVNfV92fh
         zEZfmA69o8F7gNO5JT6uv0zE0OJeE7BWbIRv09fAQTN2l+N2dnFwJ9Lfuiiy6+74FoDp
         uGRo9f5/Goa9H9R9Ca2oLvyjv31O0I5e5WLdLO3tmvoyjg1wNvw+8b2zxVEfd9gJSTwJ
         +SSg2n/omewPli8xLPnvSElOhwgHU9I/P33Tw7RfhZ2LRLr+x5PTn04fXGfMHG1ZHR4/
         XB7f4UjQbIdtenugCUJSD8W8ywk7H6JVByBN8MjE8ZURVuqLb51s1gVwQaBsfh/AY/u/
         6ICw==
X-Google-Smtp-Source: APXvYqy35ID2kalnRZopmGnEWCBLThqKczYiLY/rC35gAIxUEa+THgEb4y2voVmHavCnFbNEpnRFQQ==
X-Received: by 2002:adf:dbce:: with SMTP id e14mr59140093wrj.249.1555517726742;
        Wed, 17 Apr 2019 09:15:26 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id y1sm154976060wrd.34.2019.04.17.09.15.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 09:15:25 -0700 (PDT)
Date: Wed, 17 Apr 2019 18:15:22 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	keescook@google.com, konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190417161042.GA43453@gmail.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


[ Sorry, had to trim the Cc: list from hell. Tried to keep all the 
  mailing lists and all x86 developers. ]

* Khalid Aziz <khalid.aziz@oracle.com> wrote:

> From: Juerg Haefliger <juerg.haefliger@canonical.com>
> 
> This patch adds basic support infrastructure for XPFO which protects 
> against 'ret2dir' kernel attacks. The basic idea is to enforce 
> exclusive ownership of page frames by either the kernel or userspace, 
> unless explicitly requested by the kernel. Whenever a page destined for 
> userspace is allocated, it is unmapped from physmap (the kernel's page 
> table). When such a page is reclaimed from userspace, it is mapped back 
> to physmap. Individual architectures can enable full XPFO support using 
> this infrastructure by supplying architecture specific pieces.

I have a higher level, meta question:

Is there any updated analysis outlining why this XPFO overhead would be 
required on x86-64 kernels running on SMAP/SMEP CPUs which should be all 
recent Intel and AMD CPUs, and with kernel that mark all direct kernel 
mappings as non-executable - which should be all reasonably modern 
kernels later than v4.0 or so?

I.e. the original motivation of the XPFO patches was to prevent execution 
of direct kernel mappings. Is this motivation still present if those 
mappings are non-executable?

(Sorry if this has been asked and answered in previous discussions.)

Thanks,

	Ingo

