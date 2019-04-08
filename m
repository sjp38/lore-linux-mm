Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ADA3C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 13:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45B572147A
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 13:17:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="tGMBSHPM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45B572147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5D566B0003; Mon,  8 Apr 2019 09:17:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6266B0005; Mon,  8 Apr 2019 09:17:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87EB6B0006; Mon,  8 Apr 2019 09:17:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F23B6B0003
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 09:17:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x23so4959001qka.19
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 06:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=dQ1SL9x4bZEYJy4r8vMymO8S+vKZHanfiXAqd5yNVlg=;
        b=mycPyuAnQGzkcFa2DCRd9VUbHamBULdC33Wr/Jr7gGnm7kmSmdz9R060w5Rx/PaAh8
         tQ1nz4/Drj4NSj/UyE9L0GN9hvHo3nWjaTi6ybgHB8r6d/fLcZyAMrtC923G49+Lolzl
         k/tunti0S+LnTsRt61/0JWB+FIAURGsYFU1Tflzvpn/OLr+bsD4vEpOpvGMCgwhWNrUw
         0Wrq0D7hllFUvtDnjWvyhaf5N0dEafbpqefGoXR7G+7o/eyy8R0YfB5XJZKYC0J5B425
         c+ffJrJ4km9ULhJwhb4Jx/1QyliHMywoB6jZfv2iO1PR48rdb89wLFd/SlNO4v84BDFD
         EM1g==
X-Gm-Message-State: APjAAAWYZ323LP1LhDOs69So+irf/aeD+EJo/r8AnpPheSR3+g7v138c
	+byHuqgCBuIFb+xipqdfbV+oan/RDOUiLYcx+2Tyj9TNnAAZQfgzwYfTXUltbgm8G/Zn/u+Da2g
	WCMHcpAG9sNwK5o4W3czKEXpStwzmpxXrm0dTtJkROrR011Rl4V3DsARIE5XSn0PHgA==
X-Received: by 2002:a37:9186:: with SMTP id t128mr21811004qkd.326.1554729458256;
        Mon, 08 Apr 2019 06:17:38 -0700 (PDT)
X-Received: by 2002:a37:9186:: with SMTP id t128mr21810945qkd.326.1554729457623;
        Mon, 08 Apr 2019 06:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554729457; cv=none;
        d=google.com; s=arc-20160816;
        b=ciCv544/8G30YE3ScZ/b0MIA9D8b2WCbFPgfFnmqrGaY7OK9Eh0M3VavYQ/zFeqWk6
         3KxPqcWvkafxj6ungp4uDN/mUagesfdG3adiKYtNU0HOlEnTHto5vlWdWBMyD5Ll9sB1
         ibQMmndxqOm3Vcnq80vn914yj30psMwEbtGjex9fzdLLRgkvEAn+4Jr7ZbTqKw7r6h/x
         BCCzbS03pEMJ5H632E/qczS2a5XPqhg4A4IBzXUOuav+9RXfvJfu9epd0xgVkxHTzG0P
         LR/4hmhK6tJEg99HviJghlIacagMsDuW4Fum1iqrhdhupq7t4wfkCVsOj+vjbRh0QSzs
         akWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=dQ1SL9x4bZEYJy4r8vMymO8S+vKZHanfiXAqd5yNVlg=;
        b=HUB/hosKpE+0CTbxcDiOPLqY9ixdWTYWrOXB3AVpYRUWBys9NZNsHLuXjHNIPyqByv
         IpJii0oiNLaozvXcuHX1p2I4GAJTLtApB8D/pZklEH945K5mQEqVV4fkA4Suo5MxuNUD
         u/+h63xOc8WlCivtkc2dDr/SY6NgbL1i6/CUCLplbtp3VMYRxGuhmU3TbNp/pEtYfXfc
         bgC206pSNtlIdcYO3LZO172zNsGQPN5HJ2tc5tZJlWKiQ3oNGubqUejMzUk7WLnYQ2tH
         FxqlfhdqhHnvUOdCxdkhHg84ROLY6asexAcTzotlM5hBDzyvMVuLDvsAPEt2xlb3eCMm
         mMxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=tGMBSHPM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor29731490qvr.51.2019.04.08.06.17.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 06:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=tGMBSHPM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dQ1SL9x4bZEYJy4r8vMymO8S+vKZHanfiXAqd5yNVlg=;
        b=tGMBSHPMKldELijf7ebfUlxeeTeLrmGlAS+GT3x9k22hlFNOefudwLsOJx77cQ2zsU
         XC11xSxJvWxx/g+DvPTqp/8G4WASzymHnVaKllfPqqBmWkVewDkjRg7EUAwQ4BwMEnek
         C1qXrzW/ZIiP6VHcqJYgvhz1eim3v/0aGSLlNPyaN70cNdNdVJVZNAJnvr4nF06KISIM
         ScDscYVVw3QXzS7iMbLH7H38VkMo9hrotMWyQ0B16321feot7yXACtuM/YU6ounkokuP
         g5OGfx0I6eoOMS4dx9aOxSKDB1VWlkwNFdd3gzGRv3+7OkgRtm4tC1OHjeNCcPWX/Iql
         rfqQ==
