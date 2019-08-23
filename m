Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFD46C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 17:22:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38BFC21848
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 17:22:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=autovalidinfo.com header.i=@autovalidinfo.com header.b="lDV7ms5R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38BFC21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=autovalidinfo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8A2A6B04B4; Fri, 23 Aug 2019 13:22:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3BD76B04B5; Fri, 23 Aug 2019 13:22:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DB476B04B6; Fri, 23 Aug 2019 13:22:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0093.hostedemail.com [216.40.44.93])
	by kanga.kvack.org (Postfix) with ESMTP id 65B996B04B4
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:22:25 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1B7F145AA
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 17:22:25 +0000 (UTC)
X-FDA: 75854361450.03.coat98_8979b0f11d13a
X-HE-Tag: coat98_8979b0f11d13a
X-Filterd-Recvd-Size: 3520
Received: from mail-yb1-f196.google.com (mail-yb1-f196.google.com [209.85.219.196])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 17:22:24 +0000 (UTC)
Received: by mail-yb1-f196.google.com with SMTP id u32so4268768ybi.12
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 10:22:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=autovalidinfo.com; s=google;
        h=mime-version:sender:from:date:message-id:subject:to;
        bh=u/wMGtxVxF7BIlc6sWld70amlSvP5YjR5tYHHKrIrrA=;
        b=lDV7ms5R9xXDIKlk/Ce4O0Fd6hAUbrcgd+pNhZ2mVYk5+/on1FJZ2OVWHX1A9b+UGW
         yOEMy2ZK3JJFE/bCcvfHCkzqYnVLavMdb85z5yQwgPeoiSs6YeIxe/BnNuMN/Z/1Losf
         yWySMmJftDdot+s2Lbxftz2h18By3mCbnuasXeJm/RtDP3i+obSAnJ7atAL/NRZ7+uNV
         bJP3FLDom7utAqzwh3CiEkvwsW6hbmrzkGnRX/mA9YduYMmUfRbcdbLd95uEp1bnpRC8
         EJMymAl2s0kLajg6DpS82MZLpdcROFEVTHNaj056Y2GRGHlLQh1gXv1Vy2Fy1Ir6/9YB
         vokQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:sender:from:date:message-id:subject
         :to;
        bh=u/wMGtxVxF7BIlc6sWld70amlSvP5YjR5tYHHKrIrrA=;
        b=C/FJvakm8vTHA8TGW3s98kFnt2it43MGIrN8GNK7AK7CPvWFJkvXgXY1hmTtG8zPrc
         ep6QaTnDRrezX354Ft+RIXKkNoGMPXQH73DHnRY7WsVUtC+K8CsBH5PP3VfOfJt/Wn49
         J97KCNlQeHntrl8anjdawAJJB86IIcexNtdWtsv+oNOalLfh8s+YMzI22HT9/eSjYr5F
         qFO9s3+EsOyyj9Zh9PY4dEYSmCV8qyc7/yWOdHUHo4MDfEN3pWs6eLNB8jtKpaxjfsrt
         DdN/zx4MiU9x3urx2zb5aX8bs9vcWQ4JJNSvty/vfEQ6v82U0QvXMJEvUAyzs70ZSmmZ
         6aIQ==
X-Gm-Message-State: APjAAAWXG59zB2sCcsMPjEne34NTkMZSG2sr5KncBaD0idwK5GxD+Ja9
	bIZRH7va3Nja9i1NPohusDJ3W0MAY1H1erQPWUlG0IMg
X-Google-Smtp-Source: APXvYqzeRcexHhCqheZ3U+RYSLJlnufElNUCBqlegiBeXjYkQzMw7JvjE45r0GvqfTl+DjMDs8ehsAH5Eo5aFWIyW+c=
X-Received: by 2002:a25:86ca:: with SMTP id y10mr4007587ybm.39.1566580943610;
 Fri, 23 Aug 2019 10:22:23 -0700 (PDT)
Received: from 158059779194 named unknown by gmailapi.google.com with
 HTTPREST; Fri, 23 Aug 2019 10:22:22 -0700
MIME-Version: 1.0
From: rosie.huynh@autovalidinfo.com
Date: Fri, 23 Aug 2019 10:22:22 -0700
X-Google-Sender-Auth: vl1sXX_Tvr47lDU7StgYo6W3dlo
Message-ID: <CAAJs2D40meCDMz9uphjPSUyU_-3nd-U1zWh8megwk0UwQSWRyg@mail.gmail.com>
Subject: Managed Security Service Providers (MSPs & MSSPs)
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="000000000000a7e8510590cc0cd2"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000402, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000a7e8510590cc0cd2
Content-Type: text/plain; charset="UTF-8"

Hi,

Did you get a chance to review my below email? Kindly let me know your
requirements and I will get back with detailed information on the same.

Warm Regards,
Rosie Huynh
Marketing Manager

--000000000000a7e8510590cc0cd2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div>Hi,<br>=C2=A0<br>Did
 you get a chance to review my below email? Kindly let me know your=20
requirements and I will get back with detailed information on the same.<br>=
=C2=A0<br>Warm Regards,<br></div><font face=3D"Calibri, sans-serif"><span s=
tyle=3D"font-size:14.6667px">Rosie Huynh</span></font><br style=3D"font-fam=
ily:Calibri,sans-serif;font-size:14.6667px"><div><span style=3D"font-family=
:Calibri,sans-serif;font-size:14.6667px">Marketing Manager</span>=C2=A0=C2=
=A0</div></div></div>

--000000000000a7e8510590cc0cd2--

