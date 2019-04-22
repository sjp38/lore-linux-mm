Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C3E2C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 15:56:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BD752077C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 15:56:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XI/gGUG+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BD752077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBE556B0006; Mon, 22 Apr 2019 11:56:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C47E06B0007; Mon, 22 Apr 2019 11:56:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0FE36B0008; Mon, 22 Apr 2019 11:56:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 917FF6B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:56:39 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id q203so13018649itb.2
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 08:56:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1YFWhk18nPvj1sYrbNiGZZtKSn/WuN9LenTer33fr9w=;
        b=n19b8Il2pyJQ3jaWYSen9NmW1mI+5cAilfYCqeo/C3oFKQZWgOnYcldYptC7+IJSXL
         PNspyTOiPLAURCO9WuECgqfUkJnIpuCdp5Vdt+n6ovTRNPFERR27wGdOpuw7rzWbnR7b
         YsvuJinQItKF2DPcHx+0oM0xS7rpbhE4vN23R93jIzDEf6JvLgrsJym/G8aVcNDbqow4
         AVUIZMPGT5z/dtbWw6nz2zLnxf7R2P5/faFbO/vozS8jiAFJv7Xf2QBYI9G1P/ahsDnH
         0Oq/Az+M/7SPahcje2HEPLB32CE9NQbgoGoxNPTrAeMS6FEpbtAkKGwVRtcm/8WOmB0f
         6hXA==
X-Gm-Message-State: APjAAAUgphNNbjmQgToHUWIiDX8+VxLVhG/6s6zSw3gUb/R7/1te9a4l
	LQWD9PkTpoXAxgaKq8uQBMuUwkJW3y09OWVA5ZuulILvIDV8wEcQJhnS8OspTa64c9bxv0nkTf6
	dCLlh4izt8otW5pILr+fOcDtb4ZasfBLi0c3JQGStLaQ9BRxOCnlkfVw9XIVoZtMO/w==
X-Received: by 2002:a05:660c:1282:: with SMTP id s2mr13902164ita.47.1555948599290;
        Mon, 22 Apr 2019 08:56:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUn85lLFqPXzXqIvKBvPCVxt5nyzbvyGgKcg+CeZSvjlnukNG7Srp2fU3NtmBZRZGaEgEg
X-Received: by 2002:a05:660c:1282:: with SMTP id s2mr13902109ita.47.1555948598290;
        Mon, 22 Apr 2019 08:56:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555948598; cv=none;
        d=google.com; s=arc-20160816;
        b=reX8/A71Z78VQcCO4ThMNV2UcjQTuQhWhRxV9a46jhbCMvYnpeUonN+YDMRghElFK+
         yUsTl7DnrFPgKycV4duFP8DRtqlW4rxVes9bMPTTZ3eDw61bGtQup8JAkelpZKqtkT9I
         ysTrElmtzRubIewkuKzlHBqxzPmJqZ6wIWfaLu1jmhLTy6omNnYCWvzKSIL1v/HSvv8L
         1XAMkS2Z4iLCOgMQTOkstiWTAtzhba5Wq9qmaqae1NfYYwj17H17FA58I6C4b/zNYUpY
         QxOoVmFCDMbSoLwxJQy56E72ZqpGAXaunFpxh36eU0/Mm7vjSpxgOjcqe5Kbcde+85eH
         2F7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1YFWhk18nPvj1sYrbNiGZZtKSn/WuN9LenTer33fr9w=;
        b=ejlxWQhzkqtj+Oa5OxF+1+PfEcxoxO5H9mabxyzusEh+lFgM8agF7puz+Xj3OBNKlR
         0Q2MZyBELVLoZ7IDpuE3GIu1YpWjzNj2F9n3bbYDx1oeov8JeUaJcnRqdl3j8BNDryAG
         8y4gjgmMB0iO0FHdLJ/aAeN97GJ/tPk2frFbYy+Vcne8PIcD/gZ2tDgmfC4XXGG4YSks
         INj5jZUAFmtmstRKeblC3wganVYSwRkAe0JymJCFGZsKvDop9AhtmfLZRBeOFONiUg/q
         VCLdmlgthRXOZZiA7tzIg9QI6hz5hlDO93ngwaKrLU1pU0s7IkfdccHS8wHipve91AQ5
         Q9qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="XI/gGUG+";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u202si8612605itb.124.2019.04.22.08.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 08:56:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="XI/gGUG+";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3MFiBSe058592;
	Mon, 22 Apr 2019 15:56:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=1YFWhk18nPvj1sYrbNiGZZtKSn/WuN9LenTer33fr9w=;
 b=XI/gGUG+sf++GowsIupWT5i00SK26pIYdJnbzRAIp5hm0bAIDhZ+HttAnN8UusZbg37f
 So4eNeN89QqmJDJYtFelMLz/WtDjWFC4JI13s69D8/mCyTwTiKeEy3M1ol1MZPpLBRVM
 EQAZVzhqPrMY9wC7JFjW77AgLSQwVDPUfzH0zzmc3k3rW5FewyAfituuLXUvJFQdROGx
 GS362yi9MfcSNU3GoqOPsC8ptuJCrMaT5jVDs3wh6y6gqMsMYSdN9CpJPmByAnZi2MJA
 xR2qnfkRNVjMcTAoSXvj5iXxpKQDOeZy3BVYwnRY548p3gsR0HBA8WtDdtlKPvYE71Vc iw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2ryv2pxx83-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Apr 2019 15:56:23 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3MFsMGr013459;
	Mon, 22 Apr 2019 15:54:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2s0f0v0qrs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Apr 2019 15:54:22 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3MFs8g3003588;
	Mon, 22 Apr 2019 15:54:09 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 22 Apr 2019 08:54:08 -0700
Date: Mon, 22 Apr 2019 11:54:37 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Alexey Kardashevskiy <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190422155437.qppyxcbfql34ginr@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
 <20190411095543.GA55197@lakrids.cambridge.arm.com>
 <20190411202807.q2fge33uoduhtehq@ca-dmjordan1.us.oracle.com>
 <20190416163351.5e4e075ddfad0677239fc23a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416163351.5e4e075ddfad0677239fc23a@linux-foundation.org>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=18 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=701
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904220119
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=724 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904220119
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 04:33:51PM -0700, Andrew Morton wrote:

Sorry for the delay, I was on vacation all last week.

> What's the status of this patchset, btw?
> 
> I have a note here that
> powerpc-mmu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch is to be
> updated.

Yes, the series needs a few updates.  v2 should appear in the next day or two.

