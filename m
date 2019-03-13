Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C91FEC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 20:02:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76A982075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 20:02:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bGh1kutl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76A982075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D6E18E001F; Wed, 13 Mar 2019 16:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0889C8E0001; Wed, 13 Mar 2019 16:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDF948E001F; Wed, 13 Mar 2019 16:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C721E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:02:07 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id x87so4011223ita.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 13:02:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AtBAoBWfQ92g/h0jn7C7rV5DlEJTC6rv3QAp7/w/8Co=;
        b=oNyy1dfYKFroB00EmHCspUOU0rDzjxwjcYxg75+58RPoUzMtpySFo+0NHUStQ344HG
         V0RP8YRocFhpQYfwgqDLJ+7h27L9wuwUaauFTDCYUsMNfBPP2PET8Gt26C2PZ8sY+/Hg
         ssbUsQxpzssuW+xFB6Fy7h7tUftxzD5UtOLmTdXi5u1VlFyE1ULFcDS5syN3NWGApzA+
         c7C1c73rQ2K2qAt5EW0qEpz1tvC9uKrnN7FsQek7M1TM8sLIpTih5B0JH/My05R9o2VX
         FHe3UZuyNbvVSz55Y6goFYcDb44Yzu3wQ3nZYIKEPp3dsSATE4baXbfpFwkoKbXcsM6V
         piOg==
X-Gm-Message-State: APjAAAW0TMeOUEJtNOnhPx1+G3nuROY6IX8xVI7LKhYyjDU8NNeCk3SL
	roDLLMCIweA4ibNsLo7lUo5rGFDZChZH4fnjTnVMtk1CNf7mZvc6sP3mdQly4WPYOPVzhPSBnLQ
	jfCwZL/nQKpjQY0fqYGT2+z4NU//kG+QUjz9Nx0ttIAj1eQvT7/WTaqJq8c+23tOvjg==
X-Received: by 2002:a24:4d15:: with SMTP id l21mr2554857itb.64.1552507327618;
        Wed, 13 Mar 2019 13:02:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXVzlTPrU0hpXq0YxbH8sZkonrBwGQqlFlZmmHkdUpppWm6L3wBdDTklsSkbky80RdrIGj
X-Received: by 2002:a24:4d15:: with SMTP id l21mr2554810itb.64.1552507326725;
        Wed, 13 Mar 2019 13:02:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552507326; cv=none;
        d=google.com; s=arc-20160816;
        b=Z4y/QN9XiVOb2/c4PMOcobNlyaHvAOAWDZbIGuiMtPE56JJi87PAKR/tOfjbJrRhCd
         OiXjnjlaqxBznpf/D4u9iJVhxGuGQdKnV11Y+1x0i9pGEeTKoW84ieyrk2TV3dY5DDBi
         QyOag/GlwMc/qpN5M2soG/uM7J2W86QF/EiisKZPOtQw9dCtkecn/GTp+1Lmjodtby42
         kLeev12CLe4vZobySNnOaloq+J5Fs3TK+cYakr4+RynP1hY5V5j4KglfALmxD4LwnMYC
         Dl5f1JqSEkHV2fx93CDkPQlZrkR6KFVEqvcHCg4oQzxTE6dmO7D13uo+ZlRy45OhCPmm
         4fQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=AtBAoBWfQ92g/h0jn7C7rV5DlEJTC6rv3QAp7/w/8Co=;
        b=vC30FHq5AnnGX1vZGlwk4EKILxgWaIHwZ9l5tZ2+QhelNDc6Y0LIUMfQ0u676R6yns
         ASds9LcB8BPYtkXdiX1ZMI0Jwm5Jh/9BbXwRBS5quQ7cqkHrXoWm1Zev84z4Ffqa9lud
         7Q56coO5amrjXLiAjr5R7NwkXr3cXjw/e7pAtZZueKgp9NSB/E/Jqyco3Gr/SiocjWCO
         7OnXcbr661/zzT8lrMmQG2PUbDNugyzx1c8QjmAON3kF6tm6K+jiX7f1EgQPojPg0b2+
         +lZRs6ftIwS9rjiMAY7IgLB9KiiDsnxsTI5GPg/k2WKeWfQvrINLvMdlkz8LwxFk1mve
         01TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bGh1kutl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o5si7065200jam.81.2019.03.13.13.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 13:02:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bGh1kutl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2DJwxnX112519;
	Wed, 13 Mar 2019 20:01:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=AtBAoBWfQ92g/h0jn7C7rV5DlEJTC6rv3QAp7/w/8Co=;
 b=bGh1kutlaBX9tZaDGFzyE1XGgTUVs18/4uz765iaJsw+6I910sVzJnDuF7bdEHtFNYWc
 QqUwndVcj2dZ+IGCvky7EFIzyK9BSYl8WWFLnA02EaSpfvShx8+1+40q+SQ2lPApvt/e
 wKD0Xiud1DXNeckZ211i0Gc96yhVmLPGlbRNLZV335Lzkhfspr5O97LABI8SSP5Q9pld
 X2tK4OLUl6fFdGDDTKErjWWe75q9cGWD3/pYcOJVivSi+a/Ey0+puKrhqNNTJvcmjv/8
 FmLmzcWDndEkqCaUK5IkQcuhxhtqBKGcO+5DQDxsfj8y4BlfFf8iDAhwUmYuJPqbAYgh sw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2r430ewrvh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Mar 2019 20:01:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2DK1mc4007502
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Mar 2019 20:01:48 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2DK1gxM016936;
	Wed, 13 Mar 2019 20:01:42 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Mar 2019 13:01:42 -0700
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Andrea Arcangeli <aarcange@redhat.com>,
        Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org,
        Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
        Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
        Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
        Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-fsdevel@vger.kernel.org,
        "Dr . David Alan Gilbert"
 <dgilbert@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e1fcdd99-20d3-c161-8a05-b98b8036137c@oracle.com>
Date: Wed, 13 Mar 2019 13:01:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190313185230.GH25147@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9194 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903130137
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/13/19 11:52 AM, Andrea Arcangeli wrote:
> 
> hugetlbfs is more complicated to detect, because even if you inherit
> it from fork(), the services that mounts the fs may be in a different
> container than the one that Oracle that uses userfaultfd later on down
> the road from a different context. And I don't think it would be ok to
> allow running userfaultfd just because you can open a file in an
> hugetlbfs file system. With /dev/kvm it's a bit different, that's
> chmod o-r by default.. no luser should be able to open it.
> 
> Unless somebody suggests a consistent way to make hugetlbfs "just
> work" (like we could achieve clean with CRIU and KVM), I think Oracle
> will need a one liner change in the Oracle setup to echo into that
> file in addition of running the hugetlbfs mount.

I think you are suggesting the DB setup process enable uffd for all users.
Correct?

This may be too simple, and I don't really like group access, but how about
just defining a uffd group?  If you are in the group you can make uffd
system calls.
-- 
Mike Kravetz

