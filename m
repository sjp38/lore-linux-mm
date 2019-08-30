Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B225C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B2C72343B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SgyXyXSy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B2C72343B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C327B6B000E; Fri, 30 Aug 2019 19:04:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4B06B0010; Fri, 30 Aug 2019 19:04:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF89D6B0266; Fri, 30 Aug 2019 19:04:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id 8848B6B000E
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:49 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EA986180AD7C3
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:48 +0000 (UTC)
X-FDA: 75880625856.20.meat91_2a011882e2d30
X-HE-Tag: meat91_2a011882e2d30
X-Filterd-Recvd-Size: 2408
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:48 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6EAB523711;
	Fri, 30 Aug 2019 23:04:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206287;
	bh=/v5QHejZ5+QKawcql9XgKCbdZW/Bd6VhcVnuUCN7PRc=;
	h=Date:From:To:Subject:From;
	b=SgyXyXSyINvdrOo/kiqnyIuUNgyw4fgYDcNc/5GSIhw0UYtMnhSQ8sMlNSTVC7EOU
	 i5hFnj4jHAZ6emH2iNyYEqhiMKh7HM3ObgPJE6u9zj23U/tqAcWucssuPHoRctqTBc
	 zoMjhR9Xv6jI+YqxTeU4KayX2lfYT8u570GM1Tok=
Date: Fri, 30 Aug 2019 16:04:46 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, dima@arista.com, linux-mm@kvack.org,
 mm-commits@vger.kernel.org, torvalds@linux-foundation.org
Subject:  [patch 5/7] mailmap: add aliases for Dmitry Safonov
Message-ID: <20190830230446.mkjHLVwpR%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dmitry Safonov <dima@arista.com>
Subject: mailmap: add aliases for Dmitry Safonov

I don't work for Virtuozzo or Samsung anymore and I've noticed that they
have started sending annoying html email-replies.

And I prioritize my personal emails over work email box, so while at it
add an entry for Arista too - so I can reply faster when needed.

Link: http://lkml.kernel.org/r/20190827220346.11123-1-dima@arista.com
Signed-off-by: Dmitry Safonov <dima@arista.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 .mailmap |    3 +++
 1 file changed, 3 insertions(+)

--- a/.mailmap~mailmap-add-aliases-for-dmitry-safonov
+++ a/.mailmap
@@ -64,6 +64,9 @@ Dengcheng Zhu <dzhu@wavecomp.com> <dengc
 Dengcheng Zhu <dzhu@wavecomp.com> <dczhu@mips.com>
 Dengcheng Zhu <dzhu@wavecomp.com> <dengcheng.zhu@gmail.com>
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+Dmitry Safonov <0x7f454c46@gmail.com> <dsafonov@virtuozzo.com>
+Dmitry Safonov <0x7f454c46@gmail.com> <d.safonov@partner.samsung.com>
+Dmitry Safonov <0x7f454c46@gmail.com> <dima@arista.com>
 Domen Puncer <domen@coderock.org>
 Douglas Gilbert <dougg@torque.net>
 Ed L. Cashin <ecashin@coraid.com>
_

