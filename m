Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BCC7C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CFD32086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:59:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="c7Di0N0Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CFD32086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7F2B6B0005; Mon,  9 Sep 2019 09:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2F4B6B0006; Mon,  9 Sep 2019 09:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1D286B0007; Mon,  9 Sep 2019 09:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id AE1806B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:59:08 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A5CC199A4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:59:07 +0000 (UTC)
X-FDA: 75915538734.12.card31_4fa389e1a9321
X-HE-Tag: card31_4fa389e1a9321
X-Filterd-Recvd-Size: 3236
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:59:07 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id b2so16253494qtq.5
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 06:59:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=VPKIFoXhxnL4jqXekZdx/Xm2018hBSmReQQr7A9dV/o=;
        b=c7Di0N0ZdX1UadOMsiSNfH3zdjInSzfNsThNAm/i32fQpZrCBP17y1eupHxQPK06F5
         uZ7Zx9mxAlrG1YRyKBV6qbohqBQmC/Kh4XnAngyeXXyBlNnu+Uvpttt1kUIXj2t5qTjK
         SnsBsLQf1H3VdF7cs2l8QlLv9FAV4gOrFYmYU2MHr6COaeZwRP3UBljsMGvpVd0p7RLf
         J0qYYuArAMdmhwIa/DXzWB2QNN/7+QQ6fYE2H//xVCynwTP9qBMySnIJoKemu57cH1Gl
         RYjanfX/R5MOAGJwPSoCAeWCyArVTOCgqcK4II/wMCF4Gk+lKEEnAKx5qEodLW3tk4NY
         782A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=VPKIFoXhxnL4jqXekZdx/Xm2018hBSmReQQr7A9dV/o=;
        b=rMW/Bq5E6J5szTuZ0q8qnvImlpECZXRC1h08wlydqgtn7SCu2JjcJ8LZPTQzso2+Tx
         ZDV5U6uLtjUb5Oh5h5tXFROZcFUHEa9zSrkDGhs2Gs5TNPprdbnIG6R8gXwwrBzcLw8V
         zg5L+KFZgBg0N9B3VB01LPrCstEEg7qLbuGBhnNxBOF8fNdeF+MOoNcjTnXgcBP9PQI8
         2sIoqdb0S/LyRpHnmF0NbaVXP/ZQefoqo/MpwsbcMB24mpM8gAARJZiIe8w82OZypEHL
         c+ZNNhtMZzd7NJpo9qMc0M9Mn7AXU6koWxypbw294ptTBRmaZEJXjQVbizubHghlVHrQ
         Ae/g==
X-Gm-Message-State: APjAAAUmsnkN66gYpmXQBnXwySzfapGU3uITnEXd1hxFI2iBLJ0b80Wo
	mvjescnRkGw+gQ7bidBJjCsfOA==
X-Google-Smtp-Source: APXvYqxTb2CmknLxoRz31HHbtcNmmjY9bk0L7QGJyOZ4BvDYRYH34nIcEsm9z7TkDin881uG5K/3zA==
X-Received: by 2002:ac8:714f:: with SMTP id h15mr22949319qtp.328.1568037546191;
        Mon, 09 Sep 2019 06:59:06 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id d133sm6570187qkg.31.2019.09.09.06.59.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 06:59:05 -0700 (PDT)
Message-ID: <1568037544.5576.119.camel@lca.pw>
Subject: git.cmpxchg.org/linux-mmots.git repository corruption?
From: Qian Cai <cai@lca.pw>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton
	 <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Date: Mon, 09 Sep 2019 09:59:04 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000028, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tried a few times without luck. Anyone else has the same issue?

# git clone git://git.cmpxchg.org/linux-mmots.git
Cloning into 'linux-mmots'...
remote: Enumerating objects: 7838808, done.
remote: Counting objects: 100% (7838808/7838808), done.
remote: Compressing objects: 100% (1065702/1065702), done.
remote: aborting due to possible repository corruption on the remote side.
fatal: early EOF
fatal: index-pack failed

