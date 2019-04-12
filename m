Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 063A5C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9752320850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9752320850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECB566B000C; Fri, 12 Apr 2019 12:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79C26B000D; Fri, 12 Apr 2019 12:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D90066B0010; Fri, 12 Apr 2019 12:50:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B74386B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:50:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so9340330qtc.1
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 09:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:in-reply-to:references:to:cc:subject:mime-version:content-id
         :date:message-id;
        bh=oNaOnJP5Pkva+H57ZtsndfrIrh/zoUcpLiQPmhV5R9g=;
        b=NU2pQfool/vT7eqhRzhKjXquzWj0qjFmo0Q66p2dqmEc3Is6r1xPATVfJ0ds3p1ygo
         L6wo9Ouajlk0+kSVJxB2HO6ptT0v+45p2rdw5ntMUZ7UvVkQk/vnjAZwgxRFWqiV73b9
         oW3QmLuRaYrGDwtjOx0261rlXDwYXERXY6TaDzyR7OElj0ICC2iZW/Ttp3rOII6FPWDv
         Tkbv2JIbDU6pXXAdZ1BmPGnavF5OMQI2Rvv+HI8J+Us4Zk/vRnfjxkDOHKFpDBcCHoXL
         LFOn8u3M86YLBR9m03XPNSOZWsDkf1FFKIVTdY9nRFrGYHjeVHWgOHcJCdKw9SFcVykj
         a5zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUg2jET0cSVX7E+5CRtnvha/LaO1W2rCEdMbix/6LiokXSmHIBR
	nkbTVBS+aoJZIhFeSFbdg5CRnicwSTtxao+14efWp1RWe+G+kPybJKA/3YF0F4DS/VHQDfLboLF
	wR+j3ZMVGmLmLer7k5hDhr2m/qC/QE/Upuqv6gNmYxYmcqTk6T0X/bskbVWlIm7xF1g==
X-Received: by 2002:ac8:247c:: with SMTP id d57mr2821407qtd.308.1555087835507;
        Fri, 12 Apr 2019 09:50:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeiV+IM4JivgyE1LocZSTkvaUun4Amjf2jDruxxxmHDxIiD3uiKGpwOjIkW/IZHX6V/Uya
X-Received: by 2002:ac8:247c:: with SMTP id d57mr2821355qtd.308.1555087834666;
        Fri, 12 Apr 2019 09:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555087834; cv=none;
        d=google.com; s=arc-20160816;
        b=meJbA7ZL8JOFd/OfA9YzhxY36VqsTiujJfstST7XCvBzbPCrK1fYTHgOxNA5x1Oeks
         VXP5xEdQ2cPU4IYypQ+H1FH2R3gfnrjYwXtQLUjyFUuMi5gkZstNDpHpRDzXwASQbU5X
         +xcUpU1uGJohJvXVDlD6C4vb1ACNsMtKR3picWzKMmk1eeRIZcK+GdUXtuAO32ZPqsVW
         gtd+QmqYQ8Q9UFWH4h8oRDtsNFE1knfl4mTIBmhCDrHk0XQ5Hi1vQXHH7CrfSGu1RyH8
         bz5/TEtSW9AssqydH7xYBo41cz9bBupxUwFR25aZtIvCj+phGE3wBFOEoLy/af/w5TdJ
         eiyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:subject:cc:to:references
         :in-reply-to:from:organization;
        bh=oNaOnJP5Pkva+H57ZtsndfrIrh/zoUcpLiQPmhV5R9g=;
        b=jf+Gu6yGtOGGLxGwnSsD6LZcc1uA8mit6L8YRfwAThvLxrmQoezsgDBLTbaOVB0Xla
         JfmirWnmXlC6/8a4G9zCNqgH6Fh2aqKdxGNZawC+HN9KVgxWCPOp1bP5gkH56FGHLi9R
         CYhxbvOMOD3Xk5Y+CMqXtT0SWXRMK9z+VI1VVORlX4qw1b8Y+HojPC54v724BJc9PmXs
         B9Vv6oov8lD0WxhEUYGGV2dO1Cy+RhYXn4+mBgqPt7K3HetHigV3vM+MJQz9up5nUUY+
         psx2VKt2cqC3w/Q+i4Yy6RL6rQcYUEliCg9AH6JSqwRV10LLbEij8tnMsqlpfH8jw0KQ
         qSIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f25si2549496qta.270.2019.04.12.09.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 09:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9822D330255;
	Fri, 12 Apr 2019 16:50:33 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4875E60BEC;
	Fri, 12 Apr 2019 16:50:31 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAHk-=wieBr3G=_ZGoCndi8XnuG1wtkedaGqkWB+=AVq65=_8sQ@mail.gmail.com>
References: <CAHk-=wieBr3G=_ZGoCndi8XnuG1wtkedaGqkWB+=AVq65=_8sQ@mail.gmail.com> <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com> <20190411193906.GA12232@hirez.programming.kicks-ass.net> <20190411195424.GL14281@hirez.programming.kicks-ass.net> <20190411211348.GA8451@worktop.programming.kicks-ass.net> <20190412105633.GM14281@hirez.programming.kicks-ass.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, Peter Zijlstra <peterz@infradead.org>,
    kernel test robot <lkp@intel.com>, LKP <lkp@01.org>,
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
    Linux-MM <linux-mm@kvack.org>,
    linux-arch <linux-arch@vger.kernel.org>,
    Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
    Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@kernel.org>,
    Nadav Amit <namit@vmware.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"): BUG: KASAN: stack-out-of-bounds in __change_page_attr_set_clr
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5889.1555087830.1@warthog.procyon.org.uk>
Date: Fri, 12 Apr 2019 17:50:30 +0100
Message-ID: <5890.1555087830@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 12 Apr 2019 16:50:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> We should never have stack alignment bigger than 16 bytes.  And
> preferably not even that.

At least one arch I know of (FRV) had instructions that could atomically
load/store register pairs or register quads, but they had to be pair- or
quad-aligned (ie. 8- or 16-byte), which made for more efficient code if you
could use them.

I don't know whether any arch we currently support has features like this (I
know some have multi-reg load/stores, but they seem to require only
word-alignment).

David

