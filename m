Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 418A1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E94B62075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:02:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="WwK5/qgZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E94B62075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 794D68E0004; Wed, 13 Mar 2019 15:02:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71C6F8E0001; Wed, 13 Mar 2019 15:02:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3DE8E0004; Wed, 13 Mar 2019 15:02:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD718E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:02:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 23so2437871qkl.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:02:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=pV111AsP45nZgmPG/271bQV19fgiNQ1eYTtDl/ri9kxHQN38Fg9V73nRrbigeElbEB
         LVLy0vQWqvoeI/8N6EOTm31EFzzclXWXJ26zlFYFjHBhGsaZb8XllL5D6PRSzPAVuPjF
         z6xFb91E0Us2OIn2FVMTnaipnSUz4mgxA0C8TbNRE/8pznRDfmmNLZQgqcNGYkng9Nob
         ft6lNvaSPhc8k4eV4Sf7SbXILD0JTBXLaK9rlrwwup4hUjuTwU57+kpr9cL2XRJvhpGA
         rZDO2DFeatUugz5SvI+mafUTofTGf8E8vTEPkc4ZrARA3bDUeU3Wz/6h020WPY+t0zde
         xmXg==
X-Gm-Message-State: APjAAAUy+o01JUYy3weNdBVpbeJYVXirkCcjg5wgDf1Xn/vONaSgklgy
	iMqei5ukhqhx8e2UxawCLrDNbCYMbV9oOLpZuCw5nWQpDHhGvV9GeYTuxKaihc03T/2VbLKmQlI
	6G3+FiqBE47RDhC7BTIJIh00N8IM28YhgYRxiBwIhy1FArxs2GmZLaslpuPR48+8=
X-Received: by 2002:ac8:4a13:: with SMTP id x19mr16398644qtq.306.1552503777005;
        Wed, 13 Mar 2019 12:02:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy2t1gU0o7PDvz3mKwHKiQcVC5bRSCxU0pPgUd8+3XkOrvQBfg7V4+QjMFBzZILgc/ODIM
X-Received: by 2002:ac8:4a13:: with SMTP id x19mr16398590qtq.306.1552503776199;
        Wed, 13 Mar 2019 12:02:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552503776; cv=none;
        d=google.com; s=arc-20160816;
        b=RiPsUw0r9PRn7oAyUMEA4B4bnrgWeEwWvxXKtt3KsSyrZk50Zh0sBDxvVVVRo0zvWh
         Nge6FcLVE5bSpn68F00tV6Ib8bpfFalXsqGwneyq+KScxiD1eooaQuXme56f8q6rv2T5
         2olqLvYFl+HezW9fQ0uAZAvWgVEBqrcbVk1rbAoTuYTuuSWdjmha2ipV5SwlzKUypTRv
         0gD6G4M5X/nM8xSxTe6jVqPNMwNenaD1O3MN3fAgXISkd7l4aexnII/JN5WSyANdOlcY
         TvDquQKWT8I0L6xbuk4CcQtO8wtenpKM1dAcaOrMKHMYh4GH5YWURYkBNkCMWQEFo4vu
         tzbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=MchHtumcnjzbQ0n2KZOk1JXiwUqUKy6bff9Pb4FH4MPYCbyuDOWkw2IEHd08O+UuLo
         rP2rCt0drKdSy8Q2tp5HS5YkzmRp14+n8rQCXWoq5hP6Q5E/ny4PrdTZ0DhMrCl1djR0
         qrmBQV7dCHhrAca6TciODx9m/JwzaeJpTb6SqJg09U7u8ZrNGihGGFOnwXmXgGuOBFkA
         Lxu1m5P3iBI7J9hZOniIF2ZdhHUFp+ZePAipoBBJOl7vaavaL5AGCMRJnn5guE+u521K
         Oir64IrldA5m2vmsHDaKUwI1Xk19N7aDMGTa4hDCxatsuw0tT9S2wfU7UUmQLQXh/Jn5
         yrXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="WwK5/qgZ";
       spf=pass (google.com: domain of 01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id u17si7354209qvm.77.2019.03.13.12.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:02:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="WwK5/qgZ";
       spf=pass (google.com: domain of 01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552503775;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
	b=WwK5/qgZAxe3F67bLLPV/PXVqSeJEE89Ir9I5OpZHdem+8FXKrSu24Vun9bAugel
	6Tgw7zgCIH8vtACfDnAXFrrAMgO9rSAjkKCm8Jl876lgCLKbWJgkUqIFieGQFzTkcDt
	9ReC1MbBUD5/cX0xr5L+DY39lZF6FUUbunRlhc7s=
Date: Wed, 13 Mar 2019 19:02:55 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/5] slub: Use slab_list instead of lru
In-Reply-To: <20190313052030.13392-3-tobin@kernel.org>
Message-ID: <01000169786fa159-7b8b94aa-06f7-454f-a2b0-b1b1962a9dde-000000@email.amazonses.com>
References: <20190313052030.13392-1-tobin@kernel.org> <20190313052030.13392-3-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux.com>


