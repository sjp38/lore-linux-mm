Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39747C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:10:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D70892175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:10:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D70892175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8748E00B7; Wed,  6 Feb 2019 07:10:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 480498E00B6; Wed,  6 Feb 2019 07:10:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 348D38E00B7; Wed,  6 Feb 2019 07:10:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03DEA8E00B6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:10:35 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id h6so4041119qke.18
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:10:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=bAzA6JhX0csIrrHZVORRRZQpvOuqzRdx74M6tF3GZ3o=;
        b=R6ZBKRIaEuOFcQSzWhXyEqAhULy2YJoCIxvlNumYw9yl8pqmYT5rPPZAEZRmACvgsT
         DQLGuLQJ/22irpFOR9PN64IhzfxFyklJUuIhEFhnh6GntXa0le9m5KY4MbprogqLVAAK
         8x/DLz5Fe09pL+i7+TlBfDpjD9w9Kt0JYofJ/2QHqocsGjoWD4HR4XOYk3ujdA7gYx0F
         KAwDGqhhe+vZx/FYHh4unTJqnjyXE9reoWe2zMRGU9LDbXpZgGPTTWjUptGpLY8j/Dgn
         NZT3GV2VOmqTZND7vdzRqWeXjFqT5+qBuEFzXoFqnh3wa6nxLW26tksHJ/iusqO8Y+3t
         SOew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubWBm28no1Fld7SHBgeqbcUGSl3V12xBsSFWY624qFR4ubuVplf
	MGSLLXCoSAeemA8KGWG1D5+jK/kOI1lW8KvDVbbItoc3/HdWXlir4jm3TwKHi1qhvsJiwtfajxC
	ddDJQQJedO5YhZ7rKJi7VwxjtTVwO/5OgxJIeIBO7qsOguY+iiM4hRa2zAalvfTz3Hw==
X-Received: by 2002:a0c:c584:: with SMTP id a4mr7415974qvj.227.1549455034790;
        Wed, 06 Feb 2019 04:10:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1vsC1WYoedWlMRrwTphTSQC11S5YM/JWUycr1wQswGQhu9ROJFCeMVkp2fy2rBHJedypV
X-Received: by 2002:a0c:c584:: with SMTP id a4mr7415932qvj.227.1549455034028;
        Wed, 06 Feb 2019 04:10:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455034; cv=none;
        d=google.com; s=arc-20160816;
        b=uLRl1xmqS93qmTJNYRSWYVtA9QpLzjDZ3uyHTAoLUE3oVILnaCz5oVjLNyXsVpaJdO
         F6CvtKxVtLjHbsi4L5vxM80DjwfOZ2bcO4EKKvO7M3yTsK0hSdX4Q/ee1J8MzmTgIDGV
         nqy2xZD111MQrMbnMxoEOY1420izy20xqEhh0hQYOe29NryRf42wkOBm6PxnhZLEc6zW
         XHA6rM4Zq58Qs4eJbPAq7phymXPkqrBV5wk6AS1/KNxq3apPayaAfLMM/HiCIXSpMvqC
         ygUoW9ZDFYwVmhDcMpOvYF1/YQHMkyqWvhCMPF/pK/qnVqxufV+J2xAZLzhz6JUsqlTu
         iYyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=bAzA6JhX0csIrrHZVORRRZQpvOuqzRdx74M6tF3GZ3o=;
        b=RTTjnSNB8wG+rraW72H3aozuX7Ng7aYEH7uE3+Ca3naat+lNWY/qKeccUD6vzgh+fu
         uGTnr0FHK38Db1E/mDwXpIfJjxkwg6+2lxGZs0D5JvZv3wDFaytTRx8k1vINICvdoIeH
         1NqUywO9p+vKBDmo8NA3i2GfSpmPdvKKtcVq426dM4ID/0WQ9IdQ4znvN11t2/eYevPw
         fWloUfUqGyK5zbmTa2X38GkVju8kFMlunfGX5lptmDIRuf7/TI8iIQAdXndz7HnW1tcA
         Ahr05JcBTpWU0XJUBEZubft2AOPpBUvHKL56c1EArAFZ15EEuxFImpsgVdLbjxY2ODBJ
         QTqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 24si8550303qty.168.2019.02.06.04.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:10:34 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x16C6sqm052947
	for <linux-mm@kvack.org>; Wed, 6 Feb 2019 07:10:33 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qfy2bh4cm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:10:33 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 6 Feb 2019 12:10:31 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Feb 2019 12:10:29 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x16CASvB55247088
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 6 Feb 2019 12:10:29 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C9F4AAE057;
	Wed,  6 Feb 2019 12:10:28 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 65298AE04D;
	Wed,  6 Feb 2019 12:10:27 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  6 Feb 2019 12:10:27 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 06 Feb 2019 14:10:26 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/2] memblock: minor cleanups
Date: Wed,  6 Feb 2019 14:10:23 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19020612-0012-0000-0000-000002F262D8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020612-0013-0000-0000-00002129C426
Message-Id: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-06_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=488 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902060096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

These patches perform some minor cleanups in memblock.
Generated vs mmotm-2019-02-04-17-47.

Mike Rapoport (2):
  memblock: remove memblock_{set,clear}_region_flags
  memblock: split checks whether a region should be skipped to a helper
    function

 include/linux/memblock.h | 12 ----------
 mm/memblock.c            | 62 ++++++++++++++++++++++++------------------------
 2 files changed, 31 insertions(+), 43 deletions(-)

-- 
2.7.4

