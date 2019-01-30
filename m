Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B847EC282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:29:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7265F2084C
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:29:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="r1zn6B8s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7265F2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FFCB8E0002; Wed, 30 Jan 2019 02:29:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D6218E0001; Wed, 30 Jan 2019 02:29:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06028E0002; Wed, 30 Jan 2019 02:29:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 992D48E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:29:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so8977512edd.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:29:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VT7MlOqFJ2aj+gRJdtq8yJKzK1geT4n0OhcSvRP4zPs=;
        b=s1+f+THG/BIIYT5brovoeZSXXvyRe+JtPfnYxtR8tla0uAf/Y/n+mAom49NOboichC
         gLL/g3VGromrP7x5eTpWup1M8WVT9mQ8qGEjKV3x3N5FjxFH2dZRV06ibEKy3ji9eH63
         lGeK7TjuEM55vvrgnBfQbV8vceoQ86FBL7lLzU9TtcLc2VjGPFwab9jt0BXuZTcoFrbV
         DFxpHUQSVI4OOnXmHYvstahcu1d5Feud0XpuuKqHcRlWzAaR6HWZV6UrUUcBCgw53WRw
         TF2/87FkVfncpR50BXsp8A3jnDUlVIQAQZ/ceQORTseDntQXFR3xQ6VyDmMfHgAOxsXO
         hBhg==
X-Gm-Message-State: AJcUukczX5lD1iuYBhV3ewsOKMfndb3ZDaw4ULg+RTr8HddyvY7jky9j
	6z8DXYv/3kcJTvXlaIqeSpXb8AVd0aS4oY23i2vHE6xxBXtKAbMWNjnP0Gbj6NzcXPmRzGa94u+
	w8BgChCOulCsIcrnXJea3xK0yk8UBvBywfr84GPUFO6pyzqciyIJ86Tl1wd9kmyw0xg==
X-Received: by 2002:a50:b286:: with SMTP id p6mr28716095edd.202.1548833374060;
        Tue, 29 Jan 2019 23:29:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5BIt3OFBGevLgY5D9BMC1UDDGstA8ZUjhXjk1qOXubC45semRwQGyoj4OHU/GPlwPW3lQA
X-Received: by 2002:a50:b286:: with SMTP id p6mr28716046edd.202.1548833373164;
        Tue, 29 Jan 2019 23:29:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548833373; cv=none;
        d=google.com; s=arc-20160816;
        b=lvHalad14zOLd785N6/ymTPpt91trd/vVJRR7fxwGmLfVJvUVfITYAk/E9eK+WCAXQ
         Uf5W2vJGobQr4dFVGwRtzNBx+JrOuEGyBosOUORiAwdTshUId2ew49yTSjHcI6fwyYL/
         1sRNNGYPdjg7tp3hHhEeoU5aQ0h1edXUyLUbJJBaFW7KU6mGCfndThnUXFxq77SaMxIv
         TEETSIN0g07Pq38mj4eWUlQL6tFv3He20LyZW1YlGtGUgyqPDsyAegs/e2mpRmJcWOWH
         hEw2js3YfHKe2Jkyon8PtqMTMtcAkiL22/p2K9MnltvkPEYrfbDjyAFG/9FhsputMBTI
         Bl9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VT7MlOqFJ2aj+gRJdtq8yJKzK1geT4n0OhcSvRP4zPs=;
        b=QoSvh6fTPoAqD567teX9ayG1rIdnhdsF9IS1aGQp89G9hnI8jBds4sqO6qky49aAYt
         GCWZtyUJ1GZDDQC5KGlIc7MWQX7rikcCWuOjI6rprU3Rkw0+q6g+VDCzsHai0y8YTUjP
         Gf13z0qrs7956OccEgZHRVhYLq6LfUDjgjcKgMlXC5W8fJqRhDPnvxmYusEfte0jemMR
         gyOCQv2t6Z3hZQldyQnlzmuk/s89Zkilcmn8MgYScq8BFUE/gvIb/1e8SGizRWfskrUi
         ycApVA+0WGkJavVo3WEct3Cwks/8siLcPHRj+jVa5hw1KKVAcFBM3rAAoim+hxPIyn0Q
         WdiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r1zn6B8s;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w26si565495edt.407.2019.01.29.23.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 23:29:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r1zn6B8s;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0U7SbrJ099867;
	Wed, 30 Jan 2019 07:29:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=VT7MlOqFJ2aj+gRJdtq8yJKzK1geT4n0OhcSvRP4zPs=;
 b=r1zn6B8sQqtOZ25/mPP8H/+iEpRZPEn4aTaYH8aoQZ92OxSJV6Xz0ca7QZ1sDOv8iRPF
 SzO64Bk8uUnFzdsdi0GY7jDczz0My3M8MHGt1bw6ZO3lPzdPRqgCEhOo+UKHbot/BGJo
 0QBTDLOnAdCUxUvyaLupJRl7a7KdZ8DjCdfDQZy2ah6sh/gwGIZZrmE76nSTcjoG+ZOU
 n7/6n7ZAKS3J/zyE5B8OI6B/G2MmO993n5/8MZ3fZR9woNtbSVYY8ZjG5iu02HRObZIi
 ddRDVFipcCjjwneHO9h/AIvwDT0VRL+gZ4I0+tpN8fVtJIYW7ffq3xkkMIZrk5btQ4My dw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2q8g6r8qx7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 07:29:07 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0U7T6xO023548
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 07:29:06 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0U7T1Ac000882;
	Wed, 30 Jan 2019 07:29:01 GMT
