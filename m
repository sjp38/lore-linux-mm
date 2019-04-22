Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB909C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 17:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AC0D214AF
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 17:29:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="I6cqfNZU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AC0D214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 525C46B0003; Mon, 22 Apr 2019 13:29:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AEE16B0006; Mon, 22 Apr 2019 13:29:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A0616B0007; Mon, 22 Apr 2019 13:29:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF2C6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:29:03 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so10967957qkf.14
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 10:29:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=uTp82GrKS+FoqOpQPeRfRgfZOledo6xDwlMBf3yfJG4=;
        b=I5CE3NYXMDC6kPc/AbRkXtRLiwzTS9PLVsETw6nbCErxfaZWPSx2761aGHWmRux5zC
         B3wU8T1A+e4xgZv4ioC1DQNl4Vbqj04c5y2cjesNh5svoxqvABRH6dhfDD9JTz3b+t6v
         NyR6kZLoWLF6YsLtGe+aEPG/SpPuGJKKLTmmyogWtzqzLlN//LRHuOAcSqAUgXLrqWR6
         Q0anc+hAF8/Q56Xb+ucCHg3ZXstRSM7DmcKYqVzo+4az6HokRz4Ar/EVLobIWPofVq6m
         8dIAtokBPjXuTrhz0cBmVg4gf4JdK5VGhRTMgxvWgMi4lqVCJMhB5aSVi+pqH9zac9n4
         gXCQ==
X-Gm-Message-State: APjAAAXccxG/MNCgs3R5ykhLH1udwsX/1g3tNGQqt9hvXQHxaSJc6jjk
	Ovk5Py6uJDtZdmBKKjvz8t40dh+ybU1bCuZBIqIHXAG8zK5AQLKZQ0sO9QGSNOctmA6Riitgbhd
	MGVny6MIO9gzi65iQueTy+66DHcbnIlug1O004quN2wvVoWm9zRpkTmiSKaQ3xZ0=
X-Received: by 2002:a0c:ae50:: with SMTP id z16mr16153383qvc.153.1555954142832;
        Mon, 22 Apr 2019 10:29:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxdF2Oz9wKvqTNpHQVuoVBb7/ytLRn5d/4TVyH7K5u3zU9jy7qNIykeTDjzX0KFx2702O0
X-Received: by 2002:a0c:ae50:: with SMTP id z16mr16153343qvc.153.1555954142188;
        Mon, 22 Apr 2019 10:29:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555954142; cv=none;
        d=google.com; s=arc-20160816;
        b=LHnSZN6riUSIHjNSrCGx4kKPmBXY+mERwnNlTT8PROwodv6wVxDVbDZyV1/GwueJMl
         X/9phGqzsUBt7LzIcrMutuM6O6byNZgJPzx5zkq5rdVId/iIwjpNnyfKbfg7hvNTxrv4
         mKjbTCaZ/0ZLJiA4YF4PUL45mQ9wFliPwLpkZ3CBUNu5FpIPbJAvEw6AAIU9sTxdUkT+
         hbkXSd6E3T4X6ALiI50CtrctXDjwRQK2PagTUMZbbcdpMvQkSLlG5hrXOcfBcQvjulJV
         y1tcNRQwhiHdQcPelCVKoG3qCe64tzgWWX+n3AiEaUjLVpEEsAxcF8pmS7oTDuEKCpoY
         oU0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=uTp82GrKS+FoqOpQPeRfRgfZOledo6xDwlMBf3yfJG4=;
        b=XiKJRgSaQleLnDboqpoLDb79rqicJehI9/BULGywnbXy7ZJTN4ZcWD1qc/Gq5jKefL
         SVwkYh4M/i2TqX9P9NB8pXNdfOq2527cAJBrV3X7/69dT3wg+jSMW5ar1bn9gPdCsbFw
         XUcvAgZbfO3CPOVZRZ9rWLce4/M2y4qqTO0kz9CEzkL4W4oCof7Ife4axT7+QYDxC8LO
         ieurBjMXD4n77vpuOxakdiytxENknmKuSDuH43sJtm7I9vz8RFa4yjjdRTm347L8Aegd
         6fIhWMozj52i8Fugt1gNPLUoZvs/E+12uQv1unIxsK6OzIRWzEId/IBn8p3TyGM16Wa0
         cJww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=I6cqfNZU;
       spf=pass (google.com: domain of 0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id x22si628970qvc.42.2019.04.22.10.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Apr 2019 10:29:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=I6cqfNZU;
       spf=pass (google.com: domain of 0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555954141;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=uTp82GrKS+FoqOpQPeRfRgfZOledo6xDwlMBf3yfJG4=;
	b=I6cqfNZUSqdVhRoTlDMauiDjIdqVla6mLkcsOz4ds5wrUQGVqk1rB364uz2Xr/5k
	jY0gYuBl3eDzKi9pPTYJff5zDwUDgoNt9H2BnsBg91m08fD3FfGS1pF/ANBrG1y+uRL
	1XaNG8omk+ElH0D5ePFpKxCXKRfGUoJ+V/kdW35o=
Date: Mon, 22 Apr 2019 17:29:01 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Mel Gorman <mgorman@techsingularity.net>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mikulas Patocka <mpatocka@redhat.com>, 
    James Bottomley <James.Bottomley@hansenpartnership.com>, 
    linux-parisc@vger.kernel.org, linux-mm@kvack.org, 
    Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, 
    linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
In-Reply-To: <20190419140521.GI7751@bombadil.infradead.org>
Message-ID: <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
References: <20190419094335.GJ18914@techsingularity.net> <20190419140521.GI7751@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.22-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Apr 2019, Matthew Wilcox wrote:

> ia64 (looks complicated ...)

Well as far as I can tell it was not even used 12 or so years ago on
Itanium when I worked on that stuff.

