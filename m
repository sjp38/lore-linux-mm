Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 421A1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 08:54:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6ADE2147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 08:54:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aL+PUDHq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6ADE2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21FA58E0003; Tue, 19 Feb 2019 03:54:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CD938E0002; Tue, 19 Feb 2019 03:54:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E6038E0003; Tue, 19 Feb 2019 03:54:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95F7F8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 03:54:53 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id c7so3519551ljj.12
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:54:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ltSsvdHNdb4GdapXqP6mMOHT1V5X/HLtl9h4j3f+Akk=;
        b=UTtMfzYh7bvjnr3bh/sbcRxDLR/Kfod/Nyiqizu4UZFWz712pD1P3TTqMRYeAroOR/
         7adVRS2DoELY0sILTl7gICsLoPQ9wgBGrWDb5gVc8d2lUVtEBsqg9y10mXhVoo7DpXL6
         /0pN9CJaC9OK1B46DX+8RpoP7kxZfPGBHBhlW/bQvWe9Rf7lD5G5RR0+hiaTYm7DhR1A
         CkpFpkraH6qXLJJPm0CyRza7hG68GGpngGmER6CDSmSN5+0GWLdFRfadeRUyYyQf3iDG
         AVsdzrU07HLL41qIMDADV/b6aDkR80Y7mGj0HOHTkhsCJmc1IyQpwlpB/dFiycsa3kPJ
         bbcw==
X-Gm-Message-State: AHQUAuYbQRLZfwMtvBBAys/sJGAx4Ham8dCJDcINRtRksO3gPILDIeQy
	/QCyM4OlkfrRW1+VVHk02CehtvEbZtj9Mpc7CIdOG4eu7fOBkSUx4Weu/ysH/1ppK+TNy5GcC5N
	W1x2IJhMdLaMWqzmZwkPM69pwiyDKUnY+GSqE/sgLdXR3MTyMbZXlsnE4zw81JGTeg7eX8jBpYU
	pMeMpovMSGSnk5hhGeV5Fvmvg1YkjKtwG9ifGFAFUVCPSKhXwRujS6DSo4cFWthNcXhgtk7Oc87
	9hcGJx6w5YhJpCGWGWyIGZWyhCaUtoCSN9+ElqCN3B10ccWFq9rAsaGbBawcR3cdFXJSXgemSzm
	TOgY8adZsix3EVD1rkKmCq54OjSHABA5D1GGmDRB7LTlXBJmAPO9q7C3cYZ7dE2tjfGowhDy5+t
	F
X-Received: by 2002:ac2:5104:: with SMTP id q4mr17081860lfb.59.1550566492653;
        Tue, 19 Feb 2019 00:54:52 -0800 (PST)
