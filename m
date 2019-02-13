Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E629DC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:33:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A892A20838
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:33:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XC31dfEt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A892A20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA148E0002; Wed, 13 Feb 2019 12:33:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 352488E0001; Wed, 13 Feb 2019 12:33:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4638E0002; Wed, 13 Feb 2019 12:33:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7A4C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:33:11 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j3so5179685itf.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:33:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yF1vCib8Wg9S4HalqsC6LxQUOgk4ubp6E1FmYHDuLck=;
        b=nn85nk+8b8TmZRzSJN6eK17mClU6wpbb7ueKZY6gIZR4IvXJdwwjObHjD3N9ZeWrLm
         1ytLRXQej/H4WBhe3F8zXTdvaMe3YoyfoMTqh4+IJDLnY9sTf4dPuEUulN8hsefISPQ6
         6HDCq4/ElTzDEWxGZrLDMzj6shoqQnMerB7sPGKIKMKHu0YqTJiM8nM9TKHjXLSMraWv
         rksOQvO9b5XMIYoUjlcz+AfyQw4LxNEY+66bBrFZ/uKu3qdadE5TjP7rVKkRguzQWnsu
         2w1PM+YRcPtwVYjEbApH9SMYBGUr+izG4BC035QTyWT5PDiOMO+C6XOvNgFIb9HIPN6e
         /2Kg==
X-Gm-Message-State: AHQUAuY+ebAB97bD19MuEUi9mPk5UTrblBOucejMgW26AOm9CeBrPcgB
	dMomo6j/qIhIvSLjowdctav4RC7gFjgXkf6He/y0MOjoVpR2bJXzUaqOHWaaz3lVR8YXlV9JLjJ
	Fln+tVnDRMZb4q5UEUcVyRwn3SsUMDx0XgeHkUlXZ+j7BosQj1fpyQBDhNW9QepAVDw==
X-Received: by 2002:a6b:e219:: with SMTP id z25mr1000237ioc.116.1550079191676;
        Wed, 13 Feb 2019 09:33:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbRHjAyKW2mgF4JjvOeu9V1WrcL9vmACyXzPFYmd68uJidU5leDBq1PuBZNGubyQBgBV704
X-Received: by 2002:a6b:e219:: with SMTP id z25mr1000200ioc.116.1550079190958;
        Wed, 13 Feb 2019 09:33:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550079190; cv=none;
        d=google.com; s=arc-20160816;
        b=YdaA0wGtRDkry5eUhJfCuT2hsPEETrxb5U4H1ftjmUrVKtouV9EcOnWMoaW9r3DEwG
         gW9fmJCFsfJSRraePiTNdHdL3oeAKky9yMvVfZ5Mt22H1qVuRob/z1wDEHOBvOpo8jsb
         nyIemT3aHhHnIb+4OpXnuhoWAxxDcWEkvwpGUi5wmUGsbHxrJzAHI8H/RdIdCso8XHkL
         bI0vyUnhMWmjRS8KyqGsHsuKunQ1Ne50+v8FUlyv0SQuTdOMpd8/8/oOxDRJG5qZXlsg
         kVTJqVh0rJ7lqWGOzr2o63SmSDHEVnpjIF1Bp1artGE/M6P2Pqk6Qqz5qFxeV9soBwXL
         PnLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yF1vCib8Wg9S4HalqsC6LxQUOgk4ubp6E1FmYHDuLck=;
        b=LsU3OS5YjD0s7G2/bXksvhaynzq7aZRUYndg9jwX+zRDRB+M0o4fvKrndNIJcAEVl/
         Jnrl6Eg6jlkN2EobIZGErGwZREVmDGhcJKJG6t67iCdkqxDtsgbA0/tzXag+RBpIhMcf
         pRIxQNt+X+IqdsBJ9/GyPF5dUQDl3WTGIoMhAquf25bpd0mFTeFCCR0EECDWS7t674AT
         ZCK0HFdTLFVUZSxV4/OtfoqpsB8xzEQOSc+HRtS09r9KnLjeLhOmVm8i5a+m/cyux3dA
         eV4NuH277iTlvRrGKjQocedEyloLJYLJ56deIm17JN3uK4iNE0D8MzX9t/4DcOyFtEbO
         TUNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XC31dfEt;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t138si1139446ita.133.2019.02.13.09.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 09:33:10 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XC31dfEt;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DHTJ1E170354;
	Wed, 13 Feb 2019 17:33:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=yF1vCib8Wg9S4HalqsC6LxQUOgk4ubp6E1FmYHDuLck=;
 b=XC31dfEtwiMut3n3VSmiGY3+oQEEaOads4E8f4KuieqGvrzDrvSjRLbWXoDmYjjbX++z
 jw6UKA1VozrD+wWa5BGKiIXhctrgRVDgKIY/XOQNe27cZxcgc7km/A2oFyzR1f7Al5mV
 /5kqGA7u/8XsEiJXP29RN2aRZupDj7oxvCJz8SwZobqdfMOnwPcANjEfk2iziumuTJua
 uufMBj+SArGPxt447awCQrAV6+77x9quxBOW5+VvUls5h1PR37w+OzkPI9W9mkJiEG3Y
 zoRtWr15MrO481KRKSBTbNcdzKlisvTACqqk85NQnTWGsOLE3BejsWTEPnkKrV5iyTeG dg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qhrekkewu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 17:33:08 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1DHX7Af009656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 17:33:07 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1DHX6pq024489;
	Wed, 13 Feb 2019 17:33:06 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 17:33:06 +0000
Date: Wed, 13 Feb 2019 12:33:27 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
Message-ID: <20190213173327.uhexilxmmztx7fbt@ca-dmjordan1.us.oracle.com>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998444053.18704.14821278988281142015.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154998444053.18704.14821278988281142015.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:14:00PM +0300, Kirill Tkhai wrote:
> Currently, struct reclaim_stat::nr_activate is a local variable,
> used only in shrink_page_list(). This patch introduces another
> local variable pgactivate to use instead of it, and reuses
> nr_activate to account number of active pages.
> 
> Note, that we need nr_activate to be an array, since type of page
> may change during shrink_page_list() (see ClearPageSwapBacked()).
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/vmstat.h |    2 +-
>  mm/vmscan.c            |   15 +++++++--------

include/trace/events/vmscan.h needs to account for the array-ification of
nr_activate too.

