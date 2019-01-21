Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42177C37120
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC3ED2089F
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:53:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Q+BjbpDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC3ED2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 880528E0004; Mon, 21 Jan 2019 16:53:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82EC48E0001; Mon, 21 Jan 2019 16:53:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71F898E0004; Mon, 21 Jan 2019 16:53:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 500F38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:53:25 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id p79so20469494qki.15
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:53:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=DcXpbnSbvxIdmq741qppTsLN32m9f2v4cydbcvErAV0=;
        b=OW+9SHSJe4NjzMMaPs9uB/4nXgeGZWy39ugjYMZlVRvIBWuMS+vlLNT31ISMTZXTXp
         IDjmQklt6ENGUotzPB8o67BbPkyrvmq4NeBrLlfGF7cD30vDAtis8jdRiT0JzTu5VkUP
         BPzN06fKyKXy7kxnPlRmHwT07GhSlBM6gipLhf4u/lmscEbKg4x0dyoSqLO/AAK2Aswf
         A6sMmH33LKKnZIMOJxoJHHxipi5IvZBl1WS5+47iRe/+XfOpGExF4Ud/z82xAqAENjaj
         bIl5l8O8Tw+SrrktlvXfGYhL1qIvcMhMbuhnTMIX3CYlEL+gqeun7bBjdxzi3nKrQX2V
         Ly+Q==
X-Gm-Message-State: AJcUukc4rsPHhNcjQj6Ak3B3uUcpL96RvgHNzKI8UZZCkgOF0MP/pSRQ
	veAhk6LcbgBcjsbuKXe6dy6M8UKmU4dLKiS1tFkWE1l2UeWzOsJX4jU7sSXz6YMzCLS4yNXlKAw
	I8mi/vhn5GSwmbOPgPjLAJ5cIiUlD3XfiueXBE9v4Hxet5i+0iwlNQRfIsiSEW5k=
X-Received: by 2002:a0c:9a4a:: with SMTP id q10mr26724677qvd.150.1548107605134;
        Mon, 21 Jan 2019 13:53:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5NoN7NLfYSBFL/zIpaTARLCnPVeXPrqOITLqViu/KlHjXTF575sg8J640NOPVlU4YCRPlb
X-Received: by 2002:a0c:9a4a:: with SMTP id q10mr26724661qvd.150.1548107604724;
        Mon, 21 Jan 2019 13:53:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548107604; cv=none;
        d=google.com; s=arc-20160816;
        b=t3DSxdFPFzd0N3ShHDEI2wB76RZr+DY8Wp4DeYFJoWE3m9Manb2aZ85tzCMnHKnEmJ
         /dy1U/A0gfgaEb02iwQyJz2dI35tyodYX9lx4FqxsKTy+cOOlYufxkt33EUNdMK+SlmD
         P57aJv+xaU54K1vtwQ303xflxP8/r/t3u7ZByibIZ82KaV+9icPhsRaT0i6UJymW/wvk
         84fIr+HO42gJlGhuYbQ3WYnVsC3oetdu2TasTvm7n6e1MNzaFqfN5cDjV/rJ+egUNi2I
         6agVJrDQphMY4M4bYMQIn4DsvrJiY71hixdZUadCcEDEU/ZjBemjwNgo4GLrKwXgyY8q
         peHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=DcXpbnSbvxIdmq741qppTsLN32m9f2v4cydbcvErAV0=;
        b=UR1EtkYAjreTlJLu7XMvqp/yll8Xgy8R+ktMIC3ZxMxSVOmeRdrUQclMqvI3kR+5r5
         goYJjrcjALWs6rggatjXveu2UOp/59X6DD2o6Dw9XPVuu1dRNXld0c0RgyiX3P5vHaTQ
         ux+f+ge6lQqMTzqKcatA+Gy6iXLBM+LgW1Rp/8vjftK1RbX8wT37A7Q/kwtKk+rn+TWt
         oVrx3CA4unbW8V+GSing3BeoP86XfsY5VBYdfEK2ynGG8tgpYUwNYwF+Flpj4BIQjuZD
         LLPcvGcc7CLnro4u6JUIZhbQSfTH+ck5K58o2E9V0FKZRIfw3eiIStxkg7Q6Tm41FKYr
         Xalg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Q+BjbpDB;
       spf=pass (google.com: domain of 01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id o89si3159903qvo.208.2019.01.21.13.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 13:53:24 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Q+BjbpDB;
       spf=pass (google.com: domain of 01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548107604;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=DcXpbnSbvxIdmq741qppTsLN32m9f2v4cydbcvErAV0=;
	b=Q+BjbpDBgsQD/11ROUV+6LLlGtEkEYWE1cAP3Xrim+rdMrlzz8/LqguRcZmbtPlL
	2bNjHzrtqtpGEdkZMf6iCeUwWepSntlMaV138LRW2szfZ4BhieGFXzdTc1+Zkk9GaLp
	NrSg5DYlIFSs3WYwZ7KFyLiBbk4Ak8CxcaDiCQTU=
Date: Mon, 21 Jan 2019 21:53:24 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Davidlohr Bueso <dave@stgolabs.net>
cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, 
    jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
In-Reply-To: <20190121174220.10583-7-dave@stgolabs.net>
Message-ID:
 <01000168726760d6-6c4f2b48-870e-4a46-846b-3bb3d324000d-000000@email.amazonses.com>
References: <20190121174220.10583-1-dave@stgolabs.net> <20190121174220.10583-7-dave@stgolabs.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2019.01.21-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121215324.FqShdM648fdSj_tb3GaVgCPeDtuSzJzytaMiYpNZGDA@z>

On Mon, 21 Jan 2019, Davidlohr Bueso wrote:

> ib_umem_get() uses gup_longterm() and relies on the lock to
> stabilze the vma_list, so we cannot really get rid of mmap_sem
> altogether, but now that the counter is atomic, we can get of
> some complexity that mmap_sem brings with only pinned_vm.

Reviewd-by: Christoph Lameter <cl@linux.com>

