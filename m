Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A09DC4646B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 13:55:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14B3D2089C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 13:55:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5OHMUXVk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14B3D2089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A279B6B0005; Thu, 20 Jun 2019 09:55:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B0D98E0002; Thu, 20 Jun 2019 09:55:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 803178E0001; Thu, 20 Jun 2019 09:55:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2B06B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:55:34 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id c5so5278020iom.18
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:55:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=TUqk6TA6h8cuXkt1anOl1PRT6/k37KqmrA8po3+sGy4=;
        b=jGJ9fo852YXLrD38rkQclkPMhqP9Qam2otZxMSUDA5mwh7KGTrzTvv9BuqdEjOfsJy
         a+6i9xjr8IRRkECbojWihDerzrblglHBa75DuSZPQrrTdxzpsT/5z20lDwhGTuvUrlO2
         r6hN6R+nTXjixFt3Ez6mcwf4M25TkF+B6BFfwn31ZJcAzWxhgglug7c9iiI+O4IT/cTq
         NUWHfcBUnVDbHRTf22p+bOPAlruZ+omI2JqEzLF9EXbgagick+vbK9Fz4OgqmvdsuCK8
         T6htht+svhqMhWhJehpB5z8miDc/imMtMTECUB4Z/AxFq5Y4V4Hj4I0Ud93SpedWDHu1
         kDfw==
X-Gm-Message-State: APjAAAVLKg5M1log9hgRsGDdxynfDJmoc6ygr+p8/itfxm0qLukR1Jcz
	UYSXTiyVkiLYtH1GL/RrzhoQo+vwK+AwxX4a1Ouz2KhlkKxNUfVj9Y71eNSckONpPb30NumLSTL
	dwRzSRPwCt15bz44qmgIHZPwarHc4xjQFB6GXmRV7lMUhURn49W7zI+eFVOTWk6qg5Q==
X-Received: by 2002:a5d:89c7:: with SMTP id a7mr9768161iot.194.1561038934110;
        Thu, 20 Jun 2019 06:55:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQ6NB286dsZZhAuThcIONvK8NW60ksLv1gUPmWK6UqNPMLJZY5ke7MNRD3ydlFZjaa35mF
X-Received: by 2002:a5d:89c7:: with SMTP id a7mr9768105iot.194.1561038933395;
        Thu, 20 Jun 2019 06:55:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561038933; cv=none;
        d=google.com; s=arc-20160816;
        b=KburM2acE5/2Bf9YHGudAeg94I0Dsl5jVmt2OtMLPtB+vpFwTBQgni6QIOyyFlXLdr
         bbDuk6ch5ci/0oZjOQBRSb6IzeKV4pO7CVhb3mnVUZskpZToABcWZceMM94uMaT4wvTx
         PHSUA/mU66ADrc4SwKVlPjWyRgPEkGXf+G3ttsnd5/0OwRi3sFKUTb0NXir7deH5Zfnf
         911HoXWJkTtGiN4lWS7Cul9YMBZ6VfEoK6q1bhwdwVYWkyX2vrbE6mztwcD6UQlD4Aud
         RaoC5ashbh7hXTae4PQwpQ7E/xINKSHCTzpx+shOBG9A9/Dr1/q5sR+vsTNy9pKzZq3Y
         7sYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=TUqk6TA6h8cuXkt1anOl1PRT6/k37KqmrA8po3+sGy4=;
        b=vM3Rco0OuF9fxkzEd3+d5k4IAY8AsQEOd0E5Ks1G3z6cAVhldn4ZMBEVz5MD2uqpRG
         leH/HdIqig3a8PNxX2E58IcbPAVawaZ11RpgT3f9RDwRre22YFt4fU9hQ+63G5rEt7Ct
         qPdGrC1LzePgFAFtQFU+qi+NRPH8um8QitwsDrrO69hvTnFlwrQfhSt7l1FdkNs1wpJh
         lBuVP4M53gdDeOPIIwTEFl/a4xuDud5PRIV9ryZgc1WZkBkNp9ZMNned1rTPi7DvupGI
         5SrapRhZH6BfO53qxjJmCEnW7lDHFARlL4XgEBG5VS8Xs1/n1O68hzNzfU7ExH6eF7qN
         kj2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5OHMUXVk;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k65si27280690iof.58.2019.06.20.06.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 06:55:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5OHMUXVk;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KDnVsb019117;
	Thu, 20 Jun 2019 13:55:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=TUqk6TA6h8cuXkt1anOl1PRT6/k37KqmrA8po3+sGy4=;
 b=5OHMUXVk/A9xwci8pfm1BD7snegaK6K+u/V3ui4gSKspj3t01Oxd2n3mf+7VSmWB9/ZK
 Ve3RZOq1uN6AX/zSzeoM6P2Yh7YRlh95BM8r3vxYcDKT1vRlO/7FMZVlGxQncelpC2TB
 xLSWnMPo4nZ5FiHRrftmaBXGGnQkgoKXjwLpu375DmeA9E1odPAHfahUvOqVo8i4a3Lu
 DTg0uk6pmOBffPszry/cJUc9OOS9dD49jAW2Z3//1qo8b5xRJ+KOH0NaDugcAYJFcB+w
 jObRZ5UvRnX9HMBEtIPfDxk/W93sRwqu3sa+nl/3hsjHADntDb753+MTHl45xG83Au1N bg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2t7809h8qx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 13:55:29 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KDtITd109552;
	Thu, 20 Jun 2019 13:55:29 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t7rdx66px-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 13:55:28 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5KDtQNv031694;
	Thu, 20 Jun 2019 13:55:26 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 20 Jun 2019 06:55:16 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 13.0 \(3560.7\))
Subject: Re: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <B051CE4A-063B-4464-8193-93C9F1D0A0A7@fb.com>
Date: Thu, 20 Jun 2019 07:55:15 -0600
Cc: Rik van Riel <riel@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Message-Id: <5D2D066C-3E70-438B-9373-A65EB65D701D@oracle.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
 <20190619062424.3486524-7-songliubraving@fb.com>
 <9ec5787861152deb1c6c6365b593343b3aef18d4.camel@fb.com>
 <B051CE4A-063B-4464-8193-93C9F1D0A0A7@fb.com>
To: Song Liu <songliubraving@fb.com>
X-Mailer: Apple Mail (2.3560.7)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=894
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906200104
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=939 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906200104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 19, 2019, at 8:10 PM, Song Liu <songliubraving@fb.com> wrote:
> 
> This is not truncate the file. It only drops page cache. 
> truncate_setsize() will still set correct size. I don't 
> think this breaks anything. 
> 
> We can probably make it smarter and only drop the clean
> huge pages (dirty page should not exist). 

It sounds like I will need this change for my THP work as well for the
same reason; once a RO THP text page is in the page cache, if the file is
marked writable strange things will occur.