X-Google-Smtp-Source: APXvYqzU6+z7q49B2XOUsT4HgLpoMZS9GA5y3qCYOAPVfjWmMVH1tX1HnUyjNK8X3E6L7g4zrk5qEw==
X-Received: by 2002:a0c:b78f:: with SMTP id l15mr23189216qve.160.1554729457052;
        Mon, 08 Apr 2019 06:17:37 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n70sm19984226qkn.5.2019.04.08.06.17.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 06:17:36 -0700 (PDT)
Message-ID: <1554729454.26196.44.camel@lca.pw>
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
From: Qian Cai <cai@lca.pw>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter
 <cl@linux.com>,  penberg@kernel.org, David Rientjes <rientjes@google.com>,
 iamjoonsoo.kim@lge.com,  Tejun Heo <tj@kernel.org>, Linux-MM
 <linux-mm@kvack.org>, Linux List Kernel Mailing
 <linux-kernel@vger.kernel.org>
Date: Mon, 08 Apr 2019 09:17:34 -0400
In-Reply-To: <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
References: <20190406225901.35465-1-cai@lca.pw>
	 <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2019-04-07 at 19:35 -1000, Linus Torvalds wrote:
> On Sat, Apr 6, 2019 at 12:59 PM Qian Cai <cai@lca.pw> wrote:
> > 
> > The commit 510ded33e075 ("slab: implement slab_root_caches list")
> > changes the name of the list node within "struct kmem_cache" from
> > "list" to "root_caches_node", but leaks_show() still use the "list"
> > which causes a crash when reading /proc/slab_allocators.
> 
> The patch does seem to be correct, and I have applied it.
> 
> However, it does strike me that apparently this wasn't caught for two
> years. Which makes me wonder whether we should (once again) discuss
> just removing SLAB entirely, or at least removing the
> /proc/slab_allocators file. Apparently it has never been used in the
> last two years. At some point a "this can't have worked if  anybody
> ever tried to use it" situation means that the code should likely be
> excised.
> 
> Qian, how did you end up noticing and debugging this?

There are some nice texts for CONFIG_SLAB Kconfig written in 2007,

"The regular slab allocator that is established and known to work well in all
environments."

"tricked" me into enabling it in a debug kernel for running testing where LTP
proc01 test case (read all files in procfs) would usually trigger the crash
(Sometimes, "cat /proc/slab_allocators" would just end up printing nothing).

Normally, all those debug kernels would use CONFIG_KASAN which would set
CONFIG_DEBUG_SLAB=n. However, there is no KASAN for powerpc yet, so it selects
CONFIG_DEBUG_SLAB=y there, and then the testing found the issue.

