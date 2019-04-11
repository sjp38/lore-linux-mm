Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9733CC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 432C3217D9
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:30:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 432C3217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D44D16B0007; Wed, 10 Apr 2019 23:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF2D26B0008; Wed, 10 Apr 2019 23:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE2E06B000A; Wed, 10 Apr 2019 23:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 930A76B0007
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:30:47 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id j17so2227297otp.9
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:30:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=28mkCRSLGHriGslWrlaW/qpB6G/Exlng75awCTBytsU=;
        b=QbNA8tPpeEzXqXcoEfim/NrQQKWVg8FRNNz27cuNe1L5fIXpcHVqt4I6ei/1MbEkXy
         KYG+8KW9i+p1hKurAib/UEBcAvMzrYSz6AImjXWixp19rspoULzbCz2WyVdPNe9HgT2g
         HmG7bYupuURc+nPEZhLK+rQHRvJLj0DYEJ2ciR5FBOxAsn8wANtKL+RpBz5CiSmznGDH
         yp4nbAiqb8586hR48s2V6c7VXGaeV0kS+/mf+bxeFN07Ex1rLI3FPzf4r9Ic44RMxCuE
         KAz1ALY4Dbkepa08Gd+CcO42tbj0/fh22KwcW3b4IIgKNc3DUg1dJpwQzGA6XjLzMOkd
         y5HA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAVKB5ckNUyalceXyi1wlvJ/a4ePyk7U3mPz3GXLta695Dic/xB9
	yXpp+wmcmvMS32Fxj9EpTCSU4ZDma1SoFBjMBx3pggm9KNIX4TFkgnJ4otBhVJM0gP85jw207bL
	9l2TkmnqXB3dO8ynZm/0vxlK8qGpPunpoH0P8LMzPoRYRcFPxyX/yRcJ/dlHRcTlg2w==
X-Received: by 2002:aca:5f0b:: with SMTP id t11mr4495166oib.14.1554953447242;
        Wed, 10 Apr 2019 20:30:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuvJ789me/0WttJ+g71ZuYFiFQH5b92vwdw8EPx/dlMAHPJDb340wxTWU/R2upsE2/sZRO
X-Received: by 2002:aca:5f0b:: with SMTP id t11mr4495133oib.14.1554953446602;
        Wed, 10 Apr 2019 20:30:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554953446; cv=none;
        d=google.com; s=arc-20160816;
        b=KIkFZ4inV1sDHJHzIXIaJ4r+Nqp9FgMtosh6oV5QHXZq6dIcByjyq3Ti2pMVmTD0ut
         YexEEpQx06QRCOAXTsiUv21FHEpFdNAyzTCnPTMpu0vsAfTP0Np2/dF6myyxPdWIgkfm
         Jl6a8l2BaFEXbySqBwnS2shxPaCvI/4GZktuooz9ADoPXuHe93/WX8gaC2Zw9mj3g8I2
         1AhFBQ3vOxeISCeRbBE7RYfbyNQgxBMyKxE4NHuzPXH7DU/vHGe1dEbZP5i8PNjgyC36
         U5jzUn/g61gsqkV6o46q9aYt/FQASBCALort353W2wJtKwLymW5izFhmxqHT4DZXpBFw
         CZow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=28mkCRSLGHriGslWrlaW/qpB6G/Exlng75awCTBytsU=;
        b=u/iPZwfxmWgSgibBWAo6Qrwijbw/tabVdQAaXaJ4I2ZSd0B4IUQeC9KtEp1GsEQpT+
         S/oEC0eBD6cgrG/wtVfpXDYJn66KbvjGo5rmsHQoI8DIdGlvUYHrMs4NVyRpZAD/6Km0
         QHSIwYdj/FCJ/bogBBuyQSpeveb07+t/F+jiF6C+NZmDPRo+pSNWOtvnV5O//mrbtX46
         zd9QuUhJDp+3r/whuAY1aJshBKpNEOOB+mKPtwVCDYeFo9HVey4pRxVyLm4EqNb0Pi7t
         21EDATcANcsBmu0lfV5Aiqkp93dhW6JmxxISU4LQtv6oAI8OZ73hZWySGZ/dzlkLmnqC
         P+lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id j204si16874012oih.72.2019.04.10.20.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:30:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id D37618A28807C7D683F6;
	Thu, 11 Apr 2019 11:30:41 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Thu, 11 Apr 2019
 11:30:36 +0800
Subject: Re: [PATCH] hugetlbfs: fix protential null pointer dereference
To: Mike Kravetz <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <kirill.shutemov@linux.intel.com>, <n-horiguchi@ah.jp.nec.com>,
	<mhocko@kernel.org>
References: <20190410025037.144872-1-yuyufen@huawei.com>
 <e8dd99bb-c357-962a-9f29-b7f25c636714@oracle.com>
 <1a43c780-3ded-a7bc-391e-f85295eb942d@huawei.com>
 <c7daf190-6a8b-0e3a-7eba-854d01962675@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <2b558d9b-0c43-0974-2eb0-e23d4d02b272@huawei.com>
Date: Thu, 11 Apr 2019 11:30:34 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <c7daf190-6a8b-0e3a-7eba-854d01962675@oracle.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.177.219.49]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/11 2:56, Mike Kravetz wrote:
> On 4/9/19 9:20 PM, yuyufen wrote:
>> Hi, Mike
>>
>> On 2019/4/10 11:38, Mike Kravetz wrote:
>>> On 4/9/19 7:50 PM, Yufen Yu wrote:
>>>> After commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map"),
>>>> i_mapping->private_data will be NULL for mode that is not regular and link.
>>>> Then, it might cause NULL pointer derefernce in hugetlb_reserve_pages()
>>>> when do_mmap. We can avoid protential null pointer dereference by
>>>> judging whether it have been allocated.
>>>>
>>>> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>> Cc: Michal Hocko <mhocko@kernel.org>
>>>> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
>>> Thanks for catching this.  I mistakenly thought all the code was checking
>>> for NULL resv_map.  That certainly is one (and only) place where it is not
>>> checked.  Have you verified that this is possible?  Should be pretty easy
>>> to do.  If you have not, I can try to verify tomorrow.
>> I honestly say that I don't have verified.
> I do not believe it is possible to hit this condition in the existing code.
> Why?  hugetlb_reserve_pages is only called from two places:
> 1) hugetlb_file_setup. In this case the inode is created immediately before
>     the call with S_IFREG.  Hence a regular file so resv_map created.
> 2) hugetlbfs_file_mmap called via do_mmap.  In do_mmap, there is the following
>     check:
>          if (!file->f_op->mmap)
>                  return -ENODEV;
>     In the hugetlbfs inode creation code (hugetlbfs_get_inode), note that
>     inode->i_fop = &hugetlbfs_file_operations (containing hugetlbfs_file_mmap)
>     is only set for inodes of type S_IFREG.  And, resv_map are created
>     for these.  So, mmap will not call hugetlbfs_file_mmap for non-S_IFREG
>     hugetlbfs inode.  Instead, it will return ENODEV.
>
> Even if we can not hit this condition today, I still believe it would be
> a good idea to make this type of change.  It would prevent a possible NULL
> dereference in case the structure of code changes in the future.  However,
> unless I am mistaken this is not needed as an urgent fix.

Thanks for so much detailed explanation. I will resend v2 including 
these suggestion.



