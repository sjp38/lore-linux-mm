Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C5F9C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 12:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 190B52080C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 12:27:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 190B52080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C192A6B029B; Thu,  5 Sep 2019 08:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC95D6B029C; Thu,  5 Sep 2019 08:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADEEC6B029D; Thu,  5 Sep 2019 08:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0187.hostedemail.com [216.40.44.187])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC516B029B
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 08:27:46 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 377D4180AD802
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:27:46 +0000 (UTC)
X-FDA: 75900793332.15.plate12_43cf21c97d904
X-HE-Tag: plate12_43cf21c97d904
X-Filterd-Recvd-Size: 1883
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:27:45 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 93EF53001836;
	Thu,  5 Sep 2019 12:27:44 +0000 (UTC)
Received: from jason-ThinkPad-X1-Carbon-6th.redhat.com (ovpn-12-44.pek2.redhat.com [10.72.12.44])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DA1775D9E2;
	Thu,  5 Sep 2019 12:27:37 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jgg@mellanox.com,
	aarcange@redhat.com,
	jglisse@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH 0/2] Revert and rework on the metadata accelreation
Date: Thu,  5 Sep 2019 20:27:34 +0800
Message-Id: <20190905122736.19768-1-jasowang@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 05 Sep 2019 12:27:44 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi:

Per request from Michael and Jason, the metadata accelreation is
reverted in this version and rework in next version.

Please review.

Thanks

Jason Wang (2):
  Revert "vhost: access vq metadata through kernel virtual address"
  vhost: re-introducing metadata acceleration through kernel virtual
    address

 drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++-----------------
 drivers/vhost/vhost.h |   8 +-
 2 files changed, 123 insertions(+), 87 deletions(-)

--=20
2.19.1


