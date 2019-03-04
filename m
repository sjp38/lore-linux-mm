Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E357C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 18:29:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3549B20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 18:29:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="F5U7Apqk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3549B20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9398E0003; Mon,  4 Mar 2019 13:29:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84E208E0001; Mon,  4 Mar 2019 13:29:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8C68E0003; Mon,  4 Mar 2019 13:29:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2397C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 13:29:42 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y1so5692530pgo.0
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 10:29:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iTZRfcoGZHsfdcunl2nlWqFf9M0yDE8914vhM69NWh4=;
        b=Y9/bN2g7CGs48gqt8oeZT5zSv5m6YOAwPa+At5CU8fCVPoYPklHPJ8RuNRKOsMDglr
         ATioHEhdBO4vxINjCwHSdmbr3tawqLQQiSxx/jzRWspKLGR2OZhiWGahgTBYyLUB+kKn
         pNMlETWBcwqZLcnoZftZHX65p7F+2AWrVxJxmBjOWiirNf3jnD51WibeZgShaGF/GR6M
         xksNXk0chZzYAzAFulSZIKX+eQf+pW2VU6/1CjqP5yddttdNxWmI1E7m+rt6B5/C9Fse
         05YAWEw2rgDi7kvBwkpq77ui660mWEJGNrccmTgVCM5iX+hfmOpdBN/K6IoXRlH0kdQz
         2GKg==
X-Gm-Message-State: AHQUAubVw6TsWt4XAEK230yZCQeU+PiUClv+xGGrNb031xLImHOXKNi+
	jHmzdxQGOcOCQkas7FanwGTpzUBKYEFxz3ecxtmrQKRsZYPMVmrYiJqJ8oSl3P5FcrerAw/ZOAA
	kFdlmJc+0GHruSam3+uzDE9kEJqmIPwjitvB71vadSwEdb3tRX1haJWrjHSylk6cDfA==
X-Received: by 2002:a62:b61a:: with SMTP id j26mr21155587pff.151.1551724181716;
        Mon, 04 Mar 2019 10:29:41 -0800 (PST)
X-Google-Smtp-Source: APXvYqySzgpWa8zez5Nw3RVLH5G8zziwH1QFRHktoUQub0UeGlvPo3S2VLBwn0lx3/RbkZzRno//
X-Received: by 2002:a62:b61a:: with SMTP id j26mr21155475pff.151.1551724179832;
        Mon, 04 Mar 2019 10:29:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551724179; cv=none;
        d=google.com; s=arc-20160816;
        b=pZef2vU4W002NQO7EiSj6sRjoX6FcxgYisMMgTqK1+xZQCMOAQjl0fh6IROA212dNm
         01d/V9zyvY5MS9UMDd+LYcIQVN/hjF4B9JgM+XHKKlNFG34z0ZWs2j5ZRBo2ZppQWtT1
         Z7stkly6pVpB4MGXcSagTCOM4YJt/e+eXT62CisP+y/b58K+/ExSMie5kh4I1K3C8EhE
         YXplMv5K2+J5X6RNngakBD0TlFnz8YsOftZVJJRC/aUc9ADwxhQXU3uw0enU8xPa2sBd
         smxAmOa/R85qmET6vQk+ST4bak8s6DPNkbRJrKaXnaEx50KncQJWmc1KhQhMmFcXA6gU
         gWKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=iTZRfcoGZHsfdcunl2nlWqFf9M0yDE8914vhM69NWh4=;
        b=eAXdqptemvLLQv0acqJHWhHyxOIQ+ATw+Fh2HtmflEQmd7feYKJqnilwd6uykZm442
         mmA4rbs7LVBRpQjlrFOxTFivrOUV4VMXRAcgwjSAZ/NBL2JMOv1XZzWkUOqd8m4YfJvI
         RJfAg4OqI2anIIwNU0x88V9RiIx/7QuUXL3VwKwI4gyyvF5j8uRYIv3CPxFqFH1A54Kb
         EmoPXRhkWXXBltSAub9apQaF0zEwWAM1rYdHWS6ZbEdfBC/aBWnQ9jjO7MvOX7uFYnEa
         tlSSFFb/SoduiYOGjyKhvhIW/il01lyXVCi7ZY9kyKO/xcwWf3ZZHeF+t10ks3v+bto+
         OFGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F5U7Apqk;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 75si5641139pgb.230.2019.03.04.10.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 10:29:39 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F5U7Apqk;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x24IOQ02066707;
	Mon, 4 Mar 2019 18:29:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=iTZRfcoGZHsfdcunl2nlWqFf9M0yDE8914vhM69NWh4=;
 b=F5U7ApqkchNQ9QKskKrJgvWscctRJ21BBQaSNBldW+snKRJHosSYZGjpkqbXHXcaa1/j
 KJV+PKWiHTi54tgrTWao73MvdVmFjxwyMVWfPBOfQ7NM9MjeCo4E+kN01sng+ALWm6Pe
 Fc9l4V5muQg3q0Cjucspo/EkeOjokIz06rQ3mNPETKM1J184AziO1+lDVzZqJi+e4vT/
 LAijwgl/hJlA4HB5zvqzy87vtfXVIWBrIYVbPuohjc1f01JIr6JCzhipJWy/tZwF8YNy
 HeVPwrgXUVA2MQVEyuRcAtCPStgDndS0/2eyH6Axtpz8BH7ci01sMb1/zAKkAKEzvcWu 6A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qyjfr8dyq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 04 Mar 2019 18:29:35 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x24ITXlT021745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 4 Mar 2019 18:29:34 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x24ITWD1025745;
	Mon, 4 Mar 2019 18:29:33 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 04 Mar 2019 10:29:32 -0800
Subject: Re: [PATCH] hugetlbfs: fix memory leak for resv_map
To: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org
References: <20190302104713.31467-1-yuyufen@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <16c7f90d-ad52-4255-f937-b585b649ce57@oracle.com>
Date: Mon, 4 Mar 2019 10:29:31 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190302104713.31467-1-yuyufen@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9185 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903040132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for finding this issue.

On 3/2/19 2:47 AM, Yufen Yu wrote:
> When .mknod create a block device file in hugetlbfs, it will
> allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
> For now, inode->i_mapping->private_data is used to point the resv_map.
> However, when open the device, bd_acquire() will set i_mapping as
> bd_inode->imapping, result in resv_map memory leak.

We are certainly leaking the resv_map.

> We fix the leak by adding a new entry resv_map in hugetlbfs_inode_info.
> It can store resv_map pointer.

This approach preserves the way the existing code always allocates a
resv_map at inode allocation time.  However, it does add an extra word
to every hugetlbfs inode.  My first thought was, why not special case
the block/char inode creation to not allocate a resv_map?  After all,
it is not used in this case.  In fact, we only need/use the resv_map
when mmap'ing a regular file.  It is a waste to allocate the structure
in all other cases.

It seems like we should be able to wait until a call to hugetlb_reserve_pages()
to allocate the inode specific resv_map in much the same way we do for
private mappings.  We could then remove the resv_map allocation at inode
creation time.  Of course, we would still need the code to free the structure
when the inode is destroyed.

I have not looked too closely at this approach, and there may be some
unknown issues.  However, it would address the leak you discovered and
would result in less memory used for hugetlbfs inodes that are never
mmap'ed.

Any thoughts on this approach?

I know it is beyond the scope of your patch.  If you do not want to try this,
I can code up something in a couple days.
-- 
Mike Kravetz

