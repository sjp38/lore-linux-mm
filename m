Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AD99C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D06020881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:49:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D06020881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A28468E0002; Thu, 31 Jan 2019 01:49:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AE748E0001; Thu, 31 Jan 2019 01:49:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8775E8E0002; Thu, 31 Jan 2019 01:49:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1198E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:49:58 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p24so2587238qtl.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:49:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=sryEmpYwNIiCtZ8liUReOVa28irp2orjLuFc24EW0fU=;
        b=lwDJsh+GOP9bgz7Zb4QS+8UeIFTK/MjgFc0umoYzpSEwqXfbXgxaDnHPG1nVMEKFer
         l9VLgbmzt6QB+kZBjIwvUSbr3vfxSIIH0GRrwDJFUhcAql95e+USxRlKJr0y4UJFbXiO
         MT01jgWft87zKW0+J+lM39Cj7WvlVE6WgUxelYzWgTTItb78f9PRMQdmixncEApAe+3j
         HlMOq2/l8GuGr+HITlYCnfUmxQdWKUdfh8JaAMBEzbzGFBnyK3JZz4PjflnbDyFBEqgt
         vfKfI1AZge+LJf/SVhMirhB8K0xmUX0ZOkOxpJff/Xw7VFbItJZFlnyA2D7qoVu9Fw+4
         sswQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukdOOP84aDw/7PlQZrTBoLbl+Jp26hbVgmB2GhyTVDZyZdziPigT
	MPhJGMyrP0gMf8QWAFxLdHrIP+wfKYKL1/yo+lwL4shx6Fxm+XYWi5EuvgpmoFFfIzp7hGaksGx
	cYC6SrKJS8cQBfRcdDhqI/RhSLhjLXeSzTsktoD2p0ESFucGo1UpE2bfcWG5UYxl5sw==
X-Received: by 2002:a0c:9deb:: with SMTP id p43mr31547245qvf.107.1548917398124;
        Wed, 30 Jan 2019 22:49:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4EUlR3HfNamT/MpbvlihYAGiE4EW9u7iZ+P0H2bJzqTaDhHhg56pAhxnJ258NuZr6jCR/Q
X-Received: by 2002:a0c:9deb:: with SMTP id p43mr31547227qvf.107.1548917397599;
        Wed, 30 Jan 2019 22:49:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548917397; cv=none;
        d=google.com; s=arc-20160816;
        b=SPkYrAfNrWnafCJLOHKyJKiXOIGxXxP36/OurCDH16yXkj/SZazb+tfKFWEP4P4kJs
         LSIzbz3lvNzWu7a9s+yHF0h/XcH741XQMkkT+7E1xMajiUZbaxdjt9dbz7KoBmV+TUXa
         kAxmGd6pkTPoy18inShlF15deODZZP61awZ7OKTX5pw6tG5VWgazRjFXn8TW+rI3K1Z/
         dldaA4sxx63b5ixcZlUXsYkv8uGYxsTsD+UcU8fCtxc3uOfAe2YDTyFuYiIq5OKZWEDa
         DPTrteR7OSuPwu+OrpFnMPHBgXwCiWelL0xwk9SwZvm5Q/pwfSl71TxQbA0TH3ak4cJZ
         asYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=sryEmpYwNIiCtZ8liUReOVa28irp2orjLuFc24EW0fU=;
        b=gMJ0GlvuQ+Ud2b5yphpQ8QueIMm7XfPamUAAxE+l+9NT9pmDdMZH970cbtIk8KN7n1
         D6U2gAQfr73H/Ax/MHh5u8/3EZPP7ZwcuIXkgaBBptuNqYRxTLX/oK0iH0a0gBy1gOtb
         ujewVvFvkno4GhfBlHfIFocn2++bugAJ0QQ/3EMqmepRGQh2LrljBZTHmcuI0JKoT+BU
         ZhctpflhNoXIlv+FVtNDHXHMRyAiAJiPvtlxVztHtMTIjwBSJg+zowuzuIYoIgolA1eY
         VxaEWXxfG6xrFHmtDWuZ6KK5tCCtloqsG8HIZS9tm/uXJOIRalh7L8kvtokNtiy2wX5I
         uZOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s7si2379885qvr.49.2019.01.30.22.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:49:57 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V6nKOl005479
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:49:57 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qbtrek60a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:49:56 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 31 Jan 2019 06:49:55 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 06:49:51 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V6npjr1835270
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 06:49:51 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E09A811C050;
	Thu, 31 Jan 2019 06:49:50 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 69D6A11C04C;
	Thu, 31 Jan 2019 06:49:49 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.38.122])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 31 Jan 2019 06:49:49 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
        linux-nvme@lists.infradead.org
Subject: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
In-Reply-To: <20190130174847.GD18811@dhcp22.suse.cz>
References: <20190130174847.GD18811@dhcp22.suse.cz>
Date: Thu, 31 Jan 2019 12:19:47 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19013106-0008-0000-0000-000002B9278F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013106-0009-0000-0000-0000222528B6
Message-Id: <87h8dpnwxg.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=861 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310053
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> writes:

> Hi,
> I would like to propose the following topic for the MM track. Different
> group of people would like to use NVIDMMs as a low cost & slower memory
> which is presented to the system as a NUMA node. We do have a NUMA API
> but it doesn't really fit to "balance the memory between nodes" needs.
> People would like to have hot pages in the regular RAM while cold pages
> might be at lower speed NUMA nodes. We do have NUMA balancing for
> promotion path but there is notIhing for the other direction. Can we
> start considering memory reclaim to move pages to more distant and idle
> NUMA nodes rather than reclaim them? There are certainly details that
> will get quite complicated but I guess it is time to start discussing
> this at least.

I would be interested in this topic too. I would like to
understand the API and how it can help exploit the different type of
devices we have on OpenCAPI.

IMHO there are few proposals related to this which we could discuss together

1. HMAT series which want to expose these devices as Numa nodes
2. The patch series from Dave Hansen which just uses Pmem as Numa node.
3. The patch series from Fengguang Wu which does prevent default
allocation from these numa nodes by excluding them from zone list.
4. The patch series from Jerome Glisse which doesn't expose these as
numa nodes.

IMHO (3) is suggesting that we really don't want them as numa nodes. But
since Numa is the only interface we currently have to present them as
memory and control the allocation and migration we are forcing
ourselves to Numa nodes and then excluding them from default allocation.

-aneesh

