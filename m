Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A20E3C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BB46214C6
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:36:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xaEwORUt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BB46214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E75B28E0008; Fri,  1 Feb 2019 17:36:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E252D8E0001; Fri,  1 Feb 2019 17:36:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3AFD8E0008; Fri,  1 Feb 2019 17:36:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91B578E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:36:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id q20so193111pls.4
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:36:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CsyhCuppqVUAVoFQMCJMMMABqMa2RyFMhSVg4Pg/oDU=;
        b=LA1czXBvOw7ILNspdH3jcLy+VyW3YYEwOGYovHd5V51le6KVFmf0Gpcm23Bq+IBE84
         cTAZiLGq0ohIritDdDDi9JYrptxd+VSoAD1xbSa0l2mjbxaZgMhonSdk3eTwtTvair9C
         DCInVR0lvINvLyKIvjgaflzO0A8u+YQO5NAfWJwwXbeUUPm2WFM06N9so4v8l5dpgwZQ
         eAPl/Ys3FrtQaPp3paw1QYIXc7/lRz1pgZgg9TugngBVTpVM53vpcVPeSFK+n7q8aGIs
         +ubvj02UIVEnYJyuFEYUYXJSM+AoVmjKjbXoTwVAP227O4U+YTobH+cquTtv7R7ThGHM
         DAVw==
X-Gm-Message-State: AJcUukeTpH9hXTcY2DYBJuggGZYMEl3MIigYfpZhO644eGH6PGkdsRE7
	0I6x/PlWCbAqdvODXdcuJR4k6Pwg+xUeLt1vzRJ3DzMq8Rh6065TSENiAnT2t7t6Zug0f9OSqI0
	vLDq3BjOKU3/mI0D+1t0IxZYVA15fWTmWMVaMyL4nkZGVy8y86DoymCouSojkqGm8qQ==
X-Received: by 2002:a17:902:9a02:: with SMTP id v2mr42369705plp.180.1549060599242;
        Fri, 01 Feb 2019 14:36:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN79n4GS4Ew+ajFqR8Z1SfSIvwBWCYjPvCkMZYRdcA2tdwAfRgdONUfZwv6LssFq/CAcmo2f
