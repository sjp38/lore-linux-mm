Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30C50C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9C5B20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:52:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iBnN7klp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9C5B20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7795A8E0003; Wed,  6 Mar 2019 18:52:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FFE38E0002; Wed,  6 Mar 2019 18:52:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A0D28E0003; Wed,  6 Mar 2019 18:52:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12ADD8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:52:46 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u8so15421602pfm.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:52:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BMrIGD4+Ll3KedNdKEQNKdpbSQxsK+Hld/zEqg1yvvE=;
        b=XCU1h7bz96dQLkAk2FAyHMSCSxZu/u1qOOsPf6Nn7XOCD4iC41ww7QFktAn9a7wlSo
         7tkAm+r62p6WsqUcjysXmJJHvMeC+dPo1hscvdcmsNwY+uGzRa1M37YXrRVKTFJ/8Qy6
         q82zwG1i+3KP+8xiLFyxjGlP137u4y823e+o6eJtaw+yBebU+4yUvD7iQkDar3uYdeaI
         LyuAA5XWL3wp7NMQSA25EzTIuQM8jxxlfTzq8hB4qeygn58kLlbXrSAfiQMDgF/iIcQ5
         yCIH/zyVn8hckUUpp+l6k3IqQpl8GUCrHnEuodCBFPQhKoALWVHFT6mX0yG48mucN/mY
         Bszg==
X-Gm-Message-State: APjAAAWh7a7Yt+E1A5wpJ6cvTx0KA4Tk53j48gogjhmDJTUOXZK+ioal
	V1PiVpVQS3wTRJcGFxN/RrKPkGb8nnXFTvUgLAG2uVN7UK4MytS/E/StUsBrkLQnvi5/E+cVr8S
	7rYgJBm9lpBjyWf3usIswvEQBENzipY37+DjeXyxYXP1KHv3i8wxQqSiOOEEJhKjYUA==
X-Received: by 2002:a17:902:2d24:: with SMTP id o33mr4693427plb.157.1551916365610;
        Wed, 06 Mar 2019 15:52:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqxFbHjfy1yNO1WqF+zToJDrm84KqLarUmUuc3WNoYAnt0VqJO+TMXpd3/njOWLR34VK9cW6
X-Received: by 2002:a17:902:2d24:: with SMTP id o33mr4693372plb.157.1551916364749;
        Wed, 06 Mar 2019 15:52:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551916364; cv=none;
        d=google.com; s=arc-20160816;
        b=V2l8Yq1AG0q3gc3cPhsIXXdaRHEdmHZEtRkHtORxP2e4KUB9bqM5AxFyxzvglcmZXm
         Xk4Qsa1+T1Q7j4baueXwqdInqEldnsepTianpORP3v/l9IeQplx8U9dkqxsdUy6QsaoY
         qLqlgxI2MUvpsKoHUkNybk8USKZaI6io7K0Qzu6NDi98PVdJMtKcvLQT4qvtDFn/iyHT
         dfnYoapFThWxYdfLQ2GIfPriMWT+wHLGSbkPtZgL7nTupoUdY3BGCC+SONibAg6cX36L
         AEK/XKssx8ufS773Y4iS2VQ4uLt/6rcR97CAdfI1VJPYblfa1mWyQp5EL0WtiGu0WkAF
         /0Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=BMrIGD4+Ll3KedNdKEQNKdpbSQxsK+Hld/zEqg1yvvE=;
        b=nco2xpMlf9oI70n/p9AtnTXZoX8GKriipdVCBDej7HbcmaO2UfTYN0p9nfq054C9qv
         06c1B2WTodB/mAh0gFMT/tuO9DuOONGvlmChqcqfHBvK/umxklVTAevqW8H/9bRyRU0z
         oZINBpXHDK9JGV5d/ZFI/JydmK6FN4rCqnT2FCz//RkmpwL/DYy0jOmcnfUCSh19GTur
         jLEQj8Jl6ww2WoUcZtBDR/9/T1HySM/M5+M8gE+2SfSNvPPzke5pArmSpX3uMSI99+OQ
         b5s27XYba0UJ5BoTGmW3Qoozwc8jv4Yxk+KWQ9wFP3M/5ym+vn1ZETmnCpn/VFbY8Ce0
         Nn0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iBnN7klp;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z25si2467768pgv.523.2019.03.06.15.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:52:44 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iBnN7klp;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x26NnQA6114246;
	Wed, 6 Mar 2019 23:52:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=BMrIGD4+Ll3KedNdKEQNKdpbSQxsK+Hld/zEqg1yvvE=;
 b=iBnN7klph75FE67DO0NmnTflO5PcBPdrzLnpM/+/kvgcLm3jA8i2x7Tq3p83k7mJPCcs
 7VYXrMEgXJm7JfD7cduiERfhhK5e2qiFOr4t7w5Kh20Fs00BmXT54CwKg0bRtJBP4ll7
 Xk4eIn1lRqlHiAwEwmZyxWrwZ/zFmJhUBtHO/fVLy9gj80GtRTsdvoKFpLX7rNe2H4ko
 HOmYfT+WG/RruWeLSM/t7uhFoZYWqosuu3GxuSSaX/rAXlj9zTFNKMj9KI9eNREnAN9L
 85YPl14WccJjEV2F31GzXBslKH2zY8cJsyVd+yrYKOI6nPMVcEnQlt75Cv7gmbUOPHKk 7g== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qyjfrpwcp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 06 Mar 2019 23:52:40 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x26NqdWi032025
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 6 Mar 2019 23:52:39 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x26NqcIQ029066;
	Wed, 6 Mar 2019 23:52:39 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 06 Mar 2019 15:52:38 -0800
Subject: Re: [PATCH v2] hugetlbfs: fix memory leak for resv_map
To: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org
References: <20190306061007.61645-1-yuyufen@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ac030f5b-3d9c-9a71-bd39-1c1f707bc931@oracle.com>
Date: Wed, 6 Mar 2019 15:52:37 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190306061007.61645-1-yuyufen@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9187 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903060162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 10:10 PM, Yufen Yu wrote:
> When .mknod create a block device file in hugetlbfs, it will
> allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
> For now, inode->i_mapping->private_data is used to point the resv_map.
> However, when open the device, bd_acquire() will set i_mapping as
> bd_inode->imapping, result in resv_map memory leak.
> 
> We fix it by waiting until a call to hugetlb_reserve_pages() to allocate
> the inode specific resv_map. We could then remove the resv_map allocation
> at inode creation time.
> 
> Programs to reproduce:
> 	mount -t hugetlbfs nodev hugetlbfs
> 	mknod hugetlbfs/dev b 0 0
> 	exec 30<> hugetlbfs/dev
> 	umount hugetlbfs/
> 
> Signed-off-by: Yufen Yu <yuyufen@huawei.com>

Thank you.  That is the approach I had in mind.

Unfortunately, this patch causes several regressions in the libhugetlbfs
test suite.  I have not debugged to determine exact cause.  

I was unsure about one thing with this approach.  We set
inode->i_mapping->private_data while holding the inode lock, so there
should be no problem there.  However, we access inode_resv_map() in the
page fault path without the inode lock.  The page fault path should get
NULL or a resv_map.  I just wonder if there may be some races where the
fault path may still be seeing NULL.

I can do more debug, but it will take a couple days as I am busy with
other things right now.
-- 
Mike Kravetz

