Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93EB7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5659B2075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:00:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ZmD0i5tI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5659B2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27108E0003; Wed, 13 Mar 2019 15:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFC398E0001; Wed, 13 Mar 2019 15:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CECF48E0003; Wed, 13 Mar 2019 15:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4BBF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:00:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so2857854qtk.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:00:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=W+yFZRk4dC/qTFdrcEsgcjNM6j6BEKwjNbGoHlGhsqorO8WgUMKx41QHvFFm84l5c8
         czp5RILEMz+tJbdDMcosvRLK/XrU26rNoM41wn1D6wk3wfSKrI3+iqzLbv2lhfSe4GzS
         +gUYV+L+sSzHpkN2zgqlXGITxYXWLqq0DO6svJ7RUACGVWgquZwOoUj9V0ATkE31UOpB
         l+anTAoOVqng5e3djOkN796oddSrdgCPL8CSMZvb4HBxoAcwbpVZ/3vcP2S7sWozDYa+
         LxrDkOfETQ12hTerIhfYwxnaMgI7zOMa2nL1bHui7W5MJTDUvDTy1Ozt2848xzV3h/lw
         G+9w==
X-Gm-Message-State: APjAAAUnJASD+xdP3SlUadM5WlyMhU6RcZulfST2lQbpg2RhPU1A2s6e
	F9zwMgcuZPVZGk+NydVNZu6U2PzW7kBMvEwvXe3Tfri9S/5il/vTdqLQSSp/+kIBdFXycF3ykKe
	KCmlGu0uzJtdZySp5iGxYDNzvu8RTB7hmS4x8rMQ6LVKDTCWp+tCQ5m1ig+5GMes=
X-Received: by 2002:a0c:ba95:: with SMTP id x21mr35150568qvf.65.1552503647219;
        Wed, 13 Mar 2019 12:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzl8Gli6Pzy6MCNezcRP6F79mXF5paLOuZ9d9bMHAQM6n3qh8Zn6oD9Boj9vBoTOEwP1486
X-Received: by 2002:a0c:ba95:: with SMTP id x21mr35150513qvf.65.1552503646276;
        Wed, 13 Mar 2019 12:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552503646; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/ej4+T5XUHylsidbQTeat28WxhgMLeuYx2o9ZmAZSnk9cNEl1w4Hi9gN0x6y06856
         ZH8qhnPAOUqNZpe76blDe3EzNrEVmRWnUO7vSVXnhzYMM5FqftaOPoLOSo9pfDppEHq9
         lggYfGogTcQELROayXDeDYw3EhM/lI7/4VKgkQteLJg8hySdXOW5GICKrW6t5oqqWNX7
         F5YbDDoYSyT7LrJvsNMGfItG0am0aM/vZmj9+L+FEvroIu9bGuauEjGjz4xgDLfIZjWB
         pwDh5NMSfRnYJ/11gmMgAF7du7bU59Sa+hWs9AzPMw/z8jK6fhYnqIwSobc/KU66RjOY
         zvyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=QiCRjtEzXgg9Tw7ZBHbSPNC+oN5cbM/c1PmWNy/JfXFpXAg2/7lNpY//Yo/aeG9mms
         OWle0w/R4QLUF8T0jxTISeTrFyU70ADj5E2p3U1znptVlb5A4nOZ9eExtjdhkTYvdlNQ
         pVpVzcU4rMbrgiIPLb2cIHOVXR94xj0mnYK97jmpPo/rx+PKBg3KjmIxlKvRO2QkXQNK
         dudArJ4fHNk5qEF/SU4GQp/TCoOlhHBaDwjDsMGDimkmHhYXJUq8Hv9uM0q5jGf5/1HW
         eH1Jn7cscasPqvCmupVqf7VhPWNGNDyWTOR0SjnF1y5iO9j4lM7HFXKovP4iAWHaFjxB
         lI3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZmD0i5tI;
       spf=pass (google.com: domain of 01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id v18si7356703qto.367.2019.03.13.12.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZmD0i5tI;
       spf=pass (google.com: domain of 01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552503645;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
	b=ZmD0i5tISekKUpnLkeNXCwQ1vVW9A7rfgy7qPJEel3WTfKVZneko1zLlsUmEzIf6
	Iji8YMMlaXnXNCYUCef5IJ3dXQYwvXe6ar3OadtxVKNs4wZB8jq0IB7Zbnf50XRxQ+e
	IGGR0HjL/4p/d/Yj8HIE+SxmH9YUxasmkaJnv7lk=
Date: Wed, 13 Mar 2019 19:00:45 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/5] slub: Add comments to endif pre-processor
 macros
In-Reply-To: <20190313052030.13392-2-tobin@kernel.org>
Message-ID: <01000169786da62d-7d0ce9cc-5f3d-4ef5-b357-447d25db000d-000000@email.amazonses.com>
References: <20190313052030.13392-1-tobin@kernel.org> <20190313052030.13392-2-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux.com>


