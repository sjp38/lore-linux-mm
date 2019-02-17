Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DEBFC4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 23:50:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A95762177B
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 23:50:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A95762177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBC4E8E0002; Sun, 17 Feb 2019 18:50:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D694E8E0001; Sun, 17 Feb 2019 18:50:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C58CA8E0002; Sun, 17 Feb 2019 18:50:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B92D8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 18:50:31 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id a5so7064648wrq.3
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 15:50:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bG/NrotNBSsgK2Avqx8s7CINFwUkhQp5Xvzf6+L7uKY=;
        b=ta/U1Rf050hYWw1u3H2GrwcpbMyIzhHscrEptZHJgMnkp+pKMk16nSoH8XyxB2ws6R
         KaMTLKnOy7KOqjSXcZSzXvgOIGlbgSYMkoz8LtjQ1psPDqZW1mG212aKFU1L+PEt0NGc
         kmIC0gqSs9CF3VTXvmgKjTpbJOB+XlVs6X8V3aOdHwzU+QLYK9kdKGCxp3ftYn7mJ7IQ
         FhtFdNhuIZqp6HaenCQE3x09kVxYMYO8VEPPf14eJYB05h8thhm+B+nDP9VpW0WxVYuf
         rtLEzQ+DSBGH6ABBQnv/GWgc6gFPQE/ddD2jus8dS7zZIyWWhDHbY5SSAnmYNJisXklN
         zc8w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAuZWaqvxg9efvGv1u1SVLSIqF+ZBlStyUXyNFZGOQgP2R10YgSNT
	DReAAYywcN1ahhNz755A4iRaHC9/I3SNXBrVZfYIVjbIL5JJe4me+AO3ZxvoWvjDBZVXwWCu6Iz
	LQtIjxAlzYeS85HjlGso+CqnSJSIqe81bjol4AcyEi8+uQY2ugoww9QfyBudSP34=
X-Received: by 2002:a5d:4412:: with SMTP id z18mr14284907wrq.111.1550447430749;
        Sun, 17 Feb 2019 15:50:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaguNKseHgCBCgxPFwuMbBij4DM2KE3jZivZkljshd+A20FFA7TkzULCKpF+IBF4PFdWabl
X-Received: by 2002:a5d:4412:: with SMTP id z18mr14284880wrq.111.1550447429806;
        Sun, 17 Feb 2019 15:50:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550447429; cv=none;
        d=google.com; s=arc-20160816;
        b=TIHtxrD3X9MbaapaqaZq2nUzHGdkRxZi4Zjby/01pdNtlbFblgWpYATbqmL5hvfRtc
         aQH3axKeZdqvy2RDWQ8IklT5FHLF7y4DhkyDGP5QHK+jFUaq814A505d0NP16iEzh9Ct
         bjIvSJ42VF7JuWafcOOauZTpCYv5SrVzD0Zj3d54COg/Ppe3G2W5nlnstoaMz1v0jQSE
         zQFOviecqk6hAEdP4237ULB+RUP3yIe98je8pBrJZJbWV7vPOEkXLwyrdVuRaMjLldoW
         sHWnZbgL+vlKOS8WSY62OOt5MblnqSuUSYHkQTUnozhf5x2EeSdJJTf+VmqMfYkOAz5F
         VbOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=bG/NrotNBSsgK2Avqx8s7CINFwUkhQp5Xvzf6+L7uKY=;
        b=JETpdZ7gNbfp5YELJn39JSxd7ZsUWmHbLvlWPlKVqOTJas1V55LWtLK3ulM45Qzq3R
         cU/et0NYmiRudMCl23sp1Fjqf/0aWqVDON8ZKgcoXYd5DixrshCZ3zCBvwhh2V+Yqhrj
         l803hWp+UahG6duIawDq1pLn4F9mi2s6mC1yguzhokzk1Ky5VAy0NADV9qXHvbCXsO0D
         eh4uzbjgdz3jO3dY/LsU9IjMd69H7zFUtp4AjkCyVRDvI+/UpNjonVFeJd0oSH7i3gso
         P2hZNRVUEe/byso/lxoND4faoEc6O5ePyUfyhAX0GCpBpjKJNcJu6CMTvgBNP1FuAu3S
         JDBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id b193si7749419wme.47.2019.02.17.15.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 15:50:29 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::bf5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 4359E1234135D;
	Sun, 17 Feb 2019 15:50:27 -0800 (PST)
Date: Sun, 17 Feb 2019 15:50:26 -0800 (PST)
Message-Id: <20190217.155026.2230689002634375366.davem@davemloft.net>
To: alexander.duyck@gmail.com
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, jannh@google.com
Subject: Re: [net PATCH 0/2] Address recent issues found in netdev
 page_frag_alloc usage
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190215223741.16881.84864.stgit@localhost.localdomain>
References: <20190215223741.16881.84864.stgit@localhost.localdomain>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sun, 17 Feb 2019 15:50:27 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 15 Feb 2019 14:44:05 -0800

> This patch set addresses a couple of issues that I had pointed out to Jann
> Horn in response to a recent patch submission.
> 
> The first issue is that I wanted to avoid the need to read/modify/write the
> size value in order to generate the value for pagecnt_bias. Instead we can
> just use a fixed constant which reduces the need for memory read operations
> and the overall number of instructions to update the pagecnt bias values.
> 
> The other, and more important issue is, that apparently we were letting tun
> access the napi_alloc_cache indirectly through netdev_alloc_frag and as a
> result letting it create unaligned accesses via unaligned allocations. In
> order to prevent this I have added a call to SKB_DATA_ALIGN for the fragsz
> field so that we will keep the offset in the napi_alloc_cache
> SMP_CACHE_BYTES aligned.

Series applied, thanks Alexander.

