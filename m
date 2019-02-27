Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CCFEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:37:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A466213A2
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:37:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IJxkwKa1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A466213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C64CF8E0004; Wed, 27 Feb 2019 09:37:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C10CA8E0001; Wed, 27 Feb 2019 09:37:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD7978E0004; Wed, 27 Feb 2019 09:37:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75E1D8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:37:41 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y66so13356897pfg.16
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:37:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=J7svFHoxmE2XLvbN/3NrHFLkdwtyhcSLXfXcg2eXElc=;
        b=esZDAoZzTcSVINISLVZ4d/kUxKxX+eFIF/kzUPwNOgi7wtkEjebqEFk/1/cFyyJmv7
         FTiCYm0dF+onU2KTURjBUR7Sgg6J2scxvULocVRTDHPpRui1jIVEWNqRkdAvGtKSco5o
         kn/x6AiFtLPMPZRcP1Nj9+klycqsgMVY5duHzHngwfxo6yTjFCIurKBLtUQpOxgMj4qH
         cL4fmBrDMwUBwLHbHwU6pFwB0akjG+eULkUdmDvUZPYBZe5P0T1ZwCkH+8JMbMwmX3xl
         aHjU2srdiipQ7sIFKEHW3ShFSznPyTpJCKuvtKbTubqq2Su0zSqAHJlFvRNQvR/PgPAl
         Mb1A==
X-Gm-Message-State: AHQUAubXeou+oas1ZFWDk2wjhyMjWiOJRaX/9pTupAA3/WNRfHbOvcVr
	pVztncLXf4BTvXA+6m6lbyaGtzzZl/iqiAIAkYSVRVxrYVTR5nngaFV2F+A/tLF6xEs+TJRCFdN
	CkS1JiBp7nVSkbEEjLlSdJw9esYwlWmuAjxdaHAJAzpB8DjK2a3qv6t1i9chn6z3xlQ==
X-Received: by 2002:a63:e801:: with SMTP id s1mr3293059pgh.378.1551278261095;
        Wed, 27 Feb 2019 06:37:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZt5PZT+bQOBVkE4WGqZgTZts+eiRQK+fs3JmUwAEVFM9bT3TVa8bWGzOabEvmMvv3NTLhq
X-Received: by 2002:a63:e801:: with SMTP id s1mr3292994pgh.378.1551278260281;
        Wed, 27 Feb 2019 06:37:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551278260; cv=none;
        d=google.com; s=arc-20160816;
        b=DSFWWbzmrjFPt5VGIRqClgtzP/P8V4j/x4MyeALcRE4oPHS/MnXZjmtbokdhxjhqR7
         6H/wePWMXo40htra8m19akrK83I+lB4y/LnJ3SzK5z8VGedHMKlmBtv58WaXvGwM7HNx
         ki2vFZX7sj7qNdGpOm++TelQgDyjK3VrJGY8Nufnw2vzqCHaty0paEbkt6ZmW1iXeVeS
         /T0HAeSGc0fiRdTCuvpEWGuS/AZpuxjeIoRp2TIuvlwVbX6SSyedV60lX7RXYB4sujCP
         vNmd1alOHLy+b4p8cXB4IuSaWS4PCt2wkvnkqHi6Hrd2k5Ngs9h+efuGqw2AsHw/0DRN
         66wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=J7svFHoxmE2XLvbN/3NrHFLkdwtyhcSLXfXcg2eXElc=;
        b=MRsquio9yjUM/7tXgHGV2mWNvAq0ifwOvM6FZ6N/7lTp2q6wlENfOCdEh4mDj2RKCV
         jAobYgDHiVxNWQ+DkyI8isdMu3FDSGp7CoM6gqbMLzGDxg5O1Iprd2HXIOAPYhYpP1wJ
         jceaci+rLwVn7JRx4kr68jYtrXE0ewplJFZWIoA9CTjDtGQtAX9IS5n6W5AMKxXKD6Ya
         9th3w+YwKOVask+Ynf36wDUlJtiuy2CR3w9J1JvRybztPuToXf3ANeby+ugE2JYncRqi
         MUkkUF5i55x+2+eYRUlyZGDEpz/OMA4HyLa190AFa0NEVK9xZv3NuKiqzFaSmmyKsQEy
         5ghg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IJxkwKa1;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u4si15283230pgh.278.2019.02.27.06.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:37:40 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IJxkwKa1;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1REYGNV125552;
	Wed, 27 Feb 2019 14:37:34 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=J7svFHoxmE2XLvbN/3NrHFLkdwtyhcSLXfXcg2eXElc=;
 b=IJxkwKa1bFsdzNiNKGOhg9j4WgFtS6uzFhksMlsq1u+Tb2ewzuk/XzrrtyX4ANyvlyDG
 yLzePZt+/m7AS3xukJxhSwt3Ri3EDkyimaydRkw3WauDXlete4qXofSFxhbx/HuO1T0e
 co9oWA/JK0XciVRsCd5TK7Pk3rplTMmWuSt/sgkk4LrqS8PkiOQtdArijn6n/7x4gQNb
 kDE5D7G8r/ZyUC8KK55IdpNq+Ziq4ZTbmHYlxU6cYt+82VzLbihdbP18VvOfO6fFNUpm
 z/GeI5atfNqKwnzwR0a8LuH+eDHZIlD6w9o9faIDX2XZLePHH1s9qVzZKLQ9cyejCqrC sg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2qtwkub77u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 14:37:34 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1REbXr9023390
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 14:37:33 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1REbX6C030641;
	Wed, 27 Feb 2019 14:37:33 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 27 Feb 2019 06:37:33 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v2] mmap.2: fix description of treatment of the hint
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190214161836.184044-1-jannh@google.com>
Date: Wed, 27 Feb 2019 07:37:32 -0700
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org,
        Michal Hocko <mhocko@kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <CE9479DC-7D40-4AA7-A382-FEC4B016DE89@oracle.com>
References: <20190214161836.184044-1-jannh@google.com>
To: Jann Horn <jannh@google.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9179 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=766 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902270099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001497, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Thanks for updating the man page!

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

