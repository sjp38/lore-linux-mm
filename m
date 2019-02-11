Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61F6C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A45A20844
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:21:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="Yl3XVBBW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A45A20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 972228E00C5; Mon, 11 Feb 2019 02:21:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9485E8E00C4; Mon, 11 Feb 2019 02:21:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 838278E00C5; Mon, 11 Feb 2019 02:21:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28A7B8E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:21:15 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f202so5707343wme.2
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 23:21:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=2+Wj7m7ySIuMfGlN7asIXsR+ghoPH8tIEa6cdB4icBU=;
        b=mQZr6dOTPwdI4BWe/kkZzDXkYD1M4Z9ErgEiq2mcZLpJXg+BAU5tGU7rsgYJoyiKXU
         VMx1+VLZXEs2NsleNX6i2ojRWIZNdxl+KD5Fo02C64cfQdKF6G4KO4uafqFm4nkNtQ76
         odmiWF9W9iUPdCJdKwfBXx5VRYkMIDf9j1hnfHBAne/jFhIGckuLnHDm8lfIvn3Ccbi8
         JISje69Jq/AjjymiOz/7hdFviMDBVm49TVIWUclvTcTULmPZfqFl4sdvWXkH5MPN0R8u
         /bMp3Dfu4r/cG87mR0rtf8jVPvbTTcyijJWDS1LWZF/44F3s0OUHOqhl1GlFPEs4hxtu
         XH+g==
X-Gm-Message-State: AHQUAuYVXyTNot6tVGhwXES3P4tqAQKE6ETBRWkdtiLBkHfSWDL4htnt
	2RzIViYg6Zs7Wo8jicA7EjykVy7uyLy3uMYqwZD9ZzuZngFXjQtnn66XNVbAq7Ey2aLjblwkJJn
	ObZHS4RXjj75EWJZ1pEEy0fNtL74bYUDugQWh6V/bQ8ln9h65oXao0DaSQLx96U3/jA==
X-Received: by 2002:a7b:c1c5:: with SMTP id a5mr8428054wmj.51.1549869674682;
        Sun, 10 Feb 2019 23:21:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib18gRC+/APdcNOQNwKwSwkychynR5xSGQhh44RYWa1I+sLMYzswf1QUUddvhqX0qeq3/kp
X-Received: by 2002:a7b:c1c5:: with SMTP id a5mr8428012wmj.51.1549869673884;
        Sun, 10 Feb 2019 23:21:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549869673; cv=none;
        d=google.com; s=arc-20160816;
        b=mv8Rz7dKzv2tSSFT4su0XiNWhs2yR8T3VAGY26uk0J5YKznlyVfoX/+Wmxi7NuWJXy
         YmHmI8+Q9zc+LDQXV503gIzv0UAIEUMdvTNig7iZxptk0L3xUzE4PfENlYIYeLYJQA8n
         IJoRud1rIjLvpe7MOpSbrdFE4EuPmRnGp33JEzZgbZeRpVj/D8NYqFh1cY7n7cG7SaGI
         DEIZ51/jfAnPuuzhPn2CVd+I71SgkQJP2N4IKJGftxCwOa8G8uEWC8qFDCpaO29lWTJL
         ZefOMqz88gXC+kKFD3qK1Hj3fr3RqUKqN1bGzL6UKfbIJ5WWSXfe+1i3uqGjfi2LTifw
         XjOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=2+Wj7m7ySIuMfGlN7asIXsR+ghoPH8tIEa6cdB4icBU=;
        b=TFnuC4FGjtrBYtu35zmAcvyVswHberNioXRVyJs0Mw5/Ki1b2Gcg4orbHQ5jYkazB1
         qxDI7+mwcXxRyLNOBdwawkNBPnZx9Ydf7aWRJW1qbyWdan/9dsKTtnveh7jL4g8h7N7n
         7vw2hncm60kBmBm+noJbmgVRJqp72pIBWBNK//OGTKVX3TjkTdNqCsPo/oPXbrNIc4fy
         zRj/WvCDZHWOgKeRqayaaVNs/HMh/BY9OUhhpGExOLCy5/I+HsmUgv72EZdzZQ0nDQoz
         vFCmuAcWaxSYJDay1tfht7TIie5NPoWexwxRY63zk0UMziCCbx4S/pYt5oFHmijpFOK/
         WczA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Yl3XVBBW;
       spf=neutral (google.com: 2a01:238:20a:202:5302::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::10])
        by mx.google.com with ESMTPS id v4si6128822wmj.80.2019.02.10.23.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 23:21:13 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5302::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5302::10;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Yl3XVBBW;
       spf=neutral (google.com: 2a01:238:20a:202:5302::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549869673;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=2+Wj7m7ySIuMfGlN7asIXsR+ghoPH8tIEa6cdB4icBU=;
	b=Yl3XVBBWTUUZf5cLFRUp6pw8MMGlX6gv03BMGA/ScOQe2YHiWAl5A8knbwL6Si9LFo
	pXZgywqxLpTEfmy9nLEJfrfRCplCaK7pykbwBEz+SqnOQNwufhPBiVLFAJctLRjq7kNy
	jMoAah0LcnBLJPglQmMyAFKbaiDJfgwqqt4mmaBadLN5pA4IfILVT3jwcXroZcbWAyCi
	1CuqemFLksBBlNuznZFA1R/EvNsnwPeebz2gaLT76/Vwd9OqvLJPhw9lk+FyhDxsnW7W
	P82sX3HRh3PbPkNrfGwvMSC7rgyjD/y7mnLAP/ISIoaqmPrilroLe3aA0YghCzFcMDpp
	O3Nw==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7NWZ5grpnxnRrZcnSnXxCNGtcwUruZsoM1Hh3rrCw"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:8189:222c:8934:2abd:8ff5:5de2]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1B7LBGUZ
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Mon, 11 Feb 2019 08:21:11 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <0042290A-2939-4EBA-A638-D404FA2055ED@xenosoft.de>
Date: Mon, 11 Feb 2019 08:21:11 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <0807B9CE-69E6-45A6-A029-1AAE5615CC8E@xenosoft.de>
References: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de> <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de> <0042290A-2939-4EBA-A638-D404FA2055ED@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Mario successfully tested a kernel from your Git [1] on his T2080rdb today.

Link to the log:=20
https://gitlab.com/oshw-powerpc-notebook/T2080customizations/blob/master/ker=
nel/dma_fix/kernel_dma_fix_log.txt

He wrote:

Please, note that all of the above kernel runs just fine with the T2080rdb, h=
owever did not had the time to test extensively (tested: login into MATE gra=
phical desktop environment, used ArctiFox for opening couple of websites, th=
en played Neverball).

=E2=80=94=E2=80=94

Cheers,
Christian

[1] http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-=
dma.6=

