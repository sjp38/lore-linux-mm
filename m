Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CABB0C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:41:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F0B421670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:41:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="QEyLbGOE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F0B421670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51306B000A; Tue, 30 Apr 2019 09:41:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E02DC6B000C; Tue, 30 Apr 2019 09:41:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0B26B000D; Tue, 30 Apr 2019 09:41:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD4D66B000A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:41:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id f82so2048951qkb.9
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:41:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=beBu285rmqBNDiQNDcTz2JoVAX9N/IQQNqAAuEjGf9w=;
        b=sqLMP1tc+Q8YMOriWcEli+2R/N+Mh+QZtdA8CKdhR5tDPgv1OjoCqdJ/NX8QG/2t4p
         Mtg1ulg3vXJ0VeVKS9V4MGiSrNDp/qHsbHEZZXK/UDZ8hvsUFN1f2EiS+dW+zYaubMhV
         rAweQ+3muYnIqifzysjrHANLPp9N4KjtUOvBW0YajEaPMOlGz/GG7E3elTKTpnYyuirV
         H5w56QdCtEfFSLc+1xWkliqBZsgSJIB6P00TReMl2KGO8ZgsIxsm7UHu3aM3WND42H/j
         Xw+/D10fpdutEOEKDJkHm6DknPQapX4I72BSZS0MDjP1V/5tejKfnRM7ke2UnYveiF8M
         +/mA==
X-Gm-Message-State: APjAAAUyGPURLRW+7k0yvLLLj46E02hfXfxOmVxj+mGrMrdooZhNoUCF
	EzjRDTN7Wbghxk/yN76m8WZ7gyaGXK7/YSN0Ij1A8FXPwa69EvVhxAbyuqaFg+JqzP9LRUwF2Qd
	vWTOlvg7G14s9NiItqOwtYrCW3YiCXIy9QvISHc8u76DscCbhwM/FW89+yxmAGr4=
X-Received: by 2002:a37:e507:: with SMTP id e7mr52370319qkg.322.1556631660446;
        Tue, 30 Apr 2019 06:41:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOhoBlHNxo/3Z29AgdL2CWrwnk3DR/QGbCj3SDivSC+ONbZV47px4qua5Vxoq6gHZ2kTCF
X-Received: by 2002:a37:e507:: with SMTP id e7mr52370287qkg.322.1556631659879;
        Tue, 30 Apr 2019 06:40:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556631659; cv=none;
        d=google.com; s=arc-20160816;
        b=BPHKPCKcw6LNJHqw+s+e2cAp4SAwsjVLOGIa6sbSThMecvuJgv01Gtkih+SBSRuEmm
         cD0YtSIIIzO9ZQyP0t/DllPf1JfcK0FCllnKyT9XSMzB4LYvWSt7Yr+kHw/ZmIQDmTFp
         x+4IbztDrc60Yve/NrgTS/jkPoVW9If9XbtJ1boavZfiiE8z6/4ATkylRg+lblhfB3SR
         xnyKo0n5hwO2RkVRlZjOKQeiNRGxLE6SkNNHyOK8JmEHvNNB5S1pdYlUaR3CgrW0hWOK
         Z6syuprWGhcL+oglZ9L4kfFQ4MjYsbZlsBgsEPcgkDxuDIYFAEn6RaO7xZ+zyTgiDnpb
         2bJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=beBu285rmqBNDiQNDcTz2JoVAX9N/IQQNqAAuEjGf9w=;
        b=gAagnkfnAq8CubjhgoDosQ/Pf7pIbHfSvasqqJdQsdzqFPNDUMVqZ529oLSgnQ6Neq
         HfjD8y62ArifdstyaEdz0xnTTq4p/85Mjb0PnCA76ktuS5MrLwm1+WTWfSv0/pC8899B
         +kcC1mLPPkERPzQ/19BcIFES+rZTivP7dQbfRoSUMbg8+Q6pB9/s9Ig3XGviHL3rrVTI
         7zK3T38lY/s0aBgXxz7VIv0hkn6QqRoYsVedtPHTK/Jx+E9iR4ePsrMH9LhQp3T8ffeT
         U4Jz50xABn6cYlR0i1SgcSYwqsD7dACA4rWx50gKfRAdUpzmkvWHRLUWhwO+/irPeKJ4
         lR8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QEyLbGOE;
       spf=pass (google.com: domain of 0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id q3si10365409qtq.31.2019.04.30.06.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Apr 2019 06:40:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QEyLbGOE;
       spf=pass (google.com: domain of 0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1556631659;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=beBu285rmqBNDiQNDcTz2JoVAX9N/IQQNqAAuEjGf9w=;
	b=QEyLbGOEOCUS+pzuVbWu7CfTSXtyfCXiSu09ABe7LGl3MQTXMcdv5F6CYG7Mn9m9
	Cr2tVt+C3bCs9O4bKVDgiFAK0s7ET2m4BRnOyzLL0HT/l29zNxm4UfubaGLY/kPzA8v
	J2Qz0gIalm+NimzzeXwHdPJ+XRPsb0atevd5DX+M=
Date: Tue, 30 Apr 2019 13:40:59 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Christoph Hellwig <hch@infradead.org>
cc: "Luck, Tony" <tony.luck@intel.com>, Meelis Roos <mroos@linux.ee>, 
    Mel Gorman <mgorman@techsingularity.net>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mikulas Patocka <mpatocka@redhat.com>, 
    James Bottomley <James.Bottomley@hansenpartnership.com>, 
    "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, 
    "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 
    "Yu, Fenghua" <fenghua.yu@intel.com>, 
    "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Subject: Re: DISCONTIGMEM is deprecated
In-Reply-To: <20190429200957.GB27158@infradead.org>
Message-ID: <0100016a6e7a22d8-dcd24705-508f-4acc-8883-e5d61f4c0fa4-000000@email.amazonses.com>
References: <20190419094335.GJ18914@techsingularity.net> <20190419140521.GI7751@bombadil.infradead.org> <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com> <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee> <20190428081353.GB30901@infradead.org>
 <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com> <20190429200957.GB27158@infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.30-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Apr 2019, Christoph Hellwig wrote:

> So maybe it it time to mark SN2 broken and see if anyone screams?
>
> Without SN2 the whole machvec mess could basically go away - the
> only real difference between the remaining machvecs is which iommu
> if any we set up.

SPARSEMEM with VMEMMAP was developed to address these
issues and allow one mapping scheme across the different platforms.

You do not need DISCONTIGMEM support for SN2. And as far as I know (from a
decade ago ok....) the distributions were using VMEMMAP instead.


