Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EF2DC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:26:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF5532339E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lcycfSHB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF5532339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FBB36B02AD; Wed, 21 Aug 2019 17:26:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AB116B02AE; Wed, 21 Aug 2019 17:26:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59A146B02AF; Wed, 21 Aug 2019 17:26:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0032.hostedemail.com [216.40.44.32])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE956B02AD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:26:00 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A337F181AC9B6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:25:59 +0000 (UTC)
X-FDA: 75847717638.15.road53_6e76f18f7cc1a
X-HE-Tag: road53_6e76f18f7cc1a
X-Filterd-Recvd-Size: 2024
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:25:58 +0000 (UTC)
Received: from localhost (unknown [40.117.208.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A2D502332A;
	Wed, 21 Aug 2019 21:25:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566422757;
	bh=wc7eTRLiEcYYmYpaLb6Z5l3HQX0RaJTCiwllmXpt9TM=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=lcycfSHBQAbFkLePlhPi7AtI7wh27fRi4gJX/2LZb0EXmX5rLJ+qGC0iaA1vFQ0AR
	 Fcf+ze4Cd3EtWy7C44KiehEIR5F4QOmOF09/OdaXzpJjop2aUXgeTGcJ9FxTy0gI8t
	 sYTmDxoyCcDqWS48HLp7tMKht5tQ5uCW24GRIVDs=
Date: Wed, 21 Aug 2019 21:25:56 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Christophe Leroy <christophe.leroy@c-s.fr>
To:     erhard_f@mailbox.org, Chris Mason <clm@fb.com>,
Cc:     linux-mm@kvack.org, stable@vger.kernel.org,
Cc: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2] btrfs: fix allocation of bitmap pages.
In-Reply-To: <c3157c8e8e0e7588312b40c853f65c02fe6c957a.1566399731.git.christophe.leroy@c-s.fr>
References: <c3157c8e8e0e7588312b40c853f65c02fe6c957a.1566399731.git.christophe.leroy@c-s.fr>
Message-Id: <20190821212557.A2D502332A@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 69d2480456d1 btrfs: use copy_page for copying pages instead of memcpy.

The bot has tested the following trees: v5.2.9, v4.19.67.

v5.2.9: Build OK!
v4.19.67: Failed to apply! Possible dependencies:
    f8b00e0f06e5 ("btrfs: remove unneeded NULL checks before kfree")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

