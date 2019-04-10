Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42549C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D10A42070D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:56:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SrD1QHES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D10A42070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 156AC6B0003; Wed, 10 Apr 2019 14:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106C56B0005; Wed, 10 Apr 2019 14:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F115A6B0006; Wed, 10 Apr 2019 14:56:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBBC96B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:56:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x5so2320931pll.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cwOcozjN6cwhWsjps1Q9SRP/9MhFfdu70Q14B/5RcGw=;
        b=OxWE2Yn4S2eCgqC4e5Ip9ZNdKFvBKQjnLK1bT/BZW2PluIkFeKGSnTLk2E1F4Fo8hn
         i+BUGSlnFQK2irJBVBbQZbEpmhz3Ro9ccsz6Ucqgud/iQopVC5o4uw+KhoYr1TTDbqCE
         vhTdXHEd2e327KXWGcS6eQblHqzoNLT98hDy+88tJguR066AgqZ+y8JasCc84o+p7f+D
         fu6LH2zQ+/HUcXHQQwtmhNrJK1sVR9W+bWpQJtIsbDQhL58o4N1wHy20ZOBkWFEtXhd9
         r9YUZcBNq/ymw17uUCd/9ZcuZVQLbiaK15c18G4NsA+AUMq7j2c9jBbLHTxkDtnJUXUQ
         QUwQ==
X-Gm-Message-State: APjAAAXMlDwrZZmuxJNzz2gP90+tGXkpdEglJa023FDnaqjCj8q1q7+E
	gkKjqxgn0g5j05Nm/Nf0XXTfouqh3vX2A2VrzNncEpKpkDb8ik+UANKLinwRvJDdSbBLW2x/Cvj
	5P4a9rNHglkx3ZgaNPLtnMku0VA2EBYoMQqUryP/H8fK59PI3tUZGdBMyXCtNFdc52g==
X-Received: by 2002:a63:3857:: with SMTP id h23mr41588981pgn.305.1554922603827;
        Wed, 10 Apr 2019 11:56:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR3olY6O8Yj8wn2rkJSSCrbiyE+ysT/D3qEVGo2CdJL2cxLo4BNMrVwbPcKaMXDDcWdF58
X-Received: by 2002:a63:3857:: with SMTP id h23mr41588937pgn.305.1554922603053;
        Wed, 10 Apr 2019 11:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554922603; cv=none;
        d=google.com; s=arc-20160816;
        b=KF0AyKamDB6l0k/uuIX5L6NJt5X0RNVJow7rEimip9iq+znXQmtkTUzjyqhsVrQoj+
         7hJZG5C5hwxeeH41gs5DZAjGm9d+k3MjmkeRX9KtN4Js45hRcr8BAkLAmar1V3ECo0RX
         d28erl7jitrdBi90Y9u2sbkxQdqT5VRuJ74vEv6qLCmoufrx73hcBDRoIMEk02bKFWvS
         1hsmap8OT5+DkaMes1Yg4zFaJ2i8niO81p+PoQPp9Qv3ebWy/hxYHW9d4fGtFkTGl3Gu
         WqBE3TrFIc1SSwV6SAm+6k03l2wyEGrjXiISmMUut66KkU01CmXj0X+WnpGIX/IM0gw2
         0Wjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=cwOcozjN6cwhWsjps1Q9SRP/9MhFfdu70Q14B/5RcGw=;
        b=gvgk7taZHso5410rGpQEXkYxXqDEklIBxNVHMJtwIfjgWYupkFVZwi9WY1OQEPp5xO
         Anz1n2JwEMDTbn96DiQVR8lbeLfsXfTRFx14AVyElJBwOWmpj4eeyyZDIIKVCX87O8eu
         0NSHRYsZ+LduZgr2+jjUMPIE+QbAydIrr7h5jY95Pla4Oz3AIEM5xJar7rmOtR4waVOD
         IouBDP2AZzBOLMZ5mgs8HdSsinKVCfrpHtuwVLy4HzG6cUM2+kBMPnbI/98xjf1f/yf2
         k3ZTPX11tGbv3Y00377KecL3KGvAgIT7SNH/fThAs+ze+HeFt4/QkbS4kynRGGVm2CQ+
         m4SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SrD1QHES;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a20si3763230pgw.465.2019.04.10.11.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 11:56:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SrD1QHES;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3AIiWGP133140;
	Wed, 10 Apr 2019 18:56:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=cwOcozjN6cwhWsjps1Q9SRP/9MhFfdu70Q14B/5RcGw=;
 b=SrD1QHES3qeXim/kkNch/K7DMVOCbisZ0cNINA3V/jLNjTPT4DP6oFcl+0bX+aUvjw/h
 fxjtNtaZ9FSs0/kKcmrX70+vT75VnUyMrXosd6O5p/GTR0hg0TdGIwT1pNp9sUwpiWkG
 6rsq3xYHBEovnuI03VTHoOj+SI4ov9n0zkkZuEs84bVxgw39ZR6Pd8BFYD8hIoKg0Ts6
 FlZ4xYMIZ4nx1r4PaSctGQ7RHDJCXh8IVwecsckLUfCB123oLTu5wAe4wdcdw3Wn0IRh
 5YUoOPnpAvmE0hVWIM2mPK+mii5//V0vCRDQ6XVOVKo9ls7I1Zr3aWPP8TDf6TYI4nEc LA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rphmen2wd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Apr 2019 18:56:34 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3AItuTn152618;
	Wed, 10 Apr 2019 18:56:34 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rpkek2x4d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Apr 2019 18:56:34 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3AIuV6c016358;
	Wed, 10 Apr 2019 18:56:32 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 10 Apr 2019 11:56:31 -0700
