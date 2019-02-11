Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,MIME_QP_LONG_LINE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEB4BC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:16:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC8B020836
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:16:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="QjLiy+ie"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC8B020836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57DD18E00C2; Mon, 11 Feb 2019 02:16:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52E2D8E00B4; Mon, 11 Feb 2019 02:16:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C1B8E00C2; Mon, 11 Feb 2019 02:16:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD4688E00B4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:16:24 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f6so5690856wmj.5
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 23:16:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=vDXOLUAx0OHR/x2jv9EfaBnmWwt0+Ml8+li9KyTOj44=;
        b=hRgaYjAn9/wglL56qnvht7InTJe4dj7FAbuoWnkTJK50BXABMakhKam49Wkz3m1G8y
         kWc8M9OrVF5NlS/Dv4rxtsSGr+0bkCVwv10VwwI36kA0QiHIp6SpZw6KI9q6ig4aB63N
         ECBBzi9FC+1eRAOqYZlkDAGQSQ7QoJJJMiWe1V0+r9SXvBDijf2zofBeHJTvwfGyxYw6
         Sxo9Ukl+HrlhLkJ6E5EJOZzvG7YOihPjw5gm/NVMan8XpSWrlemINyP7yXO3ZVRh2Mcu
         ac8WcHgx+qneZKdx6iMf6FvT+sFKgrOkZarUjtnvmjhooDb4PHbeVoeSKkonVgyhURpy
         NO/A==
X-Gm-Message-State: AHQUAuZHJct7s8xYMmFUl14zYv1N0vmVHNLYZgmo7ksw9WhoLt3tNTUE
	MAJU9BI0cP3/Csc/h4Adps07pevGYGnNzT+FME8esb1Tf6ZudgUDPR1LQpSR3qILY2gM3DPlw1/
	o6EAyf9lG9TJKRq0iVC9syRzkPUPv73qhXPto9BF9F2D6Kxx15HzlC+OwnsDJVnomng==
X-Received: by 2002:a1c:6a16:: with SMTP id f22mr8280945wmc.25.1549869384345;
        Sun, 10 Feb 2019 23:16:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnT0drZtGRQmkP+3Ne2BsWI2tAqBmVwYCmip0KCaqIjZBGy3CsO94wo30AGHm3nukHATu7
X-Received: by 2002:a1c:6a16:: with SMTP id f22mr8280877wmc.25.1549869383154;
        Sun, 10 Feb 2019 23:16:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549869383; cv=none;
        d=google.com; s=arc-20160816;
        b=VelDh1QtX/aeNrrwsTyJP2pYEPvJnPd520h92yipFe177bqnar/JrrtE0mq4X9xFiS
         icyDCT6VTlRhPgmUwYy/pbnHVIu+XwnoZtJJTo2W6zs7dJRlnvASzPZGGnd4P0J4XDkx
         WM95bzbzt8S9+JPhJykf/2qmAKm2ahe9ga9KnLYJGtpfIXD4ur/z0OkJREZGIxL3xckj
         6NGsVGgZC848cJ8lycS5A0t0xm/IEkzxiHjGhHOLb/92JgD9sCbB1Nnn1q44ctWYOrbO
         yRTxSLAE6BLxMk/+lDA8Vg5eguWO2/D0yUU0stqGSTQhErDbnhB7FDbyM/LNxIz+4XLv
         6Nqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=vDXOLUAx0OHR/x2jv9EfaBnmWwt0+Ml8+li9KyTOj44=;
        b=WGfQGkcZ2m8M/woVAXIYUmagKBYZMt8I3JOcHvH/uonSIxQo864T7MayB6cB8qFsr1
         H51lq3zy0my0unWQU6eLnUyuq9qElSxGsWPgxif6S4cWsUAb4f4W2k5gKNnHofGrB+i3
         Jt68A8oPK0bApcJCVDNDeuwRv7zTQDZ964fXVFJDPlr8PRY2SJXz4nLA5gEboEtrtXln
         qm2PLQ736pL5fpV4O9TZkXVALIqMQCyq+OVF9mtL5EnTHrJMZVg04SmpKjj0fkESLbQF
         tLAJ8UR8QjPkVK53DszkKH8QD0GXeEqe+ELe5nfEiaRskxudbGU4+j2J07+iWrBlX+b6
         DDEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=QjLiy+ie;
       spf=neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::6])
        by mx.google.com with ESMTPS id i5si7636423wml.171.2019.02.10.23.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 23:16:23 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::6;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=QjLiy+ie;
       spf=neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549869382;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=vDXOLUAx0OHR/x2jv9EfaBnmWwt0+Ml8+li9KyTOj44=;
	b=QjLiy+ie5QbHH0nUdA+DkXEBmSvKS2gvdnJTnZJ4DayjFY9z/ou6fc98S+lmNEqJTP
	ATY0c3AoxveQMceBMa8+71drAP8XkkpiADwVvu6KJpUxhJN3LHucDbgv3Obk5MozSzPv
	4C9YrtycFwqBpyneHPQ4aWAr6I0wDcUP5hmBDJoUt+N+q/di0zlI2VdRVc4bHzW58EH9
	2gq0hS/tktSMkaAD+Rhx6dfkRjk5FkEk2Jcqb6wFHHFOW+7Mz6AzGgZb8CIqcSBHwNo4
	bT0OeRegJWdRtZsBP3/vXxuHF+XPxfGTkI7BLAInSo45LPaMOSXjPLKhafnIeXcUSE3w
	yRfg==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7NWZ5grpnxnRrZcnSnXxCNGtcwUruZsoM1Hh3rrCw"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:8189:222c:8934:2abd:8ff5:5de2]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1B7GJGSk
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Mon, 11 Feb 2019 08:16:19 +0100 (CET)
Content-Type: multipart/alternative;
	boundary=Apple-Mail-AB54F82F-011B-4A2E-BF51-3599C977EE35
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
Date: Mon, 11 Feb 2019 08:16:18 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: 7bit
Message-Id: <0042290A-2939-4EBA-A638-D404FA2055ED@xenosoft.de>
References: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de> <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail-AB54F82F-011B-4A2E-BF51-3599C977EE35
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

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

--Apple-Mail-AB54F82F-011B-4A2E-BF51-3599C977EE35
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charset=3D=
utf-8"></head><body dir=3D"auto">Hi Christoph,<div><br></div><div>Mario succ=
essfully tested a kernel from your Git [1] on his T2080rdb today.</div><div>=
<br></div><div>Link to the log:&nbsp;</div><div><a href=3D"https://gitlab.co=
m/oshw-powerpc-notebook/T2080customizations/blob/master/kernel/dma_fix/kerne=
l_dma_fix_log.txt">https://gitlab.com/oshw-powerpc-notebook/T2080customizati=
ons/blob/master/kernel/dma_fix/kernel_dma_fix_log.txt</a></div><div><br></di=
v><div>He wrote:</div><div><br></div><div>Please, note that all of the above=
 kernel runs just fine with the T2080rdb, however did not had the time to te=
st extensively (tested: login into MATE graphical desktop environment, used A=
rctiFox for opening couple of websites, then played Neverball).</div><div><b=
r></div><div>=E2=80=94=E2=80=94</div><div><br></div><div>Cheers,</div><div>C=
hristian</div><div><br></div><div>[1]&nbsp;<a href=3D"http://git.infradead.o=
rg/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6">http://git.infradea=
d.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6</a></div></body><=
/html>=

--Apple-Mail-AB54F82F-011B-4A2E-BF51-3599C977EE35--

