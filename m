Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0E8BC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:54:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DAAC218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DAAC218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04C018E0002; Thu, 31 Jan 2019 04:54:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F9A8E0001; Thu, 31 Jan 2019 04:54:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2DB38E0002; Thu, 31 Jan 2019 04:54:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B74958E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:54:31 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k90so3007458qte.0
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:54:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=j29xYbLcjFenDOQcVwbD0khVjpUTE4td829ySY51iKY=;
        b=bod8SmGG+y5PhSMsMtsnuE0kWJuhYFjQw2jpH2zjXssM2/rOSshkCGeFruwDXmhHRz
         zI4d7VA9SsUbCHvFQ2cKBYjVlxc84Lnm1l7Mb2tsd443stqzsJXwcPcxhmdZzrI2DReM
         gY9QeacIsTZXLJd9SnRsxb5kQRkVsZeKw2aMHbpMJFYElejp6+Lsus5EleJQC9lC7U/J
         gUeH3m0jd3h41X/4YGetiVZaPPCpUQAWEwCx45DYDAYF2bCIUwHb4PPLSejyiIxPhVbL
         ji1stXUuwswGQ0wFkjvgn7cd+pIvmoQyYEs/nUqsEeQWVAbJlAy4nTBJtl97QKQv95+j
         Y7lA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeD1tAMzn05dnrUpQCH3twLJZw2SdgAnjE2nv0FD9kijNewTVod
	lEVpDLaQxw6oBvxNZAHl8Uu/5ZQraAMCzoORmptHNCHKGPmkEkjpx2iNj+8WOP2Yp5Ms+qfvoy4
	wRADTOLRBfkTRAmDils6jA7Piaa1avLX8aHcxsblZqC1YWiUyIbmZmcf31LpyUKnkBg==
X-Received: by 2002:ac8:3518:: with SMTP id y24mr33082741qtb.241.1548928471505;
        Thu, 31 Jan 2019 01:54:31 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4WVgEP4Q7uVhEEMpQuy3I/0DzxIqW8S4FhAXdhe5q0N4nDnLAvqMoCrzdL3QHubLqFwTPL
X-Received: by 2002:ac8:3518:: with SMTP id y24mr33082720qtb.241.1548928470983;
        Thu, 31 Jan 2019 01:54:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548928470; cv=none;
        d=google.com; s=arc-20160816;
        b=YHQ9zS5VAOInsj1gEw97z/8o0I/bwRMPt0AHJVY+onzk5B0qZ5uYTOZ5lqO/mvScqV
         Y3p3/Mcuu2P/rroWsE5bm6F1rJN/dmu3F3B3CbliRj07MmDqnCDnAGzkvDOHKDJtd+9q
         xRS+xUb22yjdCtQ1LVSf25KiWQA0eWkljRAejy90JWOKXqXsJ3fEjn+1LlEWS1/wL3ky
         Zv3FW2cP+kfsz7dw6uheJiLUrurWfPpsIWewbRJozBzH0Q5urzEK6L4zw3hjhqpD9rSq
         kcbZ6PqlkNA0iaShKaP2PwHc4SuOlB6X1Zki+5ioXKFdFEgMtLOhJbJcyLZ1+D3dL15w
         vnig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=j29xYbLcjFenDOQcVwbD0khVjpUTE4td829ySY51iKY=;
        b=TzqhsDwaYq80x5kJcwEm8D1OfdoGOLlh4x6V6fOU5oXdmt1ttHbv2OJuV/tc5nUUVL
         lFLGwvjoqT4gjeFnhkYnvFRcFCJkDrK5i0MICkduIvaSlK1evoBWF7xJe7gdUtXHZVw/
         DLgyrF+9+NxFMDgipkohkeEQ+xkkXkna9RYBDzqGhGrViJjitpM3824NwDDwe9o9uc1+
         LbS9GVB2lB7xnX8QnC9xIyIugCXt3fwkD/JeUmLCw2MWpZ4FUPTuSC3F3Zf2u7OAEmr4
         HrrACLeAbivNAFo50M9Qa/dCLBHwb32CUiQ37eOj2VtRJ2k0TzZXEwMhrzl6SLOmL4AJ
         uYqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e2si2862271qki.231.2019.01.31.01.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 01:54:30 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V9sJcn113941
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:54:30 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qbv80qjkg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:54:30 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 09:54:28 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 09:54:24 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V9sNhc62914648
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 09:54:23 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C50DF11C058;
	Thu, 31 Jan 2019 09:54:23 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9D3F11C069;
	Thu, 31 Jan 2019 09:54:22 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 09:54:22 +0000 (GMT)
Date: Thu, 31 Jan 2019 11:54:21 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, lsf-pc@lists.linux-foundation.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Blake Caldwell <blake.caldwell@colorado.edu>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
        Andrei Vagin <avagin@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [LSF/MM TOPIC]: userfaultfd (was: [LSF/MM TOPIC] NUMA remote THP
 vs NUMA local non-THP under MADV_HUGEPAGE)
References: <20190129234058.GH31695@redhat.com>
 <20190130081336.GC17937@rapoport-lnx>
 <20190130092302.GA25119@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130092302.GA25119@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013109-0008-0000-0000-000002B93D21
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013109-0009-0000-0000-000022253F10
Message-Id: <20190131095420.GI28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=984 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Wed, Jan 30, 2019 at 05:23:02PM +0800, Peter Xu wrote:
> On Wed, Jan 30, 2019 at 10:13:36AM +0200, Mike Rapoport wrote:
> > 
> > If we are to discuss userfaultfd, I'd like also to bring the subject of COW
> > mappings.
> > The pages populated with UFFDIO_COPY cannot be COW-shared between related
> > processes which unnecessarily increases memory footprint of a migrated
> > process tree.
> > I've posted a patch [1] a (real) while ago, but nobody reacted and I've put
> > this aside.
> > Maybe it's time to discuss it again :)
> 
> Hi, Mike,
> 
> It's interesting to know such a work...
> 
> Since I really don't have much context on this, so sorry if I'm going
> to ask a silly question... but I'd say when reading this I'm thinking
> of KSM.  I think KSM does not suite in this case since when doing
> UFFDIO_COPY_COW it'll contain hinting information while KSM was only
> scanning over the pages between processes which seems to be O(N*N) if
> assuming there're two processes.  However, would it make any sense to
> provide a general interface to scan for same pages between any two
> processes within specific range and merge them if found (rather than a
> specific interface for userfaultfd only)?  Then it might even be used
> by KSM admins (just as an example) when the admin knows exactly that
> memory range (addr1, len) of process A should very probably has many
> same contents as the memory range (addr2, len) of process B?

I haven't really thought about using KSM in our case. Our goal was to make
the VM layout of the migrated processes as close as possible to the
original, including the COW sharing between parent process and its
descendants. For that UFFDIO_COPY_COW seems to be more natural fit than
KSM.

> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