Subject: Re: [PATCH] hugetlbfs: fix protential null pointer dereference
To: yuyufen <yuyufen@huawei.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com,
        mhocko@kernel.org
References: <20190410025037.144872-1-yuyufen@huawei.com>
 <e8dd99bb-c357-962a-9f29-b7f25c636714@oracle.com>
 <1a43c780-3ded-a7bc-391e-f85295eb942d@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c7daf190-6a8b-0e3a-7eba-854d01962675@oracle.com>
Date: Wed, 10 Apr 2019 11:56:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1a43c780-3ded-a7bc-391e-f85295eb942d@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9223 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904100123
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9223 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904100123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/9/19 9:20 PM, yuyufen wrote:
> Hi, Mike
> 
> On 2019/4/10 11:38, Mike Kravetz wrote:
>> On 4/9/19 7:50 PM, Yufen Yu wrote:
>>> After commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map"),
>>> i_mapping->private_data will be NULL for mode that is not regular and link.
>>> Then, it might cause NULL pointer derefernce in hugetlb_reserve_pages()
>>> when do_mmap. We can avoid protential null pointer dereference by
>>> judging whether it have been allocated.
>>>
>>> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Cc: Michal Hocko <mhocko@kernel.org>
>>> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
>> Thanks for catching this.  I mistakenly thought all the code was checking
>> for NULL resv_map.  That certainly is one (and only) place where it is not
>> checked.  Have you verified that this is possible?  Should be pretty easy
>> to do.  If you have not, I can try to verify tomorrow.
> 
> I honestly say that I don't have verified.

I do not believe it is possible to hit this condition in the existing code.
Why?  hugetlb_reserve_pages is only called from two places:
1) hugetlb_file_setup. In this case the inode is created immediately before
   the call with S_IFREG.  Hence a regular file so resv_map created.
2) hugetlbfs_file_mmap called via do_mmap.  In do_mmap, there is the following
   check:
        if (!file->f_op->mmap)
                return -ENODEV;
   In the hugetlbfs inode creation code (hugetlbfs_get_inode), note that
   inode->i_fop = &hugetlbfs_file_operations (containing hugetlbfs_file_mmap)
   is only set for inodes of type S_IFREG.  And, resv_map are created
   for these.  So, mmap will not call hugetlbfs_file_mmap for non-S_IFREG
   hugetlbfs inode.  Instead, it will return ENODEV.

Even if we can not hit this condition today, I still believe it would be
a good idea to make this type of change.  It would prevent a possible NULL
dereference in case the structure of code changes in the future.  However,
unless I am mistaken this is not needed as an urgent fix.

-- 
Mike Kravetz

