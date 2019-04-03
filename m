Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 702D5C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:08:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12CD7206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:08:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ThHYq2VJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12CD7206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A771A6B0266; Wed,  3 Apr 2019 12:08:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26576B026A; Wed,  3 Apr 2019 12:08:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 917626B026B; Wed,  3 Apr 2019 12:08:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4936B0266
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:08:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so7896349ede.3
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:08:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=Qa48Suyz500z7A2yWyZLvBEvJHp5kd9ufgcGoK7MTZY=;
        b=LHIDilHkMpeqXXSat3PrFp9Y2L1IdIHFFf6SjwKrUwTDySjmArJS9YZnM7KAKKvIXN
         1I5DmHPnkFRl3LfmRDE8ENT+iU/MUWnKDXBI8j+tb23JD49NVj/p3LW8sz2jVwWMTAQX
         eAlNzOBNQLe+cDWkheT1XrRCgplJdmaB92HEugpXNyFOuzhYo26yVumASGmSbRhMS9gD
         EIG5/3WQALLmFFU7DgtzYcnzaTZvDR8idbczRlqcIr2vGier4wW+X2NKWE9rwTp355fP
         LlGw32keurb8Au3KDPIALkJg3lje/BO4wVEDmXaDUKrPn4949KuP/ExPpZAl4iUaXTN9
         GIRw==
X-Gm-Message-State: APjAAAVeX6Rhe0uHvENPilAwV2dI/I7dfq8EwViI0Nhvme7obDuqZl36
	Drqb6yXkYblDQnwIL6OUEeJwyoxFwPtBb7MibsqcpSf6awWykip8FrCeisx7f0qK6k68hVMJJur
	Y3nKXtTrQhF8do1SOQHQAPwtd+NzRA7FmarO935XmcDUOk5RzjuS/jNGvPBAto8Oe8g==
X-Received: by 2002:a50:ad83:: with SMTP id a3mr291016edd.21.1554307731811;
        Wed, 03 Apr 2019 09:08:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNRvxbXgGlsCccZWWXEjpKmBDxfZHcYkfgNdxMp0N26XD05pHla9sIJRvOfDXpXGbOdzyQ
X-Received: by 2002:a50:ad83:: with SMTP id a3mr290963edd.21.1554307730969;
        Wed, 03 Apr 2019 09:08:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554307730; cv=none;
        d=google.com; s=arc-20160816;
        b=ivH+a27dTF00phG8oQ0sh+10JdqB4B3XjkcaffAJr/IwrGe5Vn1Ied4ZqI8QFGz826
         hRYL3ofv7PA08uLuj55VrzkSvdYm2IOWfsr+mjmK27Y8d0nQZkI311rFYlR6899Fm7EN
         HmPbb/Xy3ujkpC501/eGX1hY3YMBWElkmd3TUBDdK8H9Z7ISH6u3G5bRo0OOCV+CuYH1
         BqoVe17Sxuug5tqDL+Cg1SeS4wRsRLQZWq+O5RPhkuRHvV2EfuZ9dCD9tZqLzdoTraiw
         ohEylrLUgMTh4V5dQ+Lk8Ed5ZGJimjgB29yEpTb7EPmJN55Lp/mGOFJ0YYITPBEe4EZX
         kJiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=Qa48Suyz500z7A2yWyZLvBEvJHp5kd9ufgcGoK7MTZY=;
        b=ouGzKMWKA95LTkR/Ic383s3QkTQsBuJ+HfiHuVFECGs95Ws+7u80Kotz4zKYd+XJZz
         TtII9ZC0i6XZSoCfjvMWCWWcRqlGptjPKAg/D4ETnC8Wd7V/6mZDtq6YbE1k/9o/PyjF
         CdjnQAMbxl1uhXcIjh633zl845NyhLfylCGQoOPjSIuwUoE5V10GuvJOjykt9qlF/uxI
         PET0pAXyASFsLjjDn/iiwbnqykd1MWBE1EGNRPOVi7QrzI3YMGs7PfD3FkYGLSaopiVM
         y/x6z6H1bo0AmJO0BvIU+IPGXqR7zQgtJXWIz+Utka5laPpScM65Ax2mEmQkRtBJH0+T
         RZ/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ThHYq2VJ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h6si3893407eja.76.2019.04.03.09.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 09:08:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ThHYq2VJ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33G4NAs096077;
	Wed, 3 Apr 2019 16:06:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Qa48Suyz500z7A2yWyZLvBEvJHp5kd9ufgcGoK7MTZY=;
 b=ThHYq2VJOnrKxy/DbuCf19v7JxOwgc2BrWEa4Dj9DsthPi1CT3F1hNCHp+TuIOHnEqvd
 F0NpGaY3M1YKKaYed8wMK3LJfPPm6mPwDXEWwoEnHmRwiqTKIG7YVsahmBAucIuK7nQX
 B4CSwPzR5T4okTUZoEX+DkkqfeMAskNvkWWpTZfd/Ya5yCG7P2stfViIB48iaJDKG1+B
 Fv7HQoI+z6PpvfdQEjLFXmjfASHiKOGPQ396PbPSdC/Zy0j6yEJ1k6I3SdkiuRL6Bhu6
 DoianK/kCG92MSG6jD8gfD1Tm3chIi6j/ds0LUwl9oMiW5HLf9rTz6ckICA6swYHAx/f Fw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2rhyvta28k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:06:39 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33G5akN018598;
	Wed, 3 Apr 2019 16:06:39 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2rm8f668wq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:06:38 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33G6bXr007088;
	Wed, 3 Apr 2019 16:06:37 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 09:06:37 -0700
Date: Wed, 3 Apr 2019 12:07:02 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190403160702.uevv74wajpqtggo7@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <20190402150424.5cf64e19deeafa58fc6c1a9f@linux-foundation.org>
 <20190402234357.tn3tik4r7k6nbrau@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402234357.tn3tik4r7k6nbrau@linux-r8p5>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030109
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 04:43:57PM -0700, Davidlohr Bueso wrote:
> On Tue, 02 Apr 2019, Andrew Morton wrote:
> 
> > Also, we didn't remove any down_write(mmap_sem)s from core code so I'm
> > thinking that the benefit of removing a few mmap_sem-takings from a few
> > obscure drivers (sorry ;)) is pretty small.
> 
> afaik porting the remaining incorrect users of locked_vm to pinned_vm was
> the next step before this one, which made converting locked_vm to atomic
> hardly worth it. Daniel?
 
Right, as you know I tried those incorrect users first, but there were concerns
about user-visible changes regarding RLIMIT_MEMLOCK and pinned_vm/locked_vm
without the accounting problem between all three being solved.

To my knowledge no one has a solution for that, so in the meantime I'm taking
the incremental step of getting rid of mmap_sem for locked_vm users.  The
locked_vm -> pinned_vm conversion can happen later.

