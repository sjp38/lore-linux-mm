Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 394CCC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:32:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E237A208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lhk5qU4z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E237A208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E916B000D; Wed, 12 Jun 2019 18:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7986E6B000E; Wed, 12 Jun 2019 18:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 660C86B0010; Wed, 12 Jun 2019 18:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 445CA6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:32:09 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y13so13523799iol.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SOIVm550t2juiTj4vnRQ5BaJ/KWVoCF7DZnOrZI0vno=;
        b=VayUze5mIkRlN6FAdWTLtB/Rvp+i/T+ZRehhaUMkkvoGStFVqA1K9/p3wPjHQpvcme
         rwn2qpf9aPKuEs1JuRY/bBz/JoFTDZzD7WBgOVc3UIeDMHq/CL5Wq/BAgGZv3Ir7WM18
         JaN2kFUdrqeZpmw4noSkJQv/zEzoesnKD2eQCdRRk2ZQoocHx33P97nmUBPwjgtDeyUx
         u+KxYr4W61N+ZSNViFwRdXaPc8/bJI5wyrxee5uMhqU4xMi9l0rxWXDJIAsvdSTqR8FD
         bEeIeJx3V7kxLCzMThgcocuOqTpUaA5g6jx253XOPDPwaKSg7fhofl0HCuezPh9Bcfla
         aT3Q==
X-Gm-Message-State: APjAAAW2u0F2er7Q5OO6oaMmLIGijS+U2fd+AlJ/4PzPRflAfDlbF9Ex
	d4MAdpM/lqez3ezrku0ql0aVmmSV56B7To17WPGLKNjLaZe10CLZ2bt3LMiidrLFqvbdhxNLVRJ
	xTuK9k2mU4w+iXXfgi5PO+/zl9Ba2HP0TXpYPBse/MBp/YJ4oJFV08F5fOxyUl2X8ww==
X-Received: by 2002:a24:9a01:: with SMTP id l1mr1134825ite.106.1560378729046;
        Wed, 12 Jun 2019 15:32:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFkcUx8KlcnnLmekiMvwr7au5P1Z+d++XVimglA2Bn+XmDC3k6XD6XzY38/NTMV0/8Ty1L
