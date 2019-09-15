Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61833C4CEC6
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 03:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E16112077C
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 03:35:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E16112077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 387466B0003; Sat, 14 Sep 2019 23:35:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3370E6B0006; Sat, 14 Sep 2019 23:35:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24CDC6B0007; Sat, 14 Sep 2019 23:35:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0062.hostedemail.com [216.40.44.62])
	by kanga.kvack.org (Postfix) with ESMTP id 0529B6B0003
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 23:35:05 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A2918181AC9AE
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 03:35:05 +0000 (UTC)
X-FDA: 75935738970.02.flag40_4964aeab23937
X-HE-Tag: flag40_4964aeab23937
X-Filterd-Recvd-Size: 1522
Received: from r3-21.sinamail.sina.com.cn (r3-21.sinamail.sina.com.cn [202.108.3.21])
	by imf33.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 03:35:04 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([222.131.67.234])
	by sina.com with ESMTP
	id 5D7DB16300012D07; Sun, 15 Sep 2019 11:35:01 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 427606629758
From: Hillf Danton <hdanton@sina.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 0/7] Emulated coherent graphics memory take 2
Date: Sun, 15 Sep 2019 11:34:50 +0800
Message-Id: <20190915033450.14008-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000076, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 13 Sep 2019 11:32:06 +0200
>=20
> The mm patch page walk interface has been reworked to be similar to the
> reworked page-walk code (mm/pagewalk.c). There have been two other solu=
tions
> to consider:
> 1) Using the page-walk code. That is currently not possible since it re=
quires
> the mmap-sem to be held for the struct vm_area_struct vm_flags and for =
huge
> page splitting. The pagewalk code in this patchset can't hold the mmap =
sems
> since it will lead to locking inversion.

Specify the locking scenario, if non-rfc is planned, to help understand
the new wheel this patchset looks to create, as two days of finding it in
the works after ba4e7d973dd0 failed.