X-Received: by 2002:ac2:5104:: with SMTP id q4mr17081788lfb.59.1550566490893;
        Tue, 19 Feb 2019 00:54:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550566490; cv=none;
        d=google.com; s=arc-20160816;
        b=sholAajLEVSEZMzlWf0z+Qh/qYJofypSwdFZmcuWPYYFPG8K2LsSbyJMkXbEKkccMM
         Qa91iJl/GgqJSO+0civlqFmhgN6gGP7B/EkdebhCapwTR2Zuf6eXIVKUrPrAJx91M3VS
         EFtAwrWQcnkbhuhppwKZiJUFuvWMzDEM9g2j8ScO6qK9oaH3GRJQLjO7pbl6fRp9H9z+
         PSAS21lJK06k1hj03cci5n3uqIIjsQl0FcVC5wXsjKuGD1jGqlgoT0XcMgDllJFVbur2
         AziR/XhG0cx7Hw5KgvirBQtqZfzfhMKXUPKQwiLEwHU+QkU/z2VvBOuwWflf5Hk99VlQ
         PU8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=ltSsvdHNdb4GdapXqP6mMOHT1V5X/HLtl9h4j3f+Akk=;
        b=SASwSoZ81S6+A+zEc6tvZHIgf60vRibdRW2urWLp+rkXXCY55b7r3a/MqyZyBSZ8Nb
         zkuLnmdIhXVQufWi28htA8MNlEk1H4lrVzexEe4Dbmzx4H5ivvhj3JpfXwYi8S6c0466
         avJZEzDXjYguKymToacxsSbDTCtWZm2HTAbixsVpTJwSHF7B14jdRmf1QpIHncF/cZMK
         3M15xGsz752UpvdtydtQD6bsR2Lwwq6/I/DjWddBYgprW+zGtoy/fCIPjPMhuaZ8Ei5i
         ChajiOupaAAG5aRpWUsHrMbA4O+6xf7Ov07OrE8Ezwwn6MUY0EkwoDhRerLetTuqKXL8
         zVFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aL+PUDHq;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22-v6sor8914184lji.38.2019.02.19.00.54.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 00:54:50 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aL+PUDHq;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ltSsvdHNdb4GdapXqP6mMOHT1V5X/HLtl9h4j3f+Akk=;
        b=aL+PUDHq6A8d0AHkzcczbedJtyBOfogKBz6UHPiZ9rftC/TSIrGUQXemnCOSGvqcNG
         9ipQ7270YN5ZMXCYZ+XAF8iCrbHoOm5TcHEmDB09pmPEqfFgHjhiFLID5Em1wHL6UBpW
         KO3BVMZbcaogI0gutigrACvY/DJWlX69P0A+SiGZWgKbmscHckGqOD0loe0pMCfrElPN
         1ivpoCFm50zvSGfEU4aWxdu4l34OefgJj+JX5PCfboB/dd34msxfwbO92PxuunzPjIDd
         Q1Q0PDFgyjJvwNMD8gnXxdZ13xh6Y5kRf8EHGUO0179CyoxEW/3IlXw9ng2Pg6o73VbE
         LJ4w==
X-Google-Smtp-Source: AHgI3IaFMjULRa32ItT5zgTo4njrPEabvQQKVTfuPUZW9epciCB+wuwK9Zcs1U4XLAr+eGdzm68XOQ==
X-Received: by 2002:a2e:96c9:: with SMTP id d9mr15766759ljj.133.1550566490211;
        Tue, 19 Feb 2019 00:54:50 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z85sm4231730lff.80.2019.02.19.00.54.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 00:54:49 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 19 Feb 2019 09:54:41 +0100
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 8475/9410] ERROR: "__vmalloc_node_range"
 [lib/test_vmalloc.ko] undefined!
Message-ID: <20190219085441.s6bg2gpy4esny5vw@pc636>
References: <201902190637.nP67rDcw%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902190637.nP67rDcw%fengguang.wu@intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Andrew.

On Tue, Feb 19, 2019 at 06:04:38AM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   cb916fc5eabf8832e05f73c246eb467259846ef0
> commit: bd7e49fa421950084fff786200b7fd6872d51643 [8475/9410] vmalloc: add test driver to analyse vmalloc allocator
> config: h8300-allyesconfig (attached as .config)
> compiler: h8300-linux-gcc (GCC) 8.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout bd7e49fa421950084fff786200b7fd6872d51643
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.2.0 make.cross ARCH=h8300 
> 
> All errors (new ones prefixed by >>):
> 
>    ERROR: "__divdi3" [lib/test_vmalloc.ko] undefined!
> >> ERROR: "__vmalloc_node_range" [lib/test_vmalloc.ko] undefined!
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
Could you please apply below patch to fix the error?

From f6ac7bddfc5969b0982ddf52ab248a1abb0b90a8 Mon Sep 17 00:00:00 2001
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Date: Tue, 19 Feb 2019 09:47:51 +0100
Subject: [PATCH] lib/Kconfig.debug: make CONFIG_TEST_VMALLOC depends on
 CONFIG_MMU

The vmalloc test driver can not be used on no-MMU systems. Add that
dependency to prevent the driver to be compiled on such systems.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 lib/Kconfig.debug | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 960ba0cb58c4..618c3ee466e6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1913,6 +1913,7 @@ config TEST_LKM
 config TEST_VMALLOC
        tristate "Test module for stress/performance analysis of vmalloc allocator"
        default n
+       depends on MMU
        depends on m
        help
          This builds the "test_vmalloc" module that should be used for
-- 
2.11.0

Sorry for inconvenience.

--
Vlad Rezki

