Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 384E7C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 17:55:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C79FC216C8
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 17:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="NcmNpSP3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C79FC216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4928D6B0003; Mon,  2 Sep 2019 13:55:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41B0C6B0008; Mon,  2 Sep 2019 13:55:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E2F46B000A; Mon,  2 Sep 2019 13:55:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id 05ACA6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:55:07 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8B4E6180AD801
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 17:55:07 +0000 (UTC)
X-FDA: 75890731854.13.ink78_83f7dd2370a4c
X-HE-Tag: ink78_83f7dd2370a4c
X-Filterd-Recvd-Size: 3375
Received: from mout.gmx.net (mout.gmx.net [212.227.15.19])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 17:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1567446905;
	bh=BuRuYWt53fabtXrFoYUqhAzDxPOtkNF0Wr10FO2gkDo=;
	h=X-UI-Sender-Class:To:From:Subject:Date;
	b=NcmNpSP3CfVq1wrtYhOp47d7OymMLF6RauJiMVbIUlNXwcvs/tituvPJZSpOIf3+p
	 dbjTCtXhY3uewULWQ4rYHUzx5h1slOgB8cuSmRCjyT21Puc+d07lkQRkUDpaivyuEL
	 AqkQJmRHmQ+MuNIH7pcx/JzupsZN83RL3zbwf9Ms=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.178.44] ([84.129.92.208]) by mail.gmx.com (mrgmx001
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0Lkwc9-1icnme26Mf-00apcg for
 <linux-mm@kvack.org>; Mon, 02 Sep 2019 19:55:05 +0200
To: linux-mm@kvack.org
From: Sebastian Fricke <sebastian.fricke-linux@gmx.de>
Subject: the linux-mm projects were last updated end of 2017
Message-ID: <95e4f329-7634-4d32-5252-1dcb25410201@gmx.de>
Date: Mon, 2 Sep 2019 19:55:05 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Provags-ID: V03:K1:QNDOL8k2qxh6BHPnEGrqqM8uXlpSDfvtZZxv74fEhJ96oxwGOj7
 qJbiuF0sx7+43YrqSyNYQCWd2fY5NP6bczNubiv1uZdPH9rDv6RxSbSo9ohYIJ2bk7IpUhJ
 VzdMWt/LfEfgpSne9sjjqrFtLJgMq3Gskfuf1VRK+SJLaFaNVEDqxSBGI2SHORccm+0nEe4
 TW085dAsI5jb79O30N14w==
X-UI-Out-Filterresults: notjunk:1;V03:K0:KXT1kATM6UQ=:8AMry/3N2tIhmaJndzGUvB
 o/aMkRjUaTfJi0JZXA4VafKKw6Km0L9Lp1KelDSx7P45GrvvaW+wmdfOW/NYJvs8X9C0NCkk3
 Ymnj75CrD8cGtSyVB1zGuZKt68Pl/mlNez9KTLWNRump4+7ic1x9huhyDo5ZVDaSca19ABdtW
 +rI92E3wdaYTrkXlhbj8E85r9fCprzvj6uZWNztFIjVrkhAMwfqW8lWpllfkzMFcuB3OfxyUO
 N5ACcnXtUi3VJG2HV0OtC+9Vq2voIjHvDpLUiU/FmULXdmJ301MdW87Y/V6dPAi1YSfRH8t8V
 vSXiVol+cmwvwRIEaqfzW0XWFBcrJDGfqRH7aVDfFoQ34uTUPa02kGy0RsszVJa78Q0ytopLF
 mH5lA5J7JiwPhdjyaLSrFRVGsgiSiRoaU/qCKTOtQ7P2GfabA9+0OVBMmbNSg0JFvaYCyGDIR
 //piHBHIky9EXR5PMxKpl0JJj/h8ZbeJvfq2CbcoinAVr4/qOqlM/6Yw3kN9VMDPmmns6euMT
 0FYeK2snZOZAegU92OLbhh+TROdZylRNGbtuUpiHO96Re0w+TDIjezG03EjMUPgsRqstQjqRk
 GLhWAz3SCjEL2RL3s1RLvPDp405ptZAlVawYTP1ZqPMxdtl9LmwTvtVeztYGTSieC+gVDYLN+
 p7s/k8Ez9/NA05S6QC9GXMsH10Ck59u08N24NFvduaPu8pMXyfFtTnJkk2/TP9tw4wh+/RwyW
 Mjq2kkWW6mMYGFcIZLO8iN8/Dkb+9QAXivO9RyQWrElv5e5ltXD6uqWbf+w9ZYot0EW2VsRy7
 dOM5Wb0LY4OaBGAtslH3M1c//bUae2XGy5FPVfI2HTC9GXUDXVEPTII+UEbfkEjuzF3I1Sy4N
 BuOqk/xIzOq9bqhpr0es21WNGJzqvGMCb8+pI9aDKEdrZADWg72VYeJtn5l2qePojp8oKoEq2
 AVffzjRNBt7MjJk/ToWNrDf7lrONfnvwpIrpbJzk7Z+ELJ+4Dwb3lTtI/jOdz5CatZkgOIcJM
 8Inh6MA6kKyUjT+KH1/PsSFlhWH5bxQQy3SRqM9MwJKHfNDEwAiH5yM656aYpeRhDrEcOsz+T
 86fS2HOPfuGX7mYgNFeNATTr7WYww1br+MqCDjWv6OE8nZJ212fCnMie8XEpUXxKJS7WXrIvk
 opPe15gr5SDA2tISOEERbn+gQ7g0BJ1EU2TNkrIl4GNqmLMzvbMwm/Ug96/GOBff4xf+4=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.036341, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Is there a current list of active projects flying around?

I would love to see what is currently in development to look at
different routes that the mm subsystem is taking.

But the kernel newbies and the linux-mm site seem to be outdated, could
anyone point me to a more up-to-date source of information? I would be
willing to update the current project site of linux-mm, if that is possibl=
e.

Thanks in advance

Sebastian


