Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7379EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35F712075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="UY5G4bBJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35F712075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2DC8E000B; Wed, 13 Mar 2019 15:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C721C8E0001; Wed, 13 Mar 2019 15:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B614F8E000B; Wed, 13 Mar 2019 15:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A39508E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:05:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so2900625qtd.15
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=HYILPhhml2kdvQ+ahvNJltAH2Iv+McJePa90BYMQh3XVfwVnxtzOKDI8llodEKo6jk
         vnDStgR+1m7Qd4gkEChi22z+zTa5bL5uM01orelW2DBUktNJ7Kt7FSgEJtNdj1+CHesD
         EzqNen8ORukbzreDQJ3GtHiu8BGoIx4lXIyM+JQ9bFY2rWbgOG2O42YwfQuh3+DgfKDr
         wy+fjJKty/jfoc4LYzVAEh2tfhaKrLwy5S7Ei6f3XNxwfe2Z1djm3py9Y33YMCqYnK4k
         VCXdMFYvYQe0FBuwUMOJrOPRR0lpFWJ5EJKKu3bxANZ9ajRI1/HuAPkjM7aNsNnv/9wd
         ebwg==
X-Gm-Message-State: APjAAAWzU4cO9bKQ5T2sQvP4dyj4AXkwAU/AAL59C53cVXKGTgqNpCRE
	1gqN52uYCIpKAITZsRC/xcNIx6isfOMgPizg1P8cfl5odd75Ff0RnzZZvDpmUKVSYcu9HkiC/ln
	nvAEIO7kGjD+b3DmWOwCP3ZyjAozWWF76qwFgInRcVbWxXiHysSm5hNQzjVFJJ70=
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr35271591qvc.235.1552503939506;
        Wed, 13 Mar 2019 12:05:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnVoSq97PRzm0Ehas6iSHPcxUk5dbT86/9W/UfpstYP+jysOYdPCEYH+1dyDgnTmtwrn+c
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr35271545qvc.235.1552503938977;
        Wed, 13 Mar 2019 12:05:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552503938; cv=none;
        d=google.com; s=arc-20160816;
        b=HX0si7fUCyfR4XYgoBC2eT+ZGDHuMG1PxVV8zSC6g5usI1SHL0mOIysEysZIf9ge5+
         ssuAgLX5b1ypJrBeJxyCvsQ+jl6b8Wzn4OfbvoU9r1stSD3z7Y96mbhi3+kYCsEM5Tuy
         1jimxXtZH9d7nffxeJvWPhnl1wjKfdspHoKhK+0bb+d0xbti1g2KCSJ8CBCvMIMX4Hsh
         aTi2GPlc2RurqDjHbY7QM9GNmfRupQvRNmykigFLEkd8Ng22vQHDTkCLTDCf6qPud56w
         8lfEdtbWFlJpF7Wcbpf0HSR9zP0STXnjtMCqPaWrgsTRm0CtMpuxGfy15dryqXyvTO6L
         5Wgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=oNxxoufs0KeBcaOjlOD1dal2IsnLGp3L41/QQB9//X1zJ1WpYyZV2k/15ZfhFJ6ayf
         5M6xY7v8K3Rw2NhBxYf82RFZHRNzVwO91+H3yFGZFUSDOXApMAl2rdNl5dWRWifJAzHw
         5ays8DDoVeFyBl7qpHKWnWw3IrC1JhL9mwQSBC9PcHaqpLLpNV9opXyZ+k6eGKfUfLPf
         b2LYsnXEuAM2GnD8DngF7uCa9JeaXGy+m5VC1Z+69DQ3xruKCpUxJI5UPH4WF+vi37Lg
         4Mei/KQ9mCW0sX55q5c1EdQK2UOQN6Hv7HYj/1rEN5vS7yw7A4zzVgTXEoTpSyRYSIlq
         Ed0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=UY5G4bBJ;
       spf=pass (google.com: domain of 0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id x2si2292661qkh.65.2019.03.13.12.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:05:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=UY5G4bBJ;
       spf=pass (google.com: domain of 0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552503938;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
	b=UY5G4bBJ5a1OOLzjRTf68GTQgR3YKY6fvzHsJl3y40wsUKdoW6BWuHJnkDt3NiQ7
	BlghG5Au0apKXSJegJmQl5/J+V9QDaa1s3kkh+yxbi6u+8U5Cmd7wtSpkmAjpyX1kOX
	Z4HZYih7uWbgxYSe8KgWjNehi0jPgOHnQMPxwq7c=
Date: Wed, 13 Mar 2019 19:05:38 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 5/5] mm: Remove stale comment from page struct
In-Reply-To: <20190313052030.13392-6-tobin@kernel.org>
Message-ID: <0100016978721dc4-11bbfcdd-3af7-469f-a8ac-d7730edc8da6-000000@email.amazonses.com>
References: <20190313052030.13392-1-tobin@kernel.org> <20190313052030.13392-6-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux.com>


