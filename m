Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD2BCC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:49:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67EEF20811
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W4Df7r2y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67EEF20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9A246B0003; Wed, 27 Mar 2019 06:49:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4B546B0006; Wed, 27 Mar 2019 06:49:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B37D86B0007; Wed, 27 Mar 2019 06:49:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 957526B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:49:07 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v123so23037429ywf.16
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:49:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=SmLSNYZJIL19h/WzSX3CugM2fcl+DeXJ38qk+ETQLPE=;
        b=TaSeYbpZhqFyX4Tpr/cQ0NKpPxRf2qLs4mTZYJnlma9Kjm4XknfyleO+qquD/znLML
         KENHtM09LmRFVNE4qGHlYhRJZMjM65+MKp5zKvRhU+urZW//yqtD9OMbo+b9+XyYtkvt
         bMpRPlSQ8SZFOCMMFE334cOS59v3r3QpS9ybar+F9qbV8PT5QBp00ydaBbnbcmOAlhgw
         kcBdkWj1sd/jcyOjobeYNF/XnWln0H4E6zt0phL1CfOHPpHYDPSSNhuZOZLxNVvYBiTP
         RfPu3+XfWXQg4ifJ7oF+CFq8T7lYN7BNmw7yYYYuDRdm3dCqAgGXHSNyO7SrmAx5DnKn
         HlFg==
X-Gm-Message-State: APjAAAVddyiV8Ajd1l5gCcRHiPzLpZhSsUGkQUv08o4Qlay7pT/F1Khd
	PgVQEM0cvk1wy7qhZoaijQwtSM5so1kheSOqMIEIzgfMWovzLwAOOkkT1nRKKPkpIyf6OSQJgkU
	7WO+fbEnYnL3dgHc0kFFsVUxzq5nAKuuMQ22xKCG8Fw/0cwdrurZawb0pNmJsZ9lPTA==
X-Received: by 2002:a25:870a:: with SMTP id a10mr28935014ybl.339.1553683747260;
        Wed, 27 Mar 2019 03:49:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGzS/66Do41qq8kRpM7cQkhwGOppE0Zgz4bsAS2q6xuKOpzyCOHe5G91hWkxpbdbkp4Plx
X-Received: by 2002:a25:870a:: with SMTP id a10mr28934991ybl.339.1553683746723;
        Wed, 27 Mar 2019 03:49:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553683746; cv=none;
        d=google.com; s=arc-20160816;
        b=jz6S5Y+Q85xeNWQI1bjc/9UREFYbbP41y5ub5wmfWjWcSKrxGPOqHWYkF3emNrkCkI
         2y3M/3+qwa6xJd4Mg3fc29oe9br61FplgQ7oXtgUC+n3GPqGtuZJ80qv7DrA/9VB3Hco
         SEXaSpHHAMyRDt4/hjlhva8xazLMb+yCcfChthp+puxkR9GtBZbKAfUorah0EVhfw7Y7
         RF5HRqmyf/H3H4ojzAVfKN3/OKnAf3FnIRT+Ypdn8upMB21i3o3+lxLJOXT3Vdc4ZIdp
         odXQy641Xk1n7Jn8jYXrToI5e22Y5XKnYfVmoORQvk+wudpAV/25x3P4vRJGRiZ/GDjG
         Yz3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=SmLSNYZJIL19h/WzSX3CugM2fcl+DeXJ38qk+ETQLPE=;
        b=l1w3Y3Jx3o5OMpM8ublkDiOamqio0xTsrpN+Qvkb8JY6hCnNK+Xo/1qlKn11vik2/L
         1516kYbCd2SUmsugev3RyeYz0RjxprCm4cyNlbdIa/ycCrnWR6HVohaVFlx07nKuh4OL
         Ik5qsRdF0OBdsfOJCNgD8Gk0D+NYsTxKMwbZ1TDRWzlCWLjAHZ8NHXk4RBz0fHNbvNNa
         ABMgYkPFTk4V11sI3zTbF/ag1Nb113vVByGFkHyOSgDZhBH5r7aDf51/pPiSKeUk2hDA
         /OrOkgzji1ADVN5EBqlliH0JSMDmY776D7P5JzbnNPMDdh9UDrX/imU1mCTUjNZWt8FD
         4gXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W4Df7r2y;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 204si9352512ywj.98.2019.03.27.03.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 03:49:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W4Df7r2y;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2RAhs5O075129;
	Wed, 27 Mar 2019 10:48:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=SmLSNYZJIL19h/WzSX3CugM2fcl+DeXJ38qk+ETQLPE=;
 b=W4Df7r2yWFC7z25RFrRE+EleO2Mo3CQtRyUUgshFJx426p2KS4i6Ipj4Qt/kY2Ead3fl
 ZYbeurhT48qUHyEEeoaeiEIOI7oZseOc7Az6Jvt22E1m8hWOAXWbUVBOdj1HzGdec57D
 xfW8Rq5T/Qj5IRnWWk8xCkrWdc+2Y+U4xVF7UnrDs4+PmPUC2a/7HZ6tmSExaRs5jttJ
 2PcIfwKCuNciutdjbCAe+w//yRq8fvj3Woz1uv5baaOPzpogv3Alb8AnkteeqK1v1zOP
 Rxq4+P+J9kKMk/8ViTvKNRTBQE7CzEUAKj13xuN+eitI7QTrv5GQThL2UIxNfYenEpoG Kg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2re6djft26-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 10:48:49 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2RAmlpt014029
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 10:48:48 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2RAmh5B009536;
	Wed, 27 Mar 2019 10:48:43 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 27 Mar 2019 03:48:43 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: page cache: Store only head pages in i_pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190324030422.GE10344@bombadil.infradead.org>
Date: Wed, 27 Mar 2019 04:48:42 -0600
Cc: Qian Cai <cai@lca.pw>, Huang Ying <ying.huang@intel.com>,
        linux-mm@kvack.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <D2A51D2E-81A5-478A-9AF7-C08F85C5C874@oracle.com>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9207 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=824 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903270076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 23, 2019, at 9:04 PM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
>=20
> static inline struct page *find_subpage(struct page *page, pgoff_t =
offset)
> {
> +       unsigned long index =3D page_index(page);
> +
>        VM_BUG_ON_PAGE(PageTail(page), page);
> -       VM_BUG_ON_PAGE(page->index > offset, page);
> -       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <=3D =
offset,
> -                       page);
> -       return page - page->index + offset;
> +       VM_BUG_ON_PAGE(index > offset, page);
> +       VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <=3D =
offset, page);
> +       return page - index + offset;
> }
>=20
>=20
>> [   56.915812] page dumped because: VM_BUG_ON_PAGE(index + =
compound_order(page)
>> <=3D offset)
>=20
> Yeah, you were missing the '1 <<' part.
>=20

Is a V5 patch coming incorporating these?=

