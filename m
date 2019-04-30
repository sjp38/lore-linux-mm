Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41DD9C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03399205ED
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:12:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="b4w9PYN0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03399205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B3446B0003; Tue, 30 Apr 2019 08:12:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93CF56B0005; Tue, 30 Apr 2019 08:12:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DE9C6B0007; Tue, 30 Apr 2019 08:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 442636B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:12:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x5so7001764pll.2
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:12:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=sDfolhPoDtLY6nBfVuOfoHQP4qFaH5aAZKN77BieGGk=;
        b=W13Omz/XVA9F3SrJYUo3eVWBaigBOZqRXd72+jCSctdM5dXZJDqlVZTA5Pbg66opNL
         Q0uDJDFDyFm3v1l+MZEtS7QVigzo/2do53H9aU0g07OlvEvMJrUFJBXZ1PAQVZWe5zH4
         ttkFQIhbGnzzq7H2U3wId4v7M+pb/585A4m8dre0cdiyPKoKugcd1Vtv1yP/jGvrSVQB
         Gn7VsMViY2ZxhQEUE0FfOD8t3y6E5dTlUqEmamDlwJ2RQ3qwK8o5Ak9FpDNzbiSFr6QG
         uwO7FsrLHvh2siBDvo0Svp49SIuc3RPAPY2Bpl38i3IwStECfGzIiyR73cIEYfNsqS/1
         tdpQ==
X-Gm-Message-State: APjAAAXBvuhAdy+o7WDAO5xxv3EQmWEGUz/M0c5Kj3I/myZMg7Kww3zL
	SPqG/oX87CL5sHmJEC74aCJlpYlF3/sOTCYow2P6mRGG7Awo2CpR4gI0z04baNtbh0TWNelsVrN
	7kE8toQhtVv7+n5+mFVqwCckoB1G5+M1YwESY+Yovg6yyOXb+AfEWfRKHR3WrGj9bdg==
X-Received: by 2002:a63:c14:: with SMTP id b20mr6973819pgl.163.1556626346818;
        Tue, 30 Apr 2019 05:12:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY9Tv7YhXfr8kGjBrv65SUMcf5WW+X40H3FG/DiU9pT8ypJ6FkTuhORFiCzFvMOBkLHXO0
X-Received: by 2002:a63:c14:: with SMTP id b20mr6973739pgl.163.1556626346041;
        Tue, 30 Apr 2019 05:12:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556626346; cv=none;
        d=google.com; s=arc-20160816;
        b=ypBJ5MQ5315sfDogl5VKFaRxsyxHjkDeKkOXv3wcTsL4KD/F6xkPAbOZaeiUmCs9jS
         LFthg0uvAum9X8F3221tS4nDHfz4PvoOFKkPSi6H6E/kIrhiAmzxAhUG8SNAW6wKh0yD
         LeEervLk74VUQcM3USRSEpLzqOSZhohoS5vXbieLnV75TfjdvDJGmziABV8JuHRpNauP
         /s/S8iGRXDE7Js/Udx1wTSERXkHpV0EeDJ+Wji3ByM4xfUtQnyzQ69eB/WTRRkwMK9rL
         ND4TgMJsKiyJyC+mwGbCLhuZA3g7bDBfRE2z2U7tFcic0MglfqbxmCYnBHj/E6WB2BEc
         feiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=sDfolhPoDtLY6nBfVuOfoHQP4qFaH5aAZKN77BieGGk=;
        b=IjOV0mwfiG71NHPbq4VGur5/MKtVXC6hAp0yqXFKW7VumjEmvZfXcoEVoduZpbNeb4
         sAeoNH1oU/3GNuig2MHOuZUbl9gIdtUiAQ5s4ltNq4kXqhHiARHpAA7b2AyakBwGPsJA
         A9Y0I0RImhWK8rCopEjh/3zd8RlX5HNGWHeT3yhYD3l3sTreKjiQeQmOQ0F5biwA4wZs
         tP1ZkqaZhMPjvftjh7CVKTCnz6flNQLf67KLUNqDMzc3OO9b7cmbuwLyqqFCHAD6bW9t
         bJljA8M9WPQ9jNVz2D8UQB4suy+4jm6+ZDSd2Q+PXvrpMSaYak2eWwx2FElJ9asYEKRr
         rXnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=b4w9PYN0;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id z4si35936732plk.385.2019.04.30.05.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 05:12:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=b4w9PYN0;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UC4RjX136070;
	Tue, 30 Apr 2019 12:12:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=sDfolhPoDtLY6nBfVuOfoHQP4qFaH5aAZKN77BieGGk=;
 b=b4w9PYN0/nvmxM8Bh0m5KG8BUa7Y1tT5y7CfUhUw2p4snONZvCCH3UjvyQizm6ttnvjG
 NUQDiAh7dGzX9n4uAx1jcqOR4unN6cs0wGHPVMlQLSllTuukzRS6YlbJRboLsKGoAfyw
 sfNrbrcgEnWXx9S72KUkms6474UZM9/2vsPpigrAzADTUPfHZPuvpCzTc29/Lv0ixH7/
 d/1JbpaeKT6sMX+8GYY8jywqMlZ5Dc66NZOnla1S76s7AkPQr5USnXPLGRYcjOBXAUuS
 FJjBPQT2JGVHb/20oafkRnOZ0M8zn/hxZZmbIrI5rMHzMQ60hB8wRyqsQz0dAVorMpOj jQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2s4ckdcacg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 12:12:14 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3UCAmkP161390;
	Tue, 30 Apr 2019 12:12:13 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2s4ew16sut-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 12:12:13 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3UCCC52029414;
	Tue, 30 Apr 2019 12:12:12 GMT
