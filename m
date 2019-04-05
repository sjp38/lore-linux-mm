Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FORGED_YAHOO_RCVD,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52664C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:54:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD05B2175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="pxiJKXeO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD05B2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DCED6B000C; Fri,  5 Apr 2019 06:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38C2A6B000D; Fri,  5 Apr 2019 06:54:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27B976B000E; Fri,  5 Apr 2019 06:54:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3D996B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 06:54:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g83so4125244pfd.3
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 03:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:reply-to:to:message-id
         :subject:mime-version:content-transfer-encoding:references;
        bh=7/aDwESz8VShDjxzOY+lyUyRXS9Vu4L14qc9ENV0qNU=;
        b=hevuBsXM4SqA3rCkovWsIAicMoPRGoATSX7tzTQ0Dis5eKVuiJyiW5f0goJK/6P0Sp
         IK491xGlMx35jFfeMB480qOYde7YSTIiUmpDZ6B3d+ZUI+6drEzWbQnQ+FxSmsuiVTVF
         Hy/DF1g9vpXJHmNrqX4TQGe+9wHaa2LTK1QW+3PrAwqbrU7Kj1z02ofKjnrybdawViHZ
         W9/obq07Wmmec5inNMsQ4KVewwC2WDgoOZvTH5y4nD0xGUHO8b1bpChF3EwQI+x6poKM
         JuMzMk/RHErTPMCx8Kgmu1/9YtPo7WtvaqeI1RdUe64LKAtepCOPJzABTK6zCe7+HOGF
         jIMQ==
X-Gm-Message-State: APjAAAVLjMZ0TRI2uoJ620sr+V6aXaIAfRXtHwNwc+HA21TfGRPP2g+R
	2H4cHOqPRaDwEbowycKefVhQobSqKUQ2PFxKkFBWx8yk3yao5iIkWbpcbZh0kIFO685Vk4Bjaj2
	s089Oqo65ZRkbES9pt78vtCx34dyFyaWxaUfYvH5PPCE5OKxKH3jdCw6OyZwc8Yjq3w==
X-Received: by 2002:a62:7549:: with SMTP id q70mr1700960pfc.112.1554461692379;
        Fri, 05 Apr 2019 03:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMGWZLVHNAH/WkXdbi1ILsIumwDN+HRtVR+wJUz8O7t4eaR7DMr0XyhTKA/xnrHbMTMmbE
X-Received: by 2002:a62:7549:: with SMTP id q70mr1700905pfc.112.1554461691454;
        Fri, 05 Apr 2019 03:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554461691; cv=none;
        d=google.com; s=arc-20160816;
        b=bgfi21a/4JTNG+E+FlXa1QhZq/fUlOISaT3xUnWQpGRQ2VUYfcpgubXEivJjbJjV7X
         0z4n1KmH0TmefAwLTh8upsTwqewRyttc6PtN9rh3cMZE1vCuptKJlbpu71bqQZPbFlqF
         9KnuGuZt5RpkgxSv+V6cnUw1nMeuCh3J5zj/xyyE3O9gCjnVWnhAxT0QXltxVjIWNzF6
         DXZCbmupvO41ms253xxi7Xb4v6EwQhWyZW6I9rRBNmoeFbewEHr6FfF8VeAYXXZncLlT
         owsaBBJ2A9dxAVrml7DVcs4lxGaLdLCcMo7vOgRUErHnAe+/ETJSuTP+hTHq188PuwTo
         NMHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:content-transfer-encoding:mime-version:subject
         :message-id:to:reply-to:from:date:dkim-signature;
        bh=7/aDwESz8VShDjxzOY+lyUyRXS9Vu4L14qc9ENV0qNU=;
        b=vFMO2PK6D+2xf0IBv68mncoEz89IWBcFuJMPtqSBOTG/cRARPip2tNet65y5yYt0mo
         Q5DC1gJbBydlFE8lSYSLoD+IL/ZknUPSXR3OULvmzqasH89AOj3ImZUXXLj/IBgYfxs4
         T8Gbuo8aIRK1VMs1+r8CSndiym+YIfKabkbMnp9zZr++VM65KWWx4tXMxcDEpJap3z1z
         6TbMGKOAkZ4CUVkRVu4OM0N7U0SRKctYm9JZWkDwl1yuanvOkUBWIlW1riQKEdgOOs83
         HW2B/24GrIlszg2BgTxJDxj/1GR0uCRehj6iyMYpPPgUB++2r1vR1iAAwpExaQYaZH3s
         RAqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=pxiJKXeO;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.140 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
