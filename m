Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F69C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C083218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C083218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C98B6B0006; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 951B96B000A; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8022E6B000C; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 597BA6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o17so2533036ywd.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Q5KoNsMCG5IDOV1gPRiQLaxv8wtKCIgM237pnH2OjKE=;
        b=IHpxV+dewyPXDHpCYROxAZ5ftGFY08YJMoK+sdhAhqxfrZM+FHHm2epnptaS3UTciR
         w40LWHwIYtHZkyBKXkZD6o+1KyhxM6BHo6JliIo2aqSuk0KUO9xBcBQ9+zcE/wnDnw1h
         BaMIVeZdInPn6g+J0Ao7zmqsWzzMdBeGOEsWD0omL8G9zYcS36akeZYgIGLQ4Tr9QaWU
         YCCs0236RzQdzAQaUE1CPQaw3OPIlnPyinvMTeYCN+xUlB/kE78tNI6/qtXRlVLjXQvf
         hv1/1qG4FbpzZtInDFJ5AZwyiOhHyoHQJYtwd1bPCS2v2fSUWwDo8+yo43CAVsJiVuiB
         wWCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX1c/jK1Sw75D4TZeV9HPEFMs5prS1ZZfD9yZp/umt8aYNPtYr2
	MNJ6kXcHBNOlSiZam9bAFhwP1Ci9iaJiwVp87DJI8VeXV1wIv1moxdCE5eR22IUzb/B38IUi9XM
	GvK9FqCJmVLYjYrIBji2Ke5fUS13jcDt7cWhyjk/Tzgc2VorVNjPPQJuYXYnLDlS7cg==
X-Received: by 2002:a25:2493:: with SMTP id k141mr21451033ybk.372.1556112265115;
        Wed, 24 Apr 2019 06:24:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5cluTt6JJv5byMudD3skq9UvS4Jsndw0hr98qHbZ1rdZyk5aGpGyHQ2F4hyO0u9tOc4AC
X-Received: by 2002:a25:2493:: with SMTP id k141mr21450991ybk.372.1556112264433;
        Wed, 24 Apr 2019 06:24:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556112264; cv=none;
        d=google.com; s=arc-20160816;
        b=JQn/YP1VmpWlvmi7wJMAImTWlUjs5atpxofxwrRr0NEwkcZwm6X28qeO82kFu+tRb0
         U2vN6YqNluuJFSnz2mxLJRQbMv/ZqmM1XN1g6HPz0OKM8wOZXvnBNE7fjkfwWWAUkdq2
         4thq7grtctwThqeYxGg3Nmj5Nf49ux3mpH1UNq60DupWfJnZnlpXbsC29RRVxHdcMfZ9
         Al5rxXesCZ0s4JZD7VnXYY59Ce31Odp+2Zlec/+dZvirfIqpUfNhuQoAGZE0fJBdM77q
         ZAEltIssObWwzrFT6A7dx8q6RfF1uEUPnVJn1BIEf7q1haeqObj7xq8FBGZywB6ztfky
         3liA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Q5KoNsMCG5IDOV1gPRiQLaxv8wtKCIgM237pnH2OjKE=;
        b=sIwfJCDnJlnx7YIEQLJa09M07gj5sfISGXi2nqa4z/fpzIa3ZFPj/M5q2f757EB/Mq
         mHx+qIgVLyzO5jcii3fEersDu/LwtbR01j9TM95skqHadgnj7JZKOZVpU9uKTcUm0zTq
         pNn04DyfhKh2cOWb8MVTdUjBInGj03+vdW0+T34d6PHz+NWTcbv56dDUYQ7TvtDVAhfe
         LqShCNgCDulHR/LJeGUb+X9qJaf2BV+OS34f1zm/B2zZzgk9KbDNDWgJMWJCS8cFkp26
         lC5pscjNQE+Cp3KrmAGL4MjRJawLfmyHcSz1wHG/FntqknZDVAkQSx6soZd+0wrI8qoU
         umGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d81si12531949ywa.337.2019.04.24.06.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:24:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OD52nH015783
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:23 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2p69qqab-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:22 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 14:24:20 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 14:24:17 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ODOGdT36700230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 13:24:16 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 43BB2A405D;
	Wed, 24 Apr 2019 13:24:16 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 77DBCA4055;
	Wed, 24 Apr 2019 13:24:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 13:24:14 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 24 Apr 2019 16:24:13 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Wilcox <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/2] x86/Kconfig: deprecate DISCONTIGMEM support for 32-bit
Date: Wed, 24 Apr 2019 16:24:10 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042413-0016-0000-0000-00000273172B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042413-0017-0000-0000-000032CF893A
Message-Id: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=600 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

During the recent discussion [1] about DISCONTIGMEM being effectively
deprecated, Christoph suggested to mark it as BROKEN for x86-32.

These patches follow that suggestion and make SPARSEMEM the default for
X86_32 && NUMA and mark DISCONTIGMEM as BROKEN.

[1] https://lore.kernel.org/lkml/20190423071354.GB12114@infradead.org/

Mike Rapoport (2):
  x86/Kconfig: make SPARSEMEM default for 32-bit
  x86/Kconfig: deprecate DISCONTIGMEM support for 32-bit

 arch/x86/Kconfig | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

-- 
2.7.4

