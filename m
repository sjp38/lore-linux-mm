Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71183C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 04:47:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AE9020833
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 04:47:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AE9020833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D556B000C; Tue,  9 Apr 2019 00:47:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACA2F6B0010; Tue,  9 Apr 2019 00:47:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BBFC6B0266; Tue,  9 Apr 2019 00:47:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC106B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 00:47:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l19so7885040edr.12
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 21:47:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=Hp/Mjar2fyBTG6mBQbYoXGY63xbiLaxaJuAaBwfKfSs=;
        b=qlqiDqD6SJx/zV9Gi74eYDXVjVZvsSZLktsEH3TnMQcgmGgwD45ZWN3x3fgcarku7I
         QrEfYr1DfdzeM5Opr7K9+dYr07siLk9Q45t9Wu7/8QsIhaPFobuKeMtZBDZfAVNYgPWK
         Vwyi5n8l53xRY+Pf+eV0xYGKm/83vsnVzwYR/6SP5JLvx0dftsn3YQaM96St6vKC0dcs
         xRX0WWDzdRhV7wEpZy/Wqhmova/a8ra/3TqLCoWk2i516t0zsg7Dx9d9/JuLOD0bdE/Y
         gu49JilKHCPm074sydWIP/iENsT78tlVeX/tlpLCzFOIH39PHcCVTatuoe7ZxuvA59rR
         ye6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWJB7QzNw/RLQl0WPc8feukNt6cCDDfsvNJHVL1izGZqw5GyRNG
	d4HrieEpSofbf69K8h4ylqVS6oNMnY4f2a+0NQ9lweJ6oiksArgWk7CIu0d8MXmeOiQr7fsAEaF
	4m00qHTjBKBymzEmOiOXpm+LIVj/YTS9I4AIitAzswJseEoMEy98853L6IbpVGbAsog==
X-Received: by 2002:a50:fb81:: with SMTP id e1mr6704460edq.243.1554785232781;
        Mon, 08 Apr 2019 21:47:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzNeHpl1MY6bUDODJgeqGDZwzFGAumHB+uA/IDiQbS3CBnVt5bZteoYEHYXDW/uNC1Av9O
X-Received: by 2002:a50:fb81:: with SMTP id e1mr6704425edq.243.1554785232000;
        Mon, 08 Apr 2019 21:47:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554785231; cv=none;
        d=google.com; s=arc-20160816;
        b=xVIPg95t4+2XT576r7ix9tfONLKM1dwHGUo+rbRVRsc54zjjjdbJpsWtRafvmkVvU6
         sKbMLQnGmHPmy8CZ7DU++5V6HlmHhPTwrsLnqezG+RULTTjxmoW99Xq8IwHQ0oY+uhRK
         9J1DUitPc4zn3beM1amdrWAlmZa0eZ0BFX2ol+koyYnvqZYgd9m815tEE6ICi8wVhvkM
         K8uUL+lClAYJA3cdOCTgBti5fJrmp2e0O4fBjN4o+7TahjgeVb5mJuy+PasgctUKbog9
         7DqXEbFs1LAfzRN5282PKZxWH0s6/Z4Zz8jHqL6rkdHodrx5iEU+qMNNMjWCkSL5ePIo
         WMYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Hp/Mjar2fyBTG6mBQbYoXGY63xbiLaxaJuAaBwfKfSs=;
        b=mUyhJZPgSTVGij/Hke2ZmbYYTjumF/8+dIlADSRqasdeLYf9YJoBJwc8WQWbU4X9K5
         un1J5keqI3IK+ESCaJrirSiWyl/M/SxyjgPS9Zip5uZx1Q0VbQ79X6zetuGOZWHeNUtY
         zGi/j35C9S9u6ja4WuDTge2FRh/QUK0F5ml9f4GFcg4ZRNa840BMg5OcR8dvzzdVFpTK
         zWbZCBRF3ZTfatw4DaS5cklX7mu8CbL1ZeYlH64Z/l31Kl5jK67RTuOXucth4SZRdKJV
         BDJYBG9HVlc7oHv41xkKQdZWZK5iA4t7S7WxDV029+n4plc/Dxy3OASa7IkVxXdmYEtN
         kn+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s53si275069edd.432.2019.04.08.21.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 21:47:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x394klkj010319
	for <linux-mm@kvack.org>; Tue, 9 Apr 2019 00:47:10 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rrj0pw5wj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:47:09 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 9 Apr 2019 05:47:07 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Apr 2019 05:47:04 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x394l3ZN61014216
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Apr 2019 04:47:03 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 162455204E;
	Tue,  9 Apr 2019 04:47:03 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.92.227])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id ACCF052050;
	Tue,  9 Apr 2019 04:47:01 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Sasha Levin <sashal@kernel.org>, Sasha Levin <sashal@kernel.org>,
        dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, stable@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
In-Reply-To: <20190403122939.C4187214AF@mail.kernel.org>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com> <20190403122939.C4187214AF@mail.kernel.org>
Date: Tue, 09 Apr 2019 10:16:59 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19040904-0028-0000-0000-0000035EC098
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040904-0029-0000-0000-0000241DDCD8
Message-Id: <87o95fn5to.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-09_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904090032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sasha Levin <sashal@kernel.org> writes:

> Hi,
>
> [This is an automated email]
>
> This commit has been processed because it contains a -stable tag.
> The stable tag indicates that it's relevant for the following trees: all
>
> The bot has tested the following trees: v5.0.5, v4.19.32, v4.14.109, v4.9.166, v4.4.177, v3.18.137.
>
> v5.0.5: Build OK!
> v4.19.32: Build OK!

Considering this only impact ppc64 for now I guess it is ok to apply
this to the above two kernel versions. The SCM support for ppc64 was
added via

git describe --contains b5beae5e224f1c72c4482b0ab36fc3d89481a6b2
v4.20-rc1~24^2~68

powerpc/pseries: Add driver for PAPR SCM regions

-aneesh

