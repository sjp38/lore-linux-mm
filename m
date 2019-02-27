Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B72EFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76296218CD
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76296218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F36658E0003; Wed, 27 Feb 2019 03:58:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE6878E0001; Wed, 27 Feb 2019 03:58:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD6268E0003; Wed, 27 Feb 2019 03:58:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0738E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:58:57 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e2so11962162pln.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 00:58:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=3MZmgpOH+L4okeA38O1B/4//YTw6phDT03bc+man3Lw=;
        b=Ncx0b05RbuBQybRSEW0A5eEIC018y45ojOn9PKH5UJSxmAICYaqBOtDKdVpIppqenS
         Py+4n7/phM8C5zZDkBUUuyhcDLj4avLOMrFQQomVOw5ubLuBYOu6ZAM+Kgs4UvWMftkP
         +V2FZL01MPQAqqDkgbfN2R6JN9epYkMozhVmcwyDZrGQ7kftkdmRMoheZGipEO9/9K/Z
         XwqP3qqYKVhj4502X35kTlOWFoG72mHUb2PtEh97kEZ0Ic5lz/Z1POskcEM4cn4XGwsE
         gxgYt4EqJYt0m8aaPrtBKPnzTvauHW8hS9h9i+mtf50Bl653pxgN3qmfbFoPPu99XawQ
         2U5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZE2Cf4C58Y8VTg/CFQFqVDrTCcfFHkfMh/6G6Im0fD30r8mn1o
	mghqt5SpvpA2ZQoe4GUZyV6kev8JLyiCE/O4pVCd9AfECdBRKKZG1uLpAG27o6bKA7gwYFjmgHm
	njRgM2eLExeVT3ywt5F1lzOyHI+TBrrK6y4ActxkJoDxd0SHbNqOapn06Wk6kzn/o1w==
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr988543plb.197.1551257937225;
        Wed, 27 Feb 2019 00:58:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYoIIdWF/GEhEjpA4QA7PeAcn8Hm3akUZX/kFEFy33ikECobRkd254u2rGN3ko+LUL5S42W
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr988497plb.197.1551257936249;
        Wed, 27 Feb 2019 00:58:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551257936; cv=none;
        d=google.com; s=arc-20160816;
        b=YVw2BLaCYev+NXV+5W+jodXiui8wbSsrPK7LonZgIYeHY9kG/hGnCZKq2XAXpUj3qV
         aScfh0UwdcsQNyaPurcc9LzDBrTrkwvu9w3001ACSk3SJGAUgFoMBWcWpqCnO1vc2ewA
         zB6NNm3iE89Ir2XZfXqpmFWrRqjhvlB4h8yFvwv6h1RT3znCIHGQyy0RMsIgDr09AQ9I
         1wfXL35kUV1Jdfcu4yU8zhckl8Uh/iT7aiUzYZrqSoHmX7V3gUCKkZKobavEALNwVJ0o
         KGKxHj8rPzJu4Yil1coaQ3BgkY6tRmkFnIxZjHhrlNPjvNHubhSbmbY7UpVZeb6/nrHN
         CqOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=3MZmgpOH+L4okeA38O1B/4//YTw6phDT03bc+man3Lw=;
        b=yBkvjxHq4xtI/59ef3sbAQiqWs+YD168jbPaHKsYuVPZ8yesZPutYTaAvqxsFAr/8H
         bRYfRMoGKvK9p/jd8RED7p5tWFnVRKgIy+IFBJKyKdKWLyxXPwuBpaY+5upVSkKuzS9O
         YwfQ3KKk9YbGqfzITGF9+kY8xwfq+OObyZlNHmQi4tg/DRhV1N7b2+FWQm8mkg7VkGsg
         vHfDuX6phcSiZkqBo2ogM64Uf22ESTs7k5hM5+a/weaz9y0TQln6asqWxMBzFr9/ZcQr
         0pSkXCnQdBaWg4QCU/hLf4mnccUSwX5hLhfbpMxA2qdG0XcTmHHl9qO36WOv7NVth/UJ
         L4MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a24si10276587pgw.581.2019.02.27.00.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 00:58:56 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1R8uLFT033703
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:58:55 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwpk3aw58-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:58:55 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Feb 2019 08:58:53 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 08:58:48 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1R8wlXj27918412
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 27 Feb 2019 08:58:47 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8C34C11C05C;
	Wed, 27 Feb 2019 08:58:47 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0EF6411C04A;
	Wed, 27 Feb 2019 08:58:46 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.69])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 27 Feb 2019 08:58:45 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org,
        mpe@ellerman.id.au, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-mm@kvack.org
Subject: Re: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
In-Reply-To: <20190226153733.2552bb48dd195ae3bd46c3ef@linux-foundation.org>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190226153733.2552bb48dd195ae3bd46c3ef@linux-foundation.org>
Date: Wed, 27 Feb 2019 14:28:43 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19022708-0020-0000-0000-0000031BCC4F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022708-0021-0000-0000-0000216D36E4
Message-Id: <87k1hltxoc.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=621 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000073, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> [patch 1/5]: unreviewed and has unaddressed comments from mpe.
> [patch 2/5]: ditto
> [patch 3/5]: ditto
> [patch 4/5]: seems ready
> [patch 5/5]: reviewed by mpe, but appears to need more work

That was mostly variable naming preferences. I like the christmas
tree style not the inverted christmas tree. There is one detail about
commit message, which indicate the change may be required by other
architecture too. Was not sure whether that needed a commit message
update.

I didn't send an updated series because after replying to most of them I
didn't find a strong request to get the required changes in. If you want
me update the series with this variable name ordering and commit message
update I can send a new series today.

-aneesh

