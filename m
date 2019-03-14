Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5231C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:26:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 804632077B
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:26:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WvTI0PsX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 804632077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17BE66B0003; Thu, 14 Mar 2019 16:26:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12AAF6B0005; Thu, 14 Mar 2019 16:26:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019B56B0006; Thu, 14 Mar 2019 16:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A08166B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:26:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t4so2750705eds.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:26:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=0MnBDGPgz9vC3/2m+t5FiE97iY9+rd0eyr2X/THTWCU=;
        b=EqSfPEk5lJtBM0Mnwc0TcoSZMAafjF7ztmqw0y6FSK8OKLFl9ANG96vIZIlictC98Q
         LQBl+AWhzgUbdNxYBipOIcStF3EJSmcRBf0yRVNEEUeolZf5hwaWB0uj62r/MguKg7bO
         Oov+OcTLSR63kD27MgMonhtwIN5bafGYPIbhLIKIgoAuFukiMTIcV4Oa1uXOv1xJ6h/g
         iXN/mrOhoEuLmjcQn6E5DFsPRx4enBvgNtAmImepXgQROXmeWnk5bjxhtae36CnpwILk
         NXV9MENEx52GvlgHXgqbug7YZxsnSEgarBK6q1Xu8YXMK7pTfuL7EyZK2QTo0ev7W5DR
         zwKA==
X-Gm-Message-State: APjAAAWXxMCPa66VplHyVu+enu9EaLvKmKXchJmOgoCKrz/pp5LmIc+V
	DqtMMRJ7IASZGRHtoyuwTGSuC5TT7TIYjY8u2NDsTuosODYC7V06cjIwVskRr3Ba+/eJBhilfaU
	4JMEv64nTO3ctYYQ6VH/vsJQoi3qWfRE/hhVeAShFHudtF6Zih4EEQBlbSP2sdYL1Eg==
X-Received: by 2002:a17:906:7c49:: with SMTP id g9mr34276590ejp.31.1552595165127;
        Thu, 14 Mar 2019 13:26:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3rvcz86W52S7+HEI96M97dEiwpIlwwf8RVb6tsOp0TtZBv/nMn9xyQucm70VCddgENxEn
X-Received: by 2002:a17:906:7c49:: with SMTP id g9mr34276541ejp.31.1552595164177;
        Thu, 14 Mar 2019 13:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552595164; cv=none;
        d=google.com; s=arc-20160816;
        b=COEL1YHKInnyha2pb420+6dyJ7oXLBhVhGWCgRkb2gTN7e1vKOg0CxOpAo42vcjtjL
         ApFLOP/JwofRr68/cv0tVo2C3O2eI3lucYGJ3dKjJhQhrb7jESs74lCB7g0E9ASs2vaQ
         X2N7U7qonvsZgUsrfqZADJeZuz0gTBHzgH/eKs577U/SLE68vZJ/wY7lKS0ly/Ozs1kU
         +hzsflbblb5+FmaWbEOLVlUDTyNh75IykVd/n5jwMm/q2pcWUCOcLWiYPdmn/GP/eGBF
         6k+pryHENnovJ2q3QpgBk8oT8Gqv9qQ4YpVF+qaEx/7tkH5T/aQlCgZOj8CM4TrkYz23
         IgCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=0MnBDGPgz9vC3/2m+t5FiE97iY9+rd0eyr2X/THTWCU=;
        b=E9nftc6lWsgPlbO98C2TxLtefCCKk5747TYr6ciQMCNiDFMCmzUa8RckTeeoo1YisL
         pIUxYJNqTmytpo+RCICV8O0CnHwSTz3BK4MMR/fwT+KzIOqhBhswmwwQzdZAhAVtwRK4
         UNDyDGbzfSx9uZ72GL0CTWDK8w6s2KW+YFTK4V/3NDfUBZvD5DsLB+rpQRY4zmYZVqI5
         Ih0YCy83VIu/7VLuataWZbG8OpJXunQOS7q57PxCxOp9nNKUKPNJqLNx8Ge91gyh74Pe
         y2KTPn1to/yzo04sLkr+9hSgnGmCsW/mZYie+084cxe8iCKUUYCYqoDF7otfpISjgzQD
         dRZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WvTI0PsX;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a21si43527edv.292.2019.03.14.13.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WvTI0PsX;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2EKIvGm101964;
	Thu, 14 Mar 2019 20:25:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=0MnBDGPgz9vC3/2m+t5FiE97iY9+rd0eyr2X/THTWCU=;
 b=WvTI0PsXF4pULFJO5AY+OrP4f7TWyMnozUbMBxSfn6wfEWfF6wEqMQcqlL6c463M/0i9
 a2oY4r4pgF125PMmmlYfCXVRqvV2n5qWJGbuPkI+KekW5jfqrn2+MlnrruNQt3BkmPaV
 Zn4ZPJh0zdhuUnmG/i+c+BWOO3r81X5UpAhfRfA3qvLvslvwmyvvoYQX/0QHB7hnn256
 moME0tX1Rmh0fnJyqTXdjG9UpF1+x9r2PddyLbTsR/MXhoud9d66SsJ/MOlvJbNfmI36
 ZkdJ9MdXp82PlvkwgllK5JH0Ym+XB3IDSXpoNELeqkTy/+omWXJ4iJaPPkDcCW/3YKGZ Ag== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2r430f3sm8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Mar 2019 20:25:46 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2EKPeKs006903
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Mar 2019 20:25:40 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2EKPb9Z032336;
	Thu, 14 Mar 2019 20:25:37 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Mar 2019 20:25:37 +0000
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190314133038.GJ16658@quack2.suse.cz>
Date: Thu, 14 Mar 2019 14:25:35 -0600
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Christopher Lameter <cl@linux.com>,
        Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christian Benvenuti <benve@cisco.com>,
        Christoph Hellwig <hch@infradead.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Chinner <david@fromorbit.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
        Mike Rapoport <rppt@linux.ibm.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        John Hubbard <jhubbard@nvidia.com>
Content-Transfer-Encoding: 7bit
Message-Id: <3AF66C8F-F4BC-4413-A01C-3C90A3C27B28@oracle.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
 <20190314090345.GB16658@quack2.suse.cz> <20190314125718.GO20037@ziepe.ca>
 <20190314133038.GJ16658@quack2.suse.cz>
To: Jan Kara <jack@suse.cz>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9195 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=629 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903140140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 14, 2019, at 7:30 AM, Jan Kara <jack@suse.cz> wrote:
> 
> Well I have some crash reports couple years old and they are not from QA
> departments. So I'm pretty confident there are real users that use this in
> production... and just reboot their machine in case it crashes.

Do you know what the use case in those crashes actually was?

I'm curious to know they were actually cases of say DMA from a video
capture card or if the uses posited to date are simply theoretical.

It's always good to know who might be doing this and why if for no other
reason than as something to keep in mind when designing future interfaces.

