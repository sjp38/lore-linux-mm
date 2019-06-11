Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8B0FC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:23:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61E82206E0
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lyKS8EPY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61E82206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D99436B0006; Tue, 11 Jun 2019 15:23:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6F066B0008; Tue, 11 Jun 2019 15:23:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5E4C6B000D; Tue, 11 Jun 2019 15:23:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA786B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:23:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y7so10275141pfy.9
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:23:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=w76MFlwvNKhZqtHwJRAkKoCnG/0YMyc0k1SshiGhIFo=;
        b=gt88qQG2SVVjBlLaojy3bfN4Z5FTT+3zFBbe+ZgZQIg8ORQ3a9SeFZc27zehneBlFa
         oIw6JpEJZq1i6TToWwhZioc1QGpxb8cNkY8FS3MLMBDyQ5jBY/8LIywjC9ybKFaLiGl4
         NJdFMHSVAcZOGmmYODVT+bKbKduIU/ZIN1SkgzsT0eACJ7mKQHeUetzPkekqJzZIhZhQ
         TfDvOQ4PNmhMar+Ko6A0XFk4/ZHsJjwJ0gxWeUkItb9lw9JHiUq1c3FlvSloFDbJ5q3Z
         UD2nr29qa0IH5fgl4ypluKQwXW4Vg2qkCJmLIUIogtN+OqjY6ofaA0mw08LLfGuIYxlt
         vtCw==
X-Gm-Message-State: APjAAAXJzXP08eju5c85u04OBO9AyuVL1VU6RqhpmX+todip/vIq49BP
	J+qaSBLTSXrZ8Ytsg2s72RQmkw0j2WN+6l54BGSwH8+YqaQJEpbAEJjPVm+zILNJyhKOl9iafc3
	lN618d5bOjDEaHo7NPotAx9hvoLiUqDpZSzM5xzLUhvEONIh0OLtvDLIZY5sOov7BlA==
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr28136144pjp.80.1560280983158;
        Tue, 11 Jun 2019 12:23:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYOYRG9S8k9RV9AKHRLk3dhs1+HVN4N8Dd3/5s86A+G06UJ4chce9YJHu5AEvTtQqFDWYb
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr28136088pjp.80.1560280982446;
        Tue, 11 Jun 2019 12:23:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560280982; cv=none;
        d=google.com; s=arc-20160816;
        b=f4/NOuGBgmPRxXeA1xwoL/Fwn5zjn62/so+H1fLdu7RMolZ1Ka7i3u2NnlmhjybQal
         SGntbEJXSZQ+DPaOcY2ggjTHjtnsIqCO5ptEEswxoSDmTXQmpEEI/4ihNB0lNEX28YRW
         oP1tPg4BWcLr04RnNS0WbHrZmAPN9BUNETcLpb+s2hkYglqVf2XEvC0JGV/z6ev0oW1O
         MhT8B6+S4sEKHAnzknEaIohz7uC5PUzkYKZDZjfT3EnhABMX+oKbtgaIo5Y2pp5EtC8B
         Zx3KypMACe2Do4PkNGrvoAk9mytXtQzGnrAu5/N4sJab6//789xtnxU75lGseTy8rglp
         K1PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=w76MFlwvNKhZqtHwJRAkKoCnG/0YMyc0k1SshiGhIFo=;
        b=wp4d2kFO3mvOx631Bw1I2OTcNwEYAhALksderuAmTr9A67G5lkcGrcK6leaYrEGcVA
         S2zqLVD5eD0fiycTvl3AsE8sDWH0BVXou5skke9fBcadLKKF+/Cpcz8LyPqN/kBwEZWz
         IPMZonKETKIbo+F4+0cAI10lvqmNGXKkcgKnKzF/ODWazFULb3cPzhSnrsR1UGqEQk9+
         bi4vAfnddgUL9iZjKbUG1ornMYjKsKHXN6207hu/Sc4fz1a3on+AjE/p/rZgK5+/dAfd
         0MlN+GrhQbdYO4FzCSWvcAIGBvIazR3KdgHCcJTOXR723n1sWXG+7zqTZs+Ih16741Qk
         KPwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lyKS8EPY;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y82si14931752pfb.58.2019.06.11.12.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:23:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lyKS8EPY;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJEZF2148131;
	Tue, 11 Jun 2019 19:22:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=w76MFlwvNKhZqtHwJRAkKoCnG/0YMyc0k1SshiGhIFo=;
 b=lyKS8EPYtHVV69hKRhxbZ6v/wFBGKQdRKMFGV75IF5Ly8f4gx63IiVxb73DDl0+AbJmm
 CdJvjrw/0ON/ZIZZDVd35XGZGYcOr6YUm+1+c4fVLRIbczJKiRbuQsnnHiPmGT32HeMI
 yPgGH8BMtCJNcZGgeKqNc9zQymR1ehBB6hPaiWuv6zwujyXlG+0dhRPfn5KJWPXSEiiY
 86sDUCAy3UJthE28Vd8oZg8tOUjk962pLYKGbyc4eo09yWsg8uiILcyco70X+7o/NVSy
 0l1s88pzby/RchV3V0Lwt3GnLLHzR1ZcAlylaXvzBxfsoWFdW5Th0f/oeh7B7jYF2E0Y MQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2t02heqdfr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:22:42 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJLICV095933;
	Tue, 11 Jun 2019 19:22:41 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2t024uk1m7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:22:41 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5BJMawp024319;
	Tue, 11 Jun 2019 19:22:36 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 12:22:36 -0700
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
To: Christoph Hellwig <hch@lst.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-2-hch@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <9145f3f9-4e14-df6a-87f5-663ad197e96e@oracle.com>
Date: Tue, 11 Jun 2019 13:22:33 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611144102.8848-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=920
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110123
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=962 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 8:40 AM, Christoph Hellwig wrote:
> This will allow sparc64 to override its ADI tags for
> get_user_pages and get_user_pages_fast.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Commit message is sparc64 specific but the goal here is to allow any
architecture with memory tagging to use this. So I would suggest
rewording the commit log. Other than that:

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

>  mm/gup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..6bb521db67ec 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2146,7 +2146,7 @@ int __get_user_pages_fast(unsigned long start, in=
t nr_pages, int write,
>  	unsigned long flags;
>  	int nr =3D 0;
> =20
> -	start &=3D PAGE_MASK;
> +	start =3D untagged_addr(start) & PAGE_MASK;
>  	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
>  	end =3D start + len;
> =20
> @@ -2219,7 +2219,7 @@ int get_user_pages_fast(unsigned long start, int =
nr_pages,
>  	unsigned long addr, len, end;
>  	int nr =3D 0, ret =3D 0;
> =20
> -	start &=3D PAGE_MASK;
> +	start =3D untagged_addr(start) & PAGE_MASK;
>  	addr =3D start;
>  	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
>  	end =3D start + len;
>=20


