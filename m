Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93282C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 20:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3316C20675
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 20:57:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3316C20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D4236B0003; Mon, 15 Apr 2019 16:57:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 784CC6B0006; Mon, 15 Apr 2019 16:57:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 673046B0007; Mon, 15 Apr 2019 16:57:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCA76B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 16:57:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a3so12569051pfi.17
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:57:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3M8bZIC8MyqEUD3uOKT4j1Uipst1x3we1fAjoiOlPXg=;
        b=gzSPPrjC0QCKMCgobCOnW69DO/gDFppWAsK+Z2Xkgx1cGF04XB6eGsXg27wFnV1OIu
         PsYe/EzsFw6At2euIrL7OHck115K+asJEWhb0RWndHlIXgOqIoQZEfpDy1A/wYk1IhrV
         Ay/tzGoI+IY3uGZHhLNxJ7cxhABjmqdv3fVMQZM6eAWrG4n10XhbeLEFfzWMRBKehqTS
         YE2hv6vkNnTVfv6kKTLebksYmBwU0s8QMdowXsZLgHyPekQRMVb1hiFKddczlz24M7hg
         eV55BHCZrV6OQwN/EFUVlffeQwi1pXY72H1NHuxD232YcHW3g2BNstbJC05t1v9ETWrq
         z1Lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAW73TgzGdRQGjuOe+l820DbL3znBidCfsXAosQcaVXQEULGnFwx
	Tp39Dxnc4rS1DAALTXNz6eF48M6oohiL2GmC+FBFoWsb2KNCC7GgqdHEsABdeEp4D23lgV/cseb
	mXoDxoJ21w9KqE8kWJaMijPI0l8YSbmPZ/lYnA8HMOnhWpOc5UDMB82LxiSnTdUgvMg==
X-Received: by 2002:a63:7d0a:: with SMTP id y10mr65946772pgc.292.1555361831898;
        Mon, 15 Apr 2019 13:57:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIXb6QEA+jm5XbOK/wrZ1xBOj2nIXH6+uUkVWUWGzBab6zq8SDa+ap7LJqbVZ5TcHIj2cx
X-Received: by 2002:a63:7d0a:: with SMTP id y10mr65946706pgc.292.1555361830916;
        Mon, 15 Apr 2019 13:57:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555361830; cv=none;
        d=google.com; s=arc-20160816;
        b=Xd68UMPS0oOS8PkezTHeAm/a/UVMnE56SeMidWOCIezNxtEbuTYq6ZsGY9JPAKlIQQ
         o2TsYGiF/dm55seM9SyqzMrRAdwtVh47z3cDpzP4XzZo37bpTJUjIEmGOQ+Lam3dMDua
         hlWKBFJqOETancto7BX2z8nDxvUEYefUfhROGfnuSaaZ81kfBpMF7sbRE+9/aR1ECNM8
         YSE1f7POsKD5w0ravEeWldooItIGz1NTjNwD1eRm2HZOBcpLCgvJRXRicNTixHkZjmXG
         ZwRuI/tG3FthH5nQ/TbAK/nWPPlCtKn0ZP3LBBjbZNrG1a0qXaoofzg79spaUmDKIDjG
         ZXJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=3M8bZIC8MyqEUD3uOKT4j1Uipst1x3we1fAjoiOlPXg=;
        b=VUkpjvD8InQIwwq0kqK3wdMBHj26YEHSKKCXEJgnoNiEhi/qm3mgGi1e4nz39yYDiL
         nJjIw03UZV41X6OAsg2JSQoAUzxSE6MoQEfY8t5lHIe4xN5lr36l0boIrn7yP8ZSwu5H
         YVzl9tJKkjTgLNrnbTNq1vG/eDG4/pscTMnRcMRI5wT7yZp7VjH+dEkPc7j98dj8EGz9
         dB9+AO2Miecf/3XwKkfmv7gqP3Pb4J25BpAowwl6plDu+xjzZeex0bTGpMPMofRg4mcU
         kEnPiK+YN0wpuwvltsKfgze/juq84pv+ZDNy/Lcx03Fzz+m7BCB8PXXl+RSUppZZhdZ/
         f2LA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 5si31501124plc.425.2019.04.15.13.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 13:57:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 19A17CB2;
	Mon, 15 Apr 2019 20:57:10 +0000 (UTC)
Date: Mon, 15 Apr 2019 13:57:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Linux Memory
 Management List <linux-mm@kvack.org>, Waiman Long <longman@redhat.com>,
 Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [linux-next:master 6345/7161] ipc/util.c:226:13: note: in
 expansion of macro 'max'
Message-Id: <20190415135708.0dbc9e3ddb5afeb47bd52ce4@linux-foundation.org>
In-Reply-To: <e9dc2a8a-6e57-c57a-df1f-678794542d09@colorfullife.com>
References: <201904130252.Ws2iLv7w%lkp@intel.com>
	<e9dc2a8a-6e57-c57a-df1f-678794542d09@colorfullife.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Apr 2019 20:21:30 +0200 Manfred Spraul <manfred@colorfullife.com=
> wrote:

>=20
> With sysctl disabled, ipc_min_cycle is RADIX_TREE_MAP_SIZE, and this is
>=20
>  > include/linux/radix-tree.h:#define RADIX_TREE_MAP_SIZE=A0 (1UL <<=20
> RADIX_TREE_MAP_SHIFT)
>=20
> The checker behind max() is not smart enough to notice that=20
> RADIX_TREE_MAP_SIZE can be represented as int without an overflow.
>=20
>=20
> What is the right approach?
>=20

Make ipc_min_cycle have the same type in both cases?

--- a/ipc/util.h~ipc-do-cyclic-id-allocation-for-the-ipc-object-fix
+++ a/ipc/util.h
@@ -42,7 +42,7 @@ extern int ipc_min_cycle;
 #else /* CONFIG_SYSVIPC_SYSCTL */
=20
 #define ipc_mni			IPCMNI
-#define ipc_min_cycle		RADIX_TREE_MAP_SIZE
+#define ipc_min_cycle		((int)RADIX_TREE_MAP_SIZE)
 #define ipcmni_seq_shift()	IPCMNI_SHIFT
 #define IPCMNI_IDX_MASK		((1 << IPCMNI_SHIFT) - 1)
 #endif /* CONFIG_SYSVIPC_SYSCTL */
_

