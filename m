Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50253C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:04:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 103DB21E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:04:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DYr3DDRG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 103DB21E6C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15B26B0007; Wed,  7 Aug 2019 11:04:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C6346B000A; Wed,  7 Aug 2019 11:04:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6E26B000C; Wed,  7 Aug 2019 11:04:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 694D76B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:04:06 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id j77so23115966vsd.3
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=M4ZcIyz5b3ADuhDa/BJRjIXspgYDnEF++XCR91nu0ok=;
        b=mPf+4qIe9yRaiwH05XX+9byelwxLQ0xPf9thqIEfhECiPS1DmLsWQgzdV+qfVNlFIm
         pbVs7E+bD3P5DVkPP/NzNFkVrw5c2/29sd8cJ3bJTdOtXpnU4n0QIkuj0QwKkCbgXuko
         eQv9OrBwCCcrICTvNHn6QvJ3cw0J1D1Ttmr+KYo6ZahmXt5sNL0I7l6Wm+L0lHEU4k7P
         b97f/A0vlGybCFK3lZeF2VAct/+mbJ/qDvvwMfleO4+cCCxuTzMvMSOSkruV/G6JKFhF
         CNVN7HUPsBlhig9wiger5U3iswf4ef7OxNQNs/wP7FWuaaO7O7olk/ejpoHiElz1ksX/
         n8Vg==
X-Gm-Message-State: APjAAAVf0UKwyqh5in077TjYkXCvEZjat7sZpevUeZ4KNTdN4rr2Vwc7
	s7BSmKdbKssqDQyv4dmgO/glVClGpyp1MKSbgFAxg3uVt8SAyz7suG/sYYjZ5eK5lIz5o2OCCn+
	tX5sSJ3mxhEKSM0lYrivbrE0xLp40A3m50kwvXtsUmpfcmhai5UpDYBJhXU2uGQ82Zw==
X-Received: by 2002:ab0:4744:: with SMTP id i4mr6427511uac.63.1565190246127;
        Wed, 07 Aug 2019 08:04:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdTdgrogQYFfXbo5LQdkEq6filmDDKlXnVC7fv5QkdneVyv/3xPMIqVEPIL0FWRKDNezpK
X-Received: by 2002:ab0:4744:: with SMTP id i4mr6427468uac.63.1565190245402;
        Wed, 07 Aug 2019 08:04:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190245; cv=none;
        d=google.com; s=arc-20160816;
        b=IDwhoJsmvJuo8bMzi1I7KcAXaYr+CJ1rpuTmxlbkvF8AyMN+h2hLVhbvUM7wDPolYw
         TtIHtEyF+bSMLtzZsCZBrmXSr4/1LuEDFiQ+wbM7SIriLJosABY3XQOBQ/5be1NW3TuI
         ndgaPzTAGqfv4OztqHNve+VgQp2Khk7PE4dMnA/n5AOZRli3JvRQv+IMKYFbxvg3zC9+
         +x2gRQJhU0CJzbGZ4tp2BoHffF9EYR32kjM5ENjJfyb7QI+wV9fURVZm8KwS7dSOrord
         gbW+mjyokHofZ8/X37D5JSEfKYBl3BTAUxFClXEi8YG9IdVZWGnK4Do/xGnz+uQiv8de
         axow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :date:message-id:from:references:cc:to:subject:dkim-signature;
        bh=M4ZcIyz5b3ADuhDa/BJRjIXspgYDnEF++XCR91nu0ok=;
        b=z+ICmQfBYZKPZOAH+FVetEDL5bopON9V/RR3ol5oubbRIwswvkx43G2om+rbINZm3/
         0/4qtlDvEPMrydOgLbcJWlupKmDOMmjDP1ruKy/3FKXdBRiCFoTRydniIjeiQWIzSTXA
         S535zStxPOVI9ANzyPXF7/wpPwgoakdubBSZrbpFsRg0CnjEHTrDieHKNsCQ+higotZR
         FaLrFlyziFRdJIQ/Yav9Jqr9HkY/MJ3q+Q2/ooTM2NXTKFxOTokSYIkiqdHvzN9Y8uYl
         QJVXFreIxim2oI3rWxSfmSYNe1SwWdWshS2fS4dGDJ/K9eNqgULADkdI6GQz4BIwTBB9
         HwbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DYr3DDRG;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s23si18458352uao.186.2019.08.07.08.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 08:04:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DYr3DDRG;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77EuC5T017488;
	Wed, 7 Aug 2019 15:03:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=M4ZcIyz5b3ADuhDa/BJRjIXspgYDnEF++XCR91nu0ok=;
 b=DYr3DDRGNCgnl64b3tUdn5uDjK/9iI852BkmaeU2KevC5r2nujoNhLLH6/TgjlMd7KOd
 h9exYj/C4Yd/fheTdqK6XRRq3hxDJrK5J1egytlV4fr9MVhpY5+6yvjb0wcLZSqhSYzo
 F+O9zM1Xvunf9aaTakx9wWYTtSaTzd+EQvrX64OWAm+FXiSVsZTzKYItaQ8wfgsXo2JM
 ShUoKdum0LuQm+n9RCZY5RqdC0cwD6ZTSc5hZNgA8wLBPTuJt614awHLkplBF7/UUDiN
 DYBStMljMQnrQKToBKtHuq756EdERzZPHSp7msg7nT6YtduymR4fI0UPYPbyALYIa+gB TA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u527pvvwy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:03:53 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77F2bFn167049;
	Wed, 7 Aug 2019 15:03:52 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2u75bwh3e9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:03:52 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x77F3oBR032173;
	Wed, 7 Aug 2019 15:03:50 GMT
Received: from [192.168.1.218] (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 08:03:50 -0700
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Mel Gorman <mgorman@techsingularity.net>,
        Christoph Lameter <cl@linux.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <CALOAHbD6ick6gnSed-7kjoGYRqXpDE4uqBAnSng6nvoydcRTcQ@mail.gmail.com>
 <20190806152918.hs74nr7xa5rl7nrg@ca-dmjordan1.us.oracle.com>
 <CALOAHbDGojd3K=m=E6mJc+9bMGQtw8FdFc0sVRhvSAngOZTHhg@mail.gmail.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <e3b75590-b2a3-d22d-fa9f-1bf9c14dae3e@oracle.com>
Date: Wed, 7 Aug 2019 11:03:49 -0400
MIME-Version: 1.0
In-Reply-To: <CALOAHbDGojd3K=m=E6mJc+9bMGQtw8FdFc0sVRhvSAngOZTHhg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=686
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908070160
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=726 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908070159
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 9:00 PM, Yafang Shao wrote:
> We used to enable it on production environment, but it caused some
> latency spike(because of memory pressure),
> so we have to disable it now.
> BTW, do you plan to enable it for your workload ?

No, I haven't experimented with it.

