Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CED9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E73E20823
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:52:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ipxJtVHV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E73E20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B33906B0007; Tue, 26 Mar 2019 09:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE33D6B0008; Tue, 26 Mar 2019 09:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F7F56B000A; Tue, 26 Mar 2019 09:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2C96B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:52:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j10so11961356pfn.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=hlceh8J3UDHjopzvH0T6OmT5CXF+sN3ZUycoWQT6P2o=;
        b=WAw8kbV/dRLOS5c/eQNgSzaeHOkXbktM6mDXbn3y72Wzrlo0ze2orZYCL+tOx2zhwC
         sfvLfcUjYf1dVhMETYi2b1rgwyy5WgmrYZ3AHctnxcOS93Lqu/LKgw6EPb1LSxOdqD5f
         jc+fCXjwqWL7q/0+1iOlQePcGPy0COFHhxlnHM+R3vFBxASz02A5hJV/GhNXpHbHil14
         7XoXOGOhBRKsHdNI/661C/PRt+18Vz0IU66DarDvk/5zatvoJ7FE6XFQYSFCZBoeyyZw
         mtqJU1pECN4aykc0ZIIBYf785TFFOg1deYs9Bz5V+F4orXauLGZQrSiJI3dxNeS9gygN
         RMag==
X-Gm-Message-State: APjAAAV30eL6l6Sk6mZoHOP6Zj3QEMdNZBf48Fvc4+yVWRMAtOAoJn/v
	wJqBNqZh8uhkCtep2yswxdWZTYJlWTcPqH4ZtFS+xO1bsxqG/BTsZCFqkAifrzFu/Yaki8m9r36
	i1iHLlTWHeKwEYuRkTqTAX+gwNcpyEdK9G8Z/pS2C5y7lalg4NoaAvXqYRX7pu9yoWg==
X-Received: by 2002:a63:7152:: with SMTP id b18mr20933584pgn.186.1553608338587;
        Tue, 26 Mar 2019 06:52:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqE2Pdz3X8hTm6AD3tsb4krEIvnLn9JnbFmsn4Moxq2zNNLFQO5p1LehFXvzc/nitDjY4T
X-Received: by 2002:a63:7152:: with SMTP id b18mr20933408pgn.186.1553608336294;
        Tue, 26 Mar 2019 06:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553608336; cv=none;
        d=google.com; s=arc-20160816;
        b=iOYW9HMhv+5xXMnwMHaZXP5lC+BsgHPqWVDobd/5L1JcbM5TC/cqUXXSXsDksyIZCJ
         l3ulR5nqfOSTyzU5xyuabzc4zC3ihgf8j0hRhpVWbHLfIOK7IXCfxB+93aqns5xpq3nH
         YhdNccAGIS9VsFgaYQtnxlVSX9ONo7L0a/Z/fJD28eKqvAXu7KlAfBnwwLpmZeUfUHFc
         Vj8DZn0CG1h522QitfkgObuJSrlqEcPF7EBSSROgcnL/WDcv8H1zRBe2zlW3iEJ097ta
         kH9KlhjjTAEJozIjC58e5z4arqRk/VJSC525uai3UqNabJHJAIoWg40BzbHDd7bdaGEZ
         vzQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=hlceh8J3UDHjopzvH0T6OmT5CXF+sN3ZUycoWQT6P2o=;
        b=fntWW1QpeDBtp0XqkO+YuPvxHdQQrETDAiSEHtC8Lal5apijnvqQcHbVYvE/TgfbgS
         93jxMZ8l000k7VBYCCAUtcYcxWJv6CSpIUwFRwPxNBQfZJ95VBAATQ6JEKNnCqEESbOj
         RTe/vnyOr6TlT2dJD7vJz4lWlnbKeHcI0FTEd7g+YpzQ3vJiVun9colvQp+5YpqcLwan
         NNG7xT4Ksee2OHV6wGJqCpwg86jmGrrL/AKKt5fac/F/qLTiPTJHVvK9ve4ct2cR4rBg
         ubBRxYgWeGS5DBcCHE0aJUtz52xXXzgKRqVBdaYKtOUJUosyQICa1BsZCPO/LpZayvqC
         /o3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ipxJtVHV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k20si15396706pfk.55.2019.03.26.06.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ipxJtVHV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2QDheMM025966;
	Tue, 26 Mar 2019 13:52:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=hlceh8J3UDHjopzvH0T6OmT5CXF+sN3ZUycoWQT6P2o=;
 b=ipxJtVHVa8TePkRxY9VPWO/oNkzjmPCNqh9NxijVEQsVYVq8MvQbS929Nj8+8NnAadQw
 tPT77xcbL4bJS3Tf4+RSCiT3LctyrFNwAdRvlz/s/q5DHrypZiTw8DtpnFiiErGMA/iZ
 hDy8EfbmGt/Q8j0NHc4RVqRz+HRSc0I0OWEZB5LJYv/vCJbcYxAjGJ/Cb+O9alEl47SB
 MwjzN6G1Ey/Ys6n+W2iMIDFfJYcElDTTepuboG3TOmxAq7CTO56k6F+lnenLlv03Q0Yd
 cWDmHI7OsGZlnwXGfl/uPJGwrzOVZOZKKy8g90bg4BQ6jKQsJ7ePXrNHqly3Ir/Gs5a+ kg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2re6g0tgbu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Mar 2019 13:52:12 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2QDqBpC027245
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Mar 2019 13:52:11 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2QDq9e2020614;
	Tue, 26 Mar 2019 13:52:09 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Mar 2019 06:52:08 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
Date: Tue, 26 Mar 2019 07:52:07 -0600
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
References: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
To: Meelis Roos <mroos@linux.ee>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9206 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=991 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903260097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Does this still happen on 5.1-rc2?

Do you have idea as to what max_low_pfn() gets set to on your system at =
boot time?

=46rom the screen shot I'm guessing it MIGHT be 0x373fe, but it's hard =
to know for sure.


> On Mar 21, 2019, at 2:22 PM, Meelis Roos <mroos@linux.ee> wrote:
>=20
> I tried to debug another problem and turned on most debug options for =
memory.
> The resulting kernel failed to boot.
>=20
> Bisecting the configurations led to CONFIG_DEBUG_VIRTUAL - if I turned =
it on
> in addition to some other debug options, the machine crashed with
>=20
> kernel BUG at arch/x86/mm/physaddr.c:79!
>=20
> Screenshot at http://kodu.ut.ee/~mroos/debug_virtual-boot-hang-1.jpg
>=20
> The machine was Athlon XP with VIA KT600 chipset and 2G RAM.
>=20
> --=20
> Meelis Roos <mroos@linux.ee>
>=20