Received: from kadam (/197.157.0.43)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 29 Jan 2019 23:29:00 -0800
Date: Wed, 30 Jan 2019 10:28:46 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, andrea.parri@amarulasolutions.com,
        shli@kernel.org, ying.huang@intel.com, dave.hansen@linux.intel.com,
        sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
        ak@linux.intel.com, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
        stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190130072846.GA2010@kadam>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115002305.15402-1-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9151 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901300058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 14, 2019 at 07:23:05PM -0500, Daniel Jordan wrote:
> Dan Carpenter reports a potential NULL dereference in
> get_swap_page_of_type:
> 
>   Smatch complains that the NULL checks on "si" aren't consistent.  This
>   seems like a real bug because we have not ensured that the type is
>   valid and so "si" can be NULL.
> 
> Add the missing check for NULL, taking care to use a read barrier to
> ensure CPU1 observes CPU0's updates in the correct order:
> 
>         CPU0                           CPU1
>         alloc_swap_info()              if (type >= nr_swapfiles)
>           swap_info[type] = p              /* handle invalid entry */
>           smp_wmb()                    smp_rmb()
>           ++nr_swapfiles               p = swap_info[type]
> 
> Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
> CPU0's write to swap_info[type] and read NULL from swap_info[type].
> 
> Ying Huang noticed that other places don't order these reads properly.
> Introduce swap_type_to_swap_info to encourage correct usage.
> 
> Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
> (see tools/memory-model/Documentation/explanation.txt).
> 
> This ordering need not be enforced in places where swap_lock is held
> (e.g. si_swapinfo) because swap_lock serializes updates to nr_swapfiles
> and the swap_info array.
> 
> This is a theoretical problem, no actual reports of it exist.
> 
> Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Will Deacon <will.deacon@arm.com>
> 
> ---
> 
> I'd appreciate it if someone more familiar with memory barriers could
> check this over.  Thanks.
> 
> Probably no need for stable, this is all theoretical.
> 

The NULL dereference part is not theoretical.  It require CAP_SYS_ADMIN
so it's not a huge deal, but you could trigger it from snapshot_ioctl()
with SNAPSHOT_ALLOC_SWAP_PAGE.

regards,
dan carpenter


