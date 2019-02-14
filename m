Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCE75C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:00:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8032D222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:00:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QW7XapRi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8032D222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3776D8E0002; Thu, 14 Feb 2019 06:00:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FEE68E0001; Thu, 14 Feb 2019 06:00:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17AB98E0002; Thu, 14 Feb 2019 06:00:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D15428E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:00:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x134so4479568pfd.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:00:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=oBoYKrHmkB0DE74B1po/8VDjK8Xr/YU8KGJgp6PsWoo=;
        b=JJcS8D6N+xTUf/douwFLynN1/sDbBYgy17QV9UYvtHdJBMzJZ25LAImSW1IKZnHkH5
         KQhRUjWHEsrGgPVYhfO9WgUVxRxZ9vsbrIWK0CO4ukHdxSJI+R2b57ntU+rCaclk9Lg0
         cOBDyDUGbcIMNXAib3jMFZeXc6jZOrTwB68p5fVc4LMciYtAULqwBb5xPIXqOi6j7Ixc
         sdzexHmbZfvmZDLDtaSozHX//SL+Yrh/ONwXLSUKV6kW66VTVIRRlVuyBJBWQreBcEdA
         U8+z3+SnP6fzSbOh406ovpp2x5Tky80Ff7AKUHSR1yOhqw0lVwiyUhcNwV9g2h42qL8T
         Yd+w==
X-Gm-Message-State: AHQUAuY+DJ6QPWOCOrEbbpC6Lp18Ga6DcKpvorVEmHHPwNKLxogGWH0s
	QMSvLU8/HOWiKgTiG2kYYTDPDTXCwtC1FuyPaiIHjf9p+zpcd7yc9jEyEzXvz6djZDFDzDrS9Y2
	Tqh3rg6p8BHoBRkO23qIW+ZR/EKg6U5XAMcikFrpLEahKEi7mhWTkBqS2pTAPbnNrIw==
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr3494748ply.65.1550142052392;
        Thu, 14 Feb 2019 03:00:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYoDR7QGix/Bu27E/HkOZZkJGHb2e4a0+4QiYx0IMbyaM0GaogGSsxGntG/7XhXYfITxBVY
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr3494686ply.65.1550142051761;
        Thu, 14 Feb 2019 03:00:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550142051; cv=none;
        d=google.com; s=arc-20160816;
        b=gY+HELQMpD4KTjlyGObNjS3QhgPH7OJ4BqaTgrStdWoTqL2Knuzq8oAxcgI3CZAN8Y
         7cPBvU6nygkePcI3IKmWedygpmyxoe1Kb/kRpkClG7PAhFFm4uF8bK7oLz8AyQNVsCNy
         5BaXTliJKxwf9q5iVQAW8jONlquopE+d6P7wKtgFiutha9g0PsDu9zGcCDozzkxQlWQe
         B66Prcm9zo/nDL+ifWZRVN07/XbSIxV5VcjRiRXQagr4Tmltom2q6fQGtY49mqs7L1fv
         +vKcVBESWogXO2Ql3Z40a08TY5Mg4wXJE3uIKiNhsN/qacEX4d717gzYW0nUBlJVvdue
         Jfcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=oBoYKrHmkB0DE74B1po/8VDjK8Xr/YU8KGJgp6PsWoo=;
        b=ND7YZFZ4TDrlDCrxzbn9gdALd0zh39j0e3A94rBBLZjaaS5Zug7KcxcTlq/L/rS3s/
         3STZx1ofSQZwDaRusTPL3y6sa5a4luFNKxS5HBau/p/l8N5LqBlpeicwGHAqQOF0AYsu
         EbjKE+UEmhrv3y22u1lDwNUUxK/iMGziaAMoZ8WfheaAh1i/eHGWhDZEHhP2lG24mup1
         ow9oaKJdgWvb6UVZ071GpD71PcRlgISS+PhhcF8bsREDisraB94Htn/CFfCkYTsE89sc
         1YUDG3tvNwezk4Rvj8C9ESbLL3jIZnV4cgQPnRqcq6/OOFTUhW3VdcOWi2atbcH3b8KB
         L5JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QW7XapRi;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 1si244980plp.114.2019.02.14.03.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 03:00:51 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QW7XapRi;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EAwecb195540;
	Thu, 14 Feb 2019 11:00:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=oBoYKrHmkB0DE74B1po/8VDjK8Xr/YU8KGJgp6PsWoo=;
 b=QW7XapRi9UF3HwATVM8EisoJD4kQ6XotQFX1LnXN6HmumbHSkpdH8Ay94BmR4UIasXhY
 NBM0J62c1Ldk3UlG0iaMpIHQDnx7wd2HHiLpW4G9apLA1TFx55ka5XKHZsOwG1ZzjA4Z
 p+S+iHraR3p9tQoExUD+sN7hOKiOmQT4GGpzwnBKhzOm3JU6sa860zS9MSXTwFZJ9n3V
 bqZ9VxsYuvl+LpwvX06ThKUR+M+U9uke0mKsj/FvHWgaTwdrab4xi/M5r6V/9/IemGwC
 n8Xzb0cZ0nqW22TH77Sfc5T+voDJwlRaZQJSMkPflW8oMtTvVcHTEM4mr3PhEMeADZsZ +g== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qhree7brc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 11:00:45 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1EB0d4H014736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 11:00:39 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EB0d14012698;
	Thu, 14 Feb 2019 11:00:39 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 11:00:39 +0000
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v3 1/2] x86: respect memory size limiting via mem=
 parameter
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190214104240.24428-2-jgross@suse.com>
Date: Thu, 14 Feb 2019 04:00:37 -0700
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        x86@kernel.org, linux-mm@kvack.org, boris.ostrovsky@oracle.com,
        sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de
Content-Transfer-Encoding: 7bit
Message-Id: <A93A19ED-0121-4E88-B24E-1593BEBD3384@oracle.com>
References: <20190214104240.24428-1-jgross@suse.com>
 <20190214104240.24428-2-jgross@suse.com>
To: Juergen Gross <jgross@suse.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 14, 2019, at 3:42 AM, Juergen Gross <jgross@suse.com> wrote:
> 
> When limiting memory size via kernel parameter "mem=" this should be
> respected even in case of memory made accessible via a PCI card.
> 
> Today this kind of memory won't be made usable in initial memory
> setup as the memory won't be visible in E820 map, but it might be
> added when adding PCI devices due to corresponding ACPI table entries.
> 
> Not respecting "mem=" can be corrected by adding a global max_mem_size
> variable set by parse_memopt() which will result in rejecting adding
> memory areas resulting in a memory size above the allowed limit.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> Acked-by: Ingo Molnar <mingo@kernel.org>

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