Received: from [192.168.0.100] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Apr 2019 05:12:12 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <CAPhsuW6uDeXrRU9pd-kPOzjJn3DVdx0O5Lny_hpyQ=Fpbhg4gw@mail.gmail.com>
Date: Tue, 30 Apr 2019 06:12:04 -0600
Cc: Matthew Wilcox <willy@infradead.org>, Keith Busch <keith.busch@intel.com>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nvme@lists.infradead.org, linux-block@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <C39B5A6C-2898-44DC-B11B-017908261C09@oracle.com>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
 <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
 <20190220144345.GG12668@bombadil.infradead.org>
 <20190220163921.GA4451@localhost.localdomain>
 <20190220171905.GJ12668@bombadil.infradead.org>
 <B53C9F2D-966C-4DFD-8151-0A7255ACA9AD@oracle.com>
 <CAPhsuW6uDeXrRU9pd-kPOzjJn3DVdx0O5Lny_hpyQ=Fpbhg4gw@mail.gmail.com>
To: Song Liu <liu.song.a23@gmail.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=877
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300080
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=902 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 28, 2019, at 2:08 PM, Song Liu <liu.song.a23@gmail.com> wrote:
>=20
> We will bring this proposal up in THP discussions. Would you like to =
share more
> thoughts on pros and cons of the two solutions? Or in other words, do =
you have
> strong reasons to dislike either of them?

I think it's a performance issue that needs to be hashed out.

The obvious thing to do is read the whole large page and then map
it, but depending on the architecture or I/O speed, mapping one
PAGESIZE page to satisfy the single fault while the large page is
being read in could potentially be faster. However, as with all
swags without actual data who can say. You can also bring up the
question of whether with SSDs and NVME storage if it makes sense
to worry anymore about how long it would take to read a 2M or even
1G page in from storage. I like the idea of simply reading the
entire large page purely for neatness reasons - recovering from an
error during redhead of a large page seems like it could become
rather complex.

One other issue is how this will interact with filesystems and how
and how to tell filesystems I want a large page's worth of data.
Matthew mentioned that compound_order() can be used to detect the
page size, so that's one answer, but obviously no such code exists
as of yet and it would need to be propagated across all file systems.

I really hope the discussions at LSFMM are productive.

-- Bill=

