Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD5CEC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BD2A20828
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="PknB/rT6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BD2A20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 012F46B0006; Mon, 25 Mar 2019 12:16:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01D16B0007; Mon, 25 Mar 2019 12:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6C76B0008; Mon, 25 Mar 2019 12:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1DDF6B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:16:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x12so10699318qtk.2
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=QBGlTHgFvFWzHfC6BIPxPtr9RCcl2kLO9acSShDGZdE=;
        b=Yh6Md/WfMhPUkMGFbmKl/FL8SLID+BuD06vqJ4UoV7VDFdzg3TNhXksoUBZ11uZiaz
         ekkBihzf2AOJh/QK2NaO9kMSBzqWkdUw8px/VSASttdLjUzgV6N0C7lJ2GHuHLxVeToM
         utIqP3YTOk6hj0mpAC9hqNsXtXCOe944womCRUn6dWiWZ/XlAMCv9wmG9Qu2CTbHv4dQ
         el4/RDpc+jGRfJh1gflqg7aWIQhOFHQGiS3PDyFnXiqGfz9Rg4CU1wVwun4C1Tep/H5U
         Lbao4fr7hE2UEhsRKWDKij+yTj8+Nar7Wojr0hoqqlPPs62qGHnGphvd+4L7xXanDmZc
         I71g==
X-Gm-Message-State: APjAAAVDrQaJebR3SPxNsirACthrUisfzducg/TbMQfvm2Uq/gMaaZYG
	NS4N+BFOQ5Vi9EO9w955os2v4VWBPl2Jn40SN6szn5t3uuGIOFgwpyCDWQe2b2G+XK8ozb/behs
	rmXCiIgTxsDtJCA3K+hMKSA5eYp80NH0HAsdRyURo0WO+4xMvCyDBZXFun46Jw2A=
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr14439708qkg.183.1553530576468;
        Mon, 25 Mar 2019 09:16:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD/VTVJG4mrN5Aoyz0SQs020rYzNPhBBRulVB7cDLPt0sRlL7/lNOrEjHr2x//W2VzDs4U
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr14439655qkg.183.1553530575812;
        Mon, 25 Mar 2019 09:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553530575; cv=none;
        d=google.com; s=arc-20160816;
        b=HqNt9AlRx++pR6/jvWqgqCGyRBBUTNuCcdfDDcC7vx8+5CaW1b4I14l9GSqTLzKMpu
         fEPQUIadOJ2V8sKGl2rFeyiExDJl7Cl4+Oj/FQg5h0V2MjDf3VNy3ccdfRS6a3q9NSi7
         nf6bUFSuTVyH0SkiovJf75v/et1jp3rfB0L/Yix9SkoUlUQM5jYvN0g8cATK48BUJp5S
         laOkW5pfVjIxZHbuEhaZyVyIFm/S0A0hc6ZAakhovMslrLscSOyPNnZ9jQsu/ubhCws+
         VeUtvUTW7nPLQClrYnLG1AvyEBiVKlbpCinSYKLUHjEvgkJfGCUpV/bTe3i4T6ReBryS
         8bgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=QBGlTHgFvFWzHfC6BIPxPtr9RCcl2kLO9acSShDGZdE=;
        b=O1D7Ek66NwMT7CMnvpNOLgPrB8Pe2zbcA2wpLTrfOzENEnvUUMIYuhTRjMS0AW1V/4
         /fyX5gEuzDXvqUrO1xdJW/m4+t7fMxc1DfqY7N7xPTEVNzA+8lbpZNZTVAvQzpc0fQU8
         KDErzkDOiVn/q1ZG++k/6Aj8VOOSu9Jnv3e76Ca6Mej0sCmLh1xtYwLLbKhER7h3b9U+
         x784ZKAHgdk5hOqL3bRR/SHPMZP0qEf19DBiNfDMQXMcb41fATAwfu4vGlkrnYAWKZtB
         5tT2xhc1qKx1mUqPcEUlTJz4pFad+67c6kNcmDqQODIIITKK671VQb0qVIH92I2B8T8x
         JFfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="PknB/rT6";
       spf=pass (google.com: domain of 01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@amazonses.com
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id h65si1341730qkc.258.2019.03.25.09.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Mar 2019 09:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@amazonses.com designates 54.240.9.112 as permitted sender) client-ip=54.240.9.112;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="PknB/rT6";
       spf=pass (google.com: domain of 01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553530575;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QBGlTHgFvFWzHfC6BIPxPtr9RCcl2kLO9acSShDGZdE=;
	b=PknB/rT6TahcS66rVgUbw9Ic4A4pEX1qBQ2wTSkh2PhvAkZRHV7Zcuqm6b3JqKhA
	4hoV4XgeocRtt9EvxbHy/FvfE55r2n1YZIJ0ZEtwlv0vO342rwcva6yZjeeISduq9Uh
	uV/UjIIVfgbZqFHci6clrkvWSpEUm8rPbycwFms4=
Date: Mon, 25 Mar 2019 16:16:15 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Waiman Long <longman@redhat.com>, Oleg Nesterov <oleg@redhat.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, selinux@vger.kernel.org, 
    Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, 
    Eric Paris <eparis@parisplace.org>, 
    "Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
In-Reply-To: <20190325152613.GG10344@bombadil.infradead.org>
Message-ID: <01000169b5a35953-18d68249-266d-48a1-bddd-adbecfcc3e9f-000000@email.amazonses.com>
References: <20190321214512.11524-1-longman@redhat.com> <20190321214512.11524-3-longman@redhat.com> <20190322015208.GD19508@bombadil.infradead.org> <20190322111642.GA28876@redhat.com> <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com> <93523469-48b0-07c8-54fd-300678af3163@redhat.com> <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com> <20190322195926.GB10344@bombadil.infradead.org>
 <01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@email.amazonses.com> <20190325152613.GG10344@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.25-54.240.9.112
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Mar 2019, Matthew Wilcox wrote:

> Options:
>
> 1. Dispense with this optimisation and always store the size of the
> object before the object.

I think thats how SLOB handled it at some point in the past. Lets go back
to that setup so its compatible with the other allocators?

