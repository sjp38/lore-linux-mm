Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A29B7C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 23:14:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 256BB20833
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 23:14:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ef5r+ypH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 256BB20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3698E0002; Wed, 30 Jan 2019 18:14:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2E18E0001; Wed, 30 Jan 2019 18:14:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 843978E0002; Wed, 30 Jan 2019 18:14:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F42D8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:14:16 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so807487pgc.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:14:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oRY8IIy+LzhfOUy5KtCkTy2Mvv+fVM7jDXgCUqjIfj0=;
        b=PEym0MyfwLbxOIFbYimm2kDMUqWd7My1Wc5fp3sE45o8vsW3/xIrNDgpYtzbz74AZm
         T2OAp77jAqc60oA/SzVY2zJrysOmYShlbbB02xog6+9Glycn1AuM/fRwxHCKc55HSaFf
         S34P7gV/Meta7arShCDn/jGFzA4qgrlKpWQdYPAaNfK3h2EUJsM2g9MM2x4JcLt+TIwf
         yWGnzm7n3Do+hJO3tQ5mU9c3jGPql3J9C70FNKImt0xDSezh1Pdidm7Kk439ePancSeD
         bVUGyKAcTwfcajEcYeBabFPsYYLU2dFc3JLqtPXTBu6vJxc3znaM+D01sVwb5oG/0hwS
         BlTg==
X-Gm-Message-State: AJcUukfd33gtA2nudr25vFrQ4pmLVXYv9/TrlhcjYmKWhU0mFMGnbfzd
	KGhAbckhc4n0AewxjMKcT7A8UOJ9vhr80AAVAciG5sBCtXs/nS/zQQh4r73f+VsCmsLkWp2TNJJ
	buN9JzBy7dGvxKsiCH7os/OqT27eOzkiWrs3OZCVwFnuX8lMsMPQHKjpV0L1bAnDpug==
X-Received: by 2002:a63:484c:: with SMTP id x12mr29179995pgk.375.1548890055782;
        Wed, 30 Jan 2019 15:14:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN74k95Kx4tm1AGNkGHiLXcvaBjDNEldJ+RB5PQLAEjPXVN1vb5MP3vgMHEpLv1wGSxegK7v
X-Received: by 2002:a63:484c:: with SMTP id x12mr29179963pgk.375.1548890055121;
        Wed, 30 Jan 2019 15:14:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548890055; cv=none;
        d=google.com; s=arc-20160816;
        b=HekGJzlQfPdF07eKmnDjqgoXlOWc+cRQe7UNYYpiRpSr8qw1Y/gFkHUiT8Oi3CxSnS
         gKeyd4p6jySTKUVLTsVN9Y6UCrKNpWJU2bDl93TaQZo+Gx9kU+fu5oiTp2+BCy35wF/+
         oyzdTV4KVAJbNhwJTPg9rDKgO6smCkQFbw+z+dbs2ygcZ5ffcb48n0HGIlBFRLaIWB/D
         uPF6e6lvcSepT1NQB2PBticYP6mI8WCTIb+tsYx5UuwXrMQb3BOnNNVOEbv46SCXHJaF
         FZHr+MoeVTbmRLO/q4CTIDYiRppK8BcZLFb1BwTA2hkr9iUbTpEKe3ubzDDhwPxJedu+
         ELrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=oRY8IIy+LzhfOUy5KtCkTy2Mvv+fVM7jDXgCUqjIfj0=;
        b=P1oRXEUtVDn6ib0RPW2V2MoHTd3jbxcV+Wqp6egQuOw13VmoefDhvrE+8XwMU7+o7M
         ivUh99Qk/u1ZotDJU5X5RH+qNDDTmj8+hEKvEjtnUokgD4tm+6uSdNUcGY/rC6VlLd8O
         qcMHmUZb+BrlUw0rJOtCDYZVzwcsQA0iB2MLbR/KY5l4ARCZ4uw0IJtXEmVdiAHiv6Cr
         5d44R5Q9kxc9ZvtQiYH1vKgH/YYGojmE3pn+SAso5x2L05mOqH2QWI87cxESmT7DwoMi
         3mO6kdhonrV7YCaglAfLa7OFIgr3C5o3SMTST8gcxvUfgKjEygELQFbAErFYAv6tKFWs
         Racg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ef5r+ypH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m32si2750989pld.86.2019.01.30.15.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 15:14:15 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ef5r+ypH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0UNDoAD083642;
	Wed, 30 Jan 2019 23:14:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=oRY8IIy+LzhfOUy5KtCkTy2Mvv+fVM7jDXgCUqjIfj0=;
 b=Ef5r+ypHarZqKR2GIKCNPyLlXdwxG3W4mZ4MfIHr90RgBOf0jur7zeY0LRt8UvzbCwQv
 FO9C8NmIMXeGFYSpBzcdexYuDWUMSFegFPloaBVQUuA0zHcI9FuEOEbjQFPg3ABI4Ud/
 ng61oqOsGOpDzJgc06svNz7UcpZySiYB0zx91zIWbC8bRRGi2SUvKhSL4HzS6I91krsg
 Be42tKYpeGxhsKS6KIe1VMq7A6CoYyAy9DKkPXGeHiChQesjsCZ52+eBkwgW8SJNDupc
 11vz38sttV6BoxZb2a9Ib2oPseTgyFfd2ClqjAp2ML/45HTIDnw6nxHQyjw3jQ6xHGCd 3w== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2q8d2edrj4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 23:14:09 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0UNE3Wa014722
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 23:14:03 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0UNE2Qe002159;
	Wed, 30 Jan 2019 23:14:02 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 15:14:02 -0800
Subject: Re: [LSF/MM TOPIC] NUMA remote THP vs NUMA local non-THP under
 MADV_HUGEPAGE
To: Andrea Arcangeli <aarcange@redhat.com>, lsf-pc@lists.linux-foundation.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Peter Xu <peterx@redhat.com>,
        Blake Caldwell
 <blake.caldwell@colorado.edu>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>
References: <20190129234058.GH31695@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <609a56e4-c8b7-154f-dcbc-a12817fb22a0@oracle.com>
Date: Wed, 30 Jan 2019 15:14:00 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129234058.GH31695@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901300167
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 3:40 PM, Andrea Arcangeli wrote:
> In addition to the above "NUMA remote THP vs NUMA local non-THP
> tradeoff" topic, there are other developments in "userfaultfd" land that
> are approaching merge readiness and that would be possible to provide a
> short overview about:
> 
> - Peter Xu made significant progress in finalizing the userfaultfd-WP
>   support over the last few months. That feature was planned from the
>   start and it will allow userland to do some new things that weren't
>   possible to achieve before. In addition to synchronously blocking
>   write faults to be resolved by an userland manager, it has also the
>   ability to obsolete the softdirty feature, because it can provide
>   the same information, but with O(1) complexity (as opposed of the
>   current softdirty O(N) complexity) similarly to what the Page
>   Modification Logging (PML) does in hardware for EPT write accesses.

I would be interested in this topic as well.  IIRC, Peter's patches do
not address hugetlbfs support.  I put together patches for this some
time back.  At the time, they worked as well as userfaultfd-WP support
for normal base pages: not too well :).  Once base page support is
finalized, I suspect I will be involved in hugetlbfs support.

-- 
Mike Kravetz

