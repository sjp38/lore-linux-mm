Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33E3FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E75872146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:09:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LZuDjeiK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E75872146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF0C8E001A; Wed, 20 Feb 2019 09:09:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 730CD8E0002; Wed, 20 Feb 2019 09:09:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F7EE8E001A; Wed, 20 Feb 2019 09:09:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 207978E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:09:42 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id e34so16918809pgm.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:09:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=rbJOGLjYWQW8uYVwZDy7W7Nqo1LJ1spRGcKE6/GOpbg=;
        b=o3tLpcz65plKBDMaKFgiruLbqRgYF2Oc+dXTjrlwV74QXsU/eYnI1F1hb7gAh6teXG
         QwYEDN0PI0vu8u0Wj/bBQ95d4kQBjJDeicMvypVGfd0oeEDogsu0T2KDfyiKk2n1oKZg
         5AdX11F59jgBCYQ/2IQHKE6ZfnBH0Lc6E/+IuH99v+u48hMS2VLD79tGGVTl5ZKAGYgN
         fOQon72MOuam1343o6bub+wfRldEckkKweLHSiYrj4pRrkxpkxRUy3Hy1s+9hhVezp9/
         xnvX/Zgx191MQg+eQ/RFbMz9x1WBt3m+2W20U1ZS7n6wGdlZDolWnWxZjFXkeZt8KVus
         NxTg==
X-Gm-Message-State: AHQUAuampY5bRhWAvaxrgSv4HzQwxKTxpJ9Jx/mH21sdSX0YJK9eS34z
	RQz2vTWzlOSH4j8KeFyjMQ7KPCEx53JwjCyIs51TXFVwNcGEDVIurwIYjD1Cnh2DIaSHasWnRFh
	eWVztNUmS105cpI0gG3QNGgPYEoLHKjq5AoQ0Q6RP8mKi7SHEnhXZcLae2TfsyghnfQ==
X-Received: by 2002:a63:4a11:: with SMTP id x17mr14085270pga.376.1550671781715;
        Wed, 20 Feb 2019 06:09:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbMulGwNkzg3HUh3ktU7a7tiaH7dw+AwG71s0fnqK3CcaD/TyxLw+IqKnI8qNM8+HNEzsgR
X-Received: by 2002:a63:4a11:: with SMTP id x17mr14085222pga.376.1550671781000;
        Wed, 20 Feb 2019 06:09:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550671780; cv=none;
        d=google.com; s=arc-20160816;
        b=kX3RDLJZhR4qJMXiTXH/U90Vx7oLzqsJ/nYmaqy5Gk5xTDJO7TPv8ekRLqtgRM2igO
         Ah6FzXQMN/3bsCID7hpBg86jGA1Mn8F4jY0SpRYfffBH8aqqYHUM81YNvE3RignAmT1C
         DOd0uO9DJHbZcf9Bc6Bm8cja3zwOynnZkVZnoSyw0rvptv/6QtV6/lHHb2FaAfZxwoPy
         IPpSBBG3WRDxCv5gJJqppeWx4yyXk3fjlpw2qcyao7+7ed1+RBdYWBSfCoKHZ0Rjg6P1
         xT/gv/K16oRlEA6dCijM8d4c99/B6gHiYQP2MKr0brOAnNlcVJjxfz7amsxAUZpdH/le
         GLcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=rbJOGLjYWQW8uYVwZDy7W7Nqo1LJ1spRGcKE6/GOpbg=;
        b=O68cKc9aGTbls7jH2Zup2w+692zEb7HFPcbaUiDZidTUvMuW6BcO/DlKUOYW3TEo6+
         swCgklqXivV5RZYKxhDM2P1NjOcz1Qn3lZlFDhzO2An8d7QimNJ3yGNOdMw/G8P635Wm
         jRBoRNO8K1rQEbZcQfNASA+RE3185M03nfKo+x7n5gH7MxL832azfpHxLJRgANlwYiKI
         QfxDQbqEg6ELsNzgMPwi2Z/d6WLNbyk4vzjPNY/nwXWltRlOQzGEGZ09nAyUg6G9MeLN
         3ZzwZNSsaHXR2q2rncok10SW2jc+rS6UvyIUXSsGhTJvMvlmd8fQiKF4ED6sHxTOhWyB
         EnqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LZuDjeiK;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d1si17984517pll.283.2019.02.20.06.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 06:09:40 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LZuDjeiK;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1KDxSls140229;
	Wed, 20 Feb 2019 14:07:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=rbJOGLjYWQW8uYVwZDy7W7Nqo1LJ1spRGcKE6/GOpbg=;
 b=LZuDjeiK+IgpTj0JZgeWqodJlp7Ysv2uE3peX/GVv7OUjZPoQ3QCEU3xjaAPGGbRfVey
 3x7u3cjCRQQhiq4TO9PgFCGMH5JFVbO0SK6Cbifp15nlYxoxn+d9XsHg26EIADRHy+JF
 fFVjsajYyKbEJuO73zBhQcykGEM5bwQ9vg27T0jzZgXMjCThqLdJJGQOaafFVjZZB0rT
 6hS8B4C5MTAnMsaoqXHtmi57tWIKkgbXbFD2dN6E5BCySPexalTWsPrdnFLvBA5XSGLq
 DxDLuDKUo9E5DQUOwoxImFyvUqsMVymrzu3jzJKcLb3YuaSvjRAfsHUCrEO2hq47l3pS BQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qpb5rhmqd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 14:07:33 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1KE7VCQ021829
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 14:07:32 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1KE7UW5031308;
	Wed, 20 Feb 2019 14:07:31 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Feb 2019 06:07:30 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190220134454.GF12668@bombadil.infradead.org>
Date: Wed, 20 Feb 2019 07:07:29 -0700
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
        linux-fsdevel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000152, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 20, 2019, at 6:44 AM, Matthew Wilcox <willy@infradead.org> wrote:
> 
> That interface would need to have some hint from the VFS as to what
> range of file offsets it's looking for, and which page is the critical
> one.  Maybe that's as simple as passing in pgoff and order, where pgoff is
> not necessarily aligned to 1<<order.  Or maybe we want to explicitly
> pass in start, end, critical.

The order is especially important, as I think it's vital that the FS can
tell the difference between a caller wanting 2M in PAGESIZE pages
(something that could be satisfied by taking multiple trips through the
existing readahead) or needing to transfer ALL the content for a 2M page
as the fault can't be satisfied until the operation is complete. It also
won't be long before reading 1G at a time to map PUD-sized pages becomes
more important, plus the need to support various sizes in-between for
architectures like ARM that support them (see the non-standard size THP
discussion for more on that.)

I'm also hoping the conference would have enough "mixer" time that MM folks
can have a nice discussion with the FS folks to get their input - or at the
very least these mail threads will get that ball rolling.