X-Received: by 2002:a24:9a01:: with SMTP id l1mr1134793ite.106.1560378728446;
        Wed, 12 Jun 2019 15:32:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560378728; cv=none;
        d=google.com; s=arc-20160816;
        b=R4V2K2GxXKMbiVpcdTCsfMkNfiJ+epc/0oKamp4ZmTh//mfPs0K/cbXXxA0aNqDjRa
         FKF7ZUIuOYX4cv0NyOfHjomb1qHOrfgeiCjo6T1tBZxJG9rfPkJQWgMFgpU6CbRTfUop
         zJCLqBDVIeenpTaHGmjzC3hZSQXHdge3S6gZ4OOKtTPdhzVNOtDrNqdm9g0DQSieYvfa
         cryDqtWGdsl36kuCDk69wGSXVikTSU2ugUqDniD1b6NIbcBcLwGEROeYqtr7reG/83oU
         ACYeTzscZCGcPsuMoLYfNIFXilLtST50m3tCOQrC5foJddPQ1XNzUqgv/40/cJd9tOzU
         we4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SOIVm550t2juiTj4vnRQ5BaJ/KWVoCF7DZnOrZI0vno=;
        b=QPZHM/FjbynBP3kXIvhJyfAKLRatU3O1ltVSJnMcRQy3Q/o9XJyKSuyBaZmfD2A/J0
         COWKY+cX0lOs3LbZiYRhJ0E0FtK6RONnAQ/z8vKjCvrj3Ba0RN4FqmKov+UXci378gqn
         8AZt7JojlYKRpyM+7RFjZ6jhBD2fVp9Eu8yO9fviyvZulyyoqfgJ94F9bSQyUwiAeY/g
         uhMef6s43t69uL6o29TbWeuCOefcBqjZLvT2VzBRbQK3mVHvaV2h5qKbS1ZJl4FtU0vt
         F0dyA5Do3W9xdYHDj32xl8Jny8vuH8Hd7uSLy5XO+ATR0jkqw5yrE0XEi6phr/6lHukk
         dqRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lhk5qU4z;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d71si833482jab.10.2019.06.12.15.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:32:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lhk5qU4z;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5CMTs85064050;
	Wed, 12 Jun 2019 22:31:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=SOIVm550t2juiTj4vnRQ5BaJ/KWVoCF7DZnOrZI0vno=;
 b=lhk5qU4z4GwfZqTKR5mbk79cDQzaoJ563ewToos4HaKC4mOW42ZuJj4rIKQuuXEL39VM
 tp4ZtszcjEpWB2WzalUsZvkf7EoQ4QcnxIQ2Qft1s6ZYSRtjhbym4uydGIVYMvhQvAHw
 fRHwYoG8GoVcSmHkzJ6QvWx2AS/Jpc3PwZV8EssJZG84yCzFBaQYH11ADbuo9e/H9WzV
 gBEoPFk2imAOKNWZH8Ol5/pQ2PTjvdP/f1tgifVJKX2HZGYVJYPuqPyaHLVwju+kvqVN
 3IYSt5eHrO4z++6UFpnrsjBUDs0k5Ev4rGF32Mx66rhmqD9/GhvxdpAvARzyeKXqVnkG 1A== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t04etx9bj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 12 Jun 2019 22:31:48 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5CMSCmx113818;
	Wed, 12 Jun 2019 22:29:47 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t0p9s3x41-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 12 Jun 2019 22:29:47 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5CMTW3r019311;
	Wed, 12 Jun 2019 22:29:39 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 12 Jun 2019 15:29:32 -0700
Date: Wed, 12 Jun 2019 18:29:34 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, hannes@cmpxchg.org,
        jiangshanlai@gmail.com, lizefan@huawei.com, bsd@redhat.com,
        dan.j.williams@intel.com, dave.hansen@intel.com, juri.lelli@redhat.com,
        mhocko@kernel.org, peterz@infradead.org, steven.sistare@oracle.com,
        tglx@linutronix.de, tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, shakeelb@google.com
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
Message-ID: <20190612222934.y74wxy3aju6eqs4r@ca-dmjordan1.us.oracle.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
 <20190605135319.GK374014@devbig004.ftw2.facebook.com>
 <20190605153229.nvxr6j7tdzffwkgj@ca-dmjordan1.us.oracle.com>
 <20190611195549.GL3341036@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611195549.GL3341036@devbig004.ftw2.facebook.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906120157
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906120157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 12:55:49PM -0700, Tejun Heo wrote:
> > > CPU doesn't have a backcharging mechanism yet and depending on the use
> > > case, we *might* need to put kthreads in different cgroups.  However,
> > > such use cases might not be that abundant and there may be gotaches
> > > which require them to be force-executed and back-charged (e.g. fs
> > > compression from global reclaim).
> > 
> > The CPU-intensiveness of these works is one of the reasons for actually putting
> > the workers through the migration path.  I don't know of a way to get the
> > workers to respect the cpu controller (and even cpuset for that matter) without
> > doing that.
> 
> So, I still think it'd likely be better to go back-charging route than
> actually putting kworkers in non-root cgroups.  That's gonna be way
> cheaper, simpler and makes avoiding inadvertent priority inversions
> trivial.

Ok, I'll experiment with backcharging in the cpu controller.  Initial plan is
to smooth out resource usage by backcharging after each chunk of work that each
helper thread does rather than do one giant backcharge after the multithreaded
job is over.  May turn out better performance-wise to do it less often than
this.

I'll also experiment with getting workqueue workers to respect cpuset without
migrating.  Seems to make sense to use the intersection of an unbound worker's
cpumask and the cpuset's cpumask, and make some compromises if the result is
empty.

Daniel

