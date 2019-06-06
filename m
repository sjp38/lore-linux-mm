Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF3E4C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:15:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F9622083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:15:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F9622083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 198176B026D; Thu,  6 Jun 2019 02:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149B36B026F; Thu,  6 Jun 2019 02:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2CD26B0270; Thu,  6 Jun 2019 02:15:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D28186B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 02:15:38 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id j72so1101282ywa.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 23:15:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=5GtNh0BGvR7DPfAlMNqPH/fQtkcx3y8XIxYdxvp75Ko=;
        b=ETApCe7vtTKLLhoM+SemC0ZN8lxPkBe/OXwLJkxz5uau68M4pJDNjXCmswGCwhRMva
         BHxBlmS4Rfjojin2jq5eYKh9ALUzZfoNK0QkyMzC6PC7/msaty8MsuBT96E2e1WKbVmr
         jnoqPEWAfnGHs046In1pGvPjFBKoupQJutedSUZxIhDAEzgRx78gbgFZXsgyWMF1kuKp
         zWEfLsDmd7/SRUSXp8uutiQ/r2/LtzF/Q9I8cgiaCHTILWi8+rd6/Axb8K6NCdzAnBs9
         CscjbqeETbuGCvmOlgvlS6APHyi2ldfotnejJb6rP4Igf5vVSTkIAXvBCA/yxyTZcB7p
         ETWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWAYDYJGrKkkDwdpKbro18PccjPjPoTeTrsuw70FuvGnHoKt/xL
	zU0M/ySkl8QmQfE8AZpvfNFClckF8abkZyfddGHiOKQCUlwGnA9iUoobmFkTquYLknMeXygQpK5
	IZW0BVWj9xjxnZzyd3DQ6XgF159XNcNuMNEGfUDQJb+Vgm00s4Lyub3GGL0JRLeMf7Q==
X-Received: by 2002:a5b:ac7:: with SMTP id a7mr11968688ybr.176.1559801738598;
        Wed, 05 Jun 2019 23:15:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy61cToNI9pL44QdVh+rdzciUhCK7L/iCD6PvAzspJzdjd/StwGkRQY83AghnsyzRa6Bwx1
X-Received: by 2002:a5b:ac7:: with SMTP id a7mr11968665ybr.176.1559801738007;
        Wed, 05 Jun 2019 23:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559801738; cv=none;
        d=google.com; s=arc-20160816;
        b=knhZX5IuwTCd8/Pjosi+2iBAmqdUXE7IgGB9abuUKnm7fxiDnPKG6M19I1s7g62gBR
         REO+bs672EN7A8LxLiQx5feVYua7EwsY6cO+sL891gOnv/hbXHMunP8si2+RsHjDbrXH
         nH0radv3vEdU6Sh9Nc95qnGkdh5JQYGU5LRA40O6pZHCSCkccUIS9w9vuJj6CrlooH1R
         7XtprQYMmRjtWwGSnazMavVpV/ttf5MDdvDzrxzPMXlUADznIMRBA5X8yqkKTAdnaYVU
         azsUVbwCxgYB5CEeb4e/To4etZWPzn0mwVk9WYlG9uAGHULTsgD/rBQuq35BTMEsJhSW
         h04A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=5GtNh0BGvR7DPfAlMNqPH/fQtkcx3y8XIxYdxvp75Ko=;
        b=rfqGyuCtF2y8vEfDZ5M+W+aqHuKFR4u4Rr8ySbUiaoJtBDJzTGcrajrzxigfXHRXgq
         3XAjI2nQP7UkvpAP/B3c49sGmSjx3Hm7H1MBHpYa5sRcWxA3JRspqYkXsIZ8Tl4kxDK2
         nb6Lb3Q4LvKs94Bnh7XqhwhXlojzmVPg0oBZX5VUwpnlzZ7OwSeGzdXnPXlFa427T7E+
         MBlnVuPBCiiGU6oRDqym72mFEfxt8yRyjxk3y5MNUQ5mRmA0ikvu4wfwPwhNPqDvp+OJ
         FfxjvvB0jhINtDZsboYgdm93lSgh1XOyItWP017eottct2adrM/5YWpqldIJk7OJZUtx
         Eapg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u13si504993ybp.439.2019.06.05.23.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 23:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5666vEe046105
	for <linux-mm@kvack.org>; Thu, 6 Jun 2019 02:15:37 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sxw4ygru5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jun 2019 02:15:37 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Jun 2019 07:15:35 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 6 Jun 2019 07:15:30 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x566FTuV17432996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 6 Jun 2019 06:15:29 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 402574207B;
	Thu,  6 Jun 2019 06:15:29 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F234B4205E;
	Thu,  6 Jun 2019 06:15:27 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  6 Jun 2019 06:15:27 +0000 (GMT)
Date: Thu, 6 Jun 2019 09:15:26 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, hannes@cmpxchg.org,
        jiangshanlai@gmail.com, lizefan@huawei.com, bsd@redhat.com,
        dan.j.williams@intel.com, dave.hansen@intel.com, juri.lelli@redhat.com,
        mhocko@kernel.org, peterz@infradead.org, steven.sistare@oracle.com,
        tglx@linutronix.de, tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
 <20190605135319.GK374014@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605135319.GK374014@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19060606-0020-0000-0000-00000346FEB7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060606-0021-0000-0000-0000219A1108
Message-Id: <20190606061525.GD23056@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-06_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906060046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On Wed, Jun 05, 2019 at 06:53:19AM -0700, Tejun Heo wrote:
> Hello, Daniel.
> 
> On Wed, Jun 05, 2019 at 09:36:45AM -0400, Daniel Jordan wrote:
> > My use case for this work is kernel multithreading, the series formerly known
> > as ktask[2] that I'm now trying to combine with padata according to feedback
> > from the last post.  Helper threads in a multithreaded job may consume lots of
> > resources that aren't properly accounted to the cgroup of the task that started
> > the job.
> 
> Can you please go into more details on the use cases?

If I remember correctly, the original Bandan's work was about using
workqueues instead of kthreads in vhost. 
 
> For memory and io, we're generally going for remote charging, where a
> kthread explicitly says who the specific io or allocation is for,
> combined with selective back-charging, where the resource is charged
> and consumed unconditionally even if that would put the usage above
> the current limits temporarily.  From what I've been seeing recently,
> combination of the two give us really good control quality without
> being too invasive across the stack.
> 
> CPU doesn't have a backcharging mechanism yet and depending on the use
> case, we *might* need to put kthreads in different cgroups.  However,
> such use cases might not be that abundant and there may be gotaches
> which require them to be force-executed and back-charged (e.g. fs
> compression from global reclaim).
> 
> Thanks.
> 
> -- 
> tejun
> 

-- 
Sincerely yours,
Mike.