X-Received: by 2002:a17:902:9a02:: with SMTP id v2mr42369668plp.180.1549060598512;
        Fri, 01 Feb 2019 14:36:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549060598; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8unrZevWyrkzt1EV8pliLyTRktAbzDeCUbYDs0FSJ9k1LVhz7o05knuvo9mjeL3RJ
         erkwCJJjwaAI9Vs+fnfmdyEtFnxmolwti+oXnU+Ony/WzaIRQgPeebUQOcjMYX0l0Izy
         4oST+baJQuCnyjzz5/VjzWNi/d+T9hprczUNwFkYVfofT4BcX86ya1F4FcjHKWpzYMpv
         lRZzDkPs00y89adSx1Lri8P5HB3Ozvs4J55m4j8tA5TLPeaOT0HF7Ek4SJfu07FRZ1wO
         X/1CXLxIBezLf7WQC0f+cc3GJA31c+x53qYl65JXsctiwu6B7w556ylzlItgBNawXPjE
         V/tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=CsyhCuppqVUAVoFQMCJMMMABqMa2RyFMhSVg4Pg/oDU=;
        b=fgOQf+PasJ4etTBoy/xKikv8TuzGPu+XNdI5bgxR7DpMohbzDblMoCvzCefmBVpMov
         ExtgodJGPuKPPVZHuz/3QTQ05WGgPv1Uws6S5PhntWUVgoAQgERLaRpEeTBrB5Z/8Qcr
         xJfVIrnwy9doSkPsRmnjc5oSEMexfmH1AjyWLmKc/+/8V786PiLopObdVK7sqkcx2iOC
         3KcE7UBo1o7mLlLOatg6i8HdTQlVjH8HORofI9atsB7U61xavwSAHS6g4VhSWp7WMeKJ
         itbEJGKv652EHYI0qSTrB+DMI98qDFPDMDCP333hr//qTpNKKg7QUWwNqB1C1lF1kPzb
         3Q4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xaEwORUt;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u9si5532665pge.48.2019.02.01.14.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 14:36:38 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xaEwORUt;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x11MXdNe190903;
	Fri, 1 Feb 2019 22:36:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=CsyhCuppqVUAVoFQMCJMMMABqMa2RyFMhSVg4Pg/oDU=;
 b=xaEwORUtZtq/8CUuuE+gH7iqPqSwrqRroTcT9GlGhpEL52xoRdOfgkN9NISuoScIyteN
 mPBtXlWeqph0KN5JRG8cNGVy6DHMQxvAO37dbbiH1AjJ2lF3Bgz5pdNYzQ1WviKal5nP
 srQTzdR1uqETGtP6Nb0RyMQQibuhCfyR4CnlvzdXzkJaoWoX79hHg/oqZPOsTRAsjXdd
 V7XALnKtTso8I+K4omvihfE01kOVHBBY1ZBlVD16kyxWD0X7XDBFecojvzm27UYrWHUw
 ra3my/R6eol/DPXcbATJdftQR0jMr7nby0TOBDaD2PKXAbSDi8q4AYTWpfTO5DqRynew wg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2q8eyv15p3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 01 Feb 2019 22:36:36 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x11MaZoJ000620
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Feb 2019 22:36:35 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x11MaYsi027073;
	Fri, 1 Feb 2019 22:36:34 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 01 Feb 2019 14:36:34 -0800
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
To: Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, stable@vger.kernel.org
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <20190131141238.6D6C220881@mail.kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <205f9878-837d-8203-58ae-2ebd7a063567@oracle.com>
Date: Fri, 1 Feb 2019 14:36:33 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131141238.6D6C220881@mail.kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9154 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902010160
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/19 6:12 AM, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 290408d4a250 hugetlb: hugepage migration core.
> 
> The bot has tested the following trees: v4.20.5, v4.19.18, v4.14.96, v4.9.153, v4.4.172, v3.18.133.
> 
> v4.20.5: Build OK!
> v4.19.18: Build OK!
> v4.14.96: Build OK!
> v4.9.153: Failed to apply! Possible dependencies:
>     2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
> 
> v4.4.172: Failed to apply! Possible dependencies:
>     09cbfeaf1a5a ("mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros")
>     0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
>     2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
>     2a28900be206 ("udf: Export superblock magic to userspace")
>     4420cfd3f51c ("staging: lustre: format properly all comment blocks for LNet core")
>     48b4800a1c6a ("zsmalloc: page migration support")
>     5057dcd0f1aa ("virtio_balloon: export 'available' memory to balloon statistics")
>     52db400fcd50 ("pmem, dax: clean up clear_pmem()")
>     5b7a487cf32d ("f2fs: add customized migrate_page callback")
>     5fd88337d209 ("staging: lustre: fix all conditional comparison to zero in LNet layer")
>     a188222b6ed2 ("net: Rename NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK")
>     b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature")
>     b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
>     bda807d44454 ("mm: migrate: support non-lru movable page migration")
>     c8b8e32d700f ("direct-io: eliminate the offset argument to ->direct_IO")
>     d1a5f2b4d8a1 ("block: use DAX for partition table reads")
>     e10624f8c097 ("pmem: fail io-requests to known bad blocks")
> 
> v3.18.133: Failed to apply! Possible dependencies:
>     0722b1011a5f ("f2fs: set page private for inmemory pages for truncation")
>     1601839e9e5b ("f2fs: fix to release count of meta page in ->invalidatepage")
>     2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
>     31a3268839c1 ("f2fs: cleanup if-statement of phase in gc_data_segment")
>     34ba94bac938 ("f2fs: do not make dirty any inmemory pages")
>     34d67debe02b ("f2fs: add infra struct and helper for inline dir")
>     4634d71ed190 ("f2fs: fix missing kmem_cache_free")
>     487261f39bcd ("f2fs: merge {invalidate,release}page for meta/node/data pages")
>     5b7a487cf32d ("f2fs: add customized migrate_page callback")
>     67298804f344 ("f2fs: introduce struct inode_management to wrap inner fields")
>     769ec6e5b7d4 ("f2fs: call radix_tree_preload before radix_tree_insert")
>     7dda2af83b2b ("f2fs: more fast lookup for gc_inode list")
>     8b26ef98da33 ("f2fs: use rw_semaphore for nat entry lock")
>     8c402946f074 ("f2fs: introduce the number of inode entries")
>     9be32d72becc ("f2fs: do retry operations with cond_resched")
>     9e4ded3f309e ("f2fs: activate f2fs_trace_pid")
>     d5053a34a9cc ("f2fs: introduce -o fastboot for reducing booting time only")
>     e5e7ea3c86e5 ("f2fs: control the memory footprint used by ino entries")
>     f68daeebba5a ("f2fs: keep PagePrivate during releasepage")
> 
> 
> How should we proceed with this patch?

Hello automated Sasha,

First, let's wait for review/ack.  However, the patch does not strictly
'depend' on the functionality of the commits in the lists above.  If/when
this goes upstream I can provide backports for 4.9, 4.4 and 3.18.

-- 
Mike Kravetz