Received: from sonic302-20.consmr.mail.sg3.yahoo.com (sonic302-20.consmr.mail.sg3.yahoo.com. [106.10.242.140])
        by mx.google.com with ESMTPS id r20si18652753pgb.162.2019.04.05.03.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 03:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.140 as permitted sender) client-ip=106.10.242.140;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=pxiJKXeO;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.140 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1554461689; bh=7/aDwESz8VShDjxzOY+lyUyRXS9Vu4L14qc9ENV0qNU=; h=Date:From:Reply-To:To:Subject:References:From:Subject; b=pxiJKXeOGcDvgBa8FIwNPX8uwXtFuIMZBlFxZbvBgSKSpNDvKiPAoajNqbKmmaEDpG7wBAGAfCg4ni1heAw3lQtFP7GtjSzf9Er/XQ51e9O0DXMI98WvEi1OX5LQ4e5WjVf0nIn+V8+0Jzmq+HGAISz0zkOKOpOodgARyYulaBL3TRnT/bHsjtIBWNia6S2oCk6KFwPGW2U06YPSnS8osJ2cX3sFqqvdl+DdT3AtfrKK7OQoIQ2geKTX9OHXneGqWT2XvlLWotv4bZcoO04VkD+QWBftLcyN3gHAN7NLV2e1Gt+uHD5iYXXOVhhpzQ1MbXdh0+AvbEMaEu5nrStjOA==
X-YMail-OSG: N1YGqvsVM1mnwyFCbx_7CBZgaHFnFdpP30Jn2za8jr8mW4GVMOSXrkdxxQ8y1Zf
 BUHtyfa6G_OL0FCfjicv74KUrplQ.jMCOxb_3ZXzXcY5vQwW.GA0YmGk8N9U5QGvLsk9FDAC2Pwn
 3y6okFosDzpgwZJsbUnbQd1Z0_yE7hHwbX2OSWtfMwCg0_6tl54GJx1YnsbvCV3eIL4VQljkLolW
 dPazzazQjgeHH_w9qybYkgqPGG3H80Nm2XX7Rgsy0ijkwsg9fFRgOKKylbrA0GTSYOAK.XnstsOw
 IGKpA9YKXgdIjhISNF5PyUqMLpXfkczy9b.J_oqaGqrItYBgYhQbIqQRRxOt4lcdLr5B9pPG8ksY
 nPheRyiYWDkY8y2fRXdzevyZ7qO3ULTSo9T.h3ahuNnM6S8tqBVah7_k9sqhBb6Vvg_4dyiFdovn
 RXBdbyOYr8kGluCleCHeH0SiAqj2UYhLYIV4cBZvfLIzT9hhVtLrKdixzj_wxGp.5SRmOahtsnAu
 JObVRkbtoA8w7TJjcoeuyfTQuvYyMWRnFB3UWfy9C3_PtWRmPJQSOtcA29jjuDpjrY7N5mCTceBe
 pM0b8XNSwR.WzvY0Ym7fFyJddVzk9wAYA.x.wEyHxOc6cRAULIzI0Va4j7EJBD1iiwJITuPjLKoG
 uaMcBRcLmYxLD5aXm_t35B_iOxOfxN2amE9lym7axigngwd1a1onHaTTyjpy238scWTpeGa3EWhl
 Spnfx5j1xc73.9bpLEcxJCVALBYgp.Kn6Qs3zztep4M.H3Vmz.biD11Ec_g5gRv9PFgFjpRVGuoF
 FxIIuIWNJfWameKuBs4WNLvXI8Mm2jqCeB5_PpfjtUooVOFh8clgZd5xehd5.ZanZJffWwiSGF4x
 hgr6UyaLoAEF9IHQVGxSIrGS9ddz8MkIOyb6fclj95UFcWNLzXI0ag2L3zoItI9O.l9r9BU1j1Gz
 0Q8bL5Kt_yWmEjGdTFI9dCJx4ex.GVY2Nj6iLHZVMSNopgV5zvLPHMjQbohClL9b91FRlRf2Tr8R
 zsRm20Iz.AHeGWDS88CwLNOPX6leqTqmvSr99IKY1qppi4bZv
Received: from sonic.gate.mail.ne1.yahoo.com by sonic302.consmr.mail.sg3.yahoo.com with HTTP; Fri, 5 Apr 2019 10:54:49 +0000
Date: Fri, 5 Apr 2019 10:54:47 +0000 (UTC)
From: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
Reply-To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
To: LKML <linux-kernel@vger.kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"kernelnewbies@kernelnewbies.org" <kernelnewbies@kernelnewbies.org>
Message-ID: <1536252828.16026118.1554461687939@mail.yahoo.com>
Subject: How to calculate page address to PFN in user space.
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
References: <1536252828.16026118.1554461687939.ref@mail.yahoo.com>
X-Mailer: WebService/1.1.13212 YahooMailNeo Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I have PFN of all processes in user space, how to calculate page address to PFN.

eg .

page address :bf05febc in kernel space.


I have PFN no for user space processes as below.

8a81b
69da0
88cf4
88d06
88d07
9549f
952d0
9734a
87c7d
87ca0

How to calculate/match page address to PFN ?

Regards,
Pankaj

