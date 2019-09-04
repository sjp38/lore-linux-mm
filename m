Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B50D9C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836A22077B
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:27:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="mP+Wb2fq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836A22077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7F36B0003; Wed,  4 Sep 2019 15:27:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A7AC6B0006; Wed,  4 Sep 2019 15:27:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BE2A6B0007; Wed,  4 Sep 2019 15:27:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id DEC3B6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:27:19 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 888A9181AC9B4
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:27:19 +0000 (UTC)
X-FDA: 75898221798.17.bun85_22d16cce21453
X-HE-Tag: bun85_22d16cce21453
X-Filterd-Recvd-Size: 1724
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com [54.240.9.114])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:27:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1567625238;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=GSADDDUzucjw0izr9jastymBrpAHNMYRyeaYzA8+Uhc=;
	b=mP+Wb2fqiHE3fKmY0lTJ5cgTL8X56zeovIKhwE5tXL5FGqe/zJl7HMc0vpR0WP9L
	pGZs89DUthfoOijrI+PGaCd/DuxFWZxVZ+1TjeK/CiriyJQ4vP3haOtVCs2yZB7qwNj
	X8T9yx92nvnLJkhMYDzkopTHI5cS8NGvFL9Bs/ck=
Date: Wed, 4 Sep 2019 19:27:18 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, 
    iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/5] mm, slab: Make kmalloc_info[] contain all types of
 names
In-Reply-To: <20190903160430.1368-1-lpf.vector@gmail.com>
Message-ID: <0100016cfdbed786-8e9441ab-4c0c-4d2d-b9dc-d1d6878481b8-000000@email.amazonses.com>
References: <20190903160430.1368-1-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.09.04-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.076688, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019, Pengfei Li wrote:

> There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> and KMALLOC_DMA.

I only got a few patches of this set. Can I see the complete patchset
somewhere?


