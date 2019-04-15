Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91075C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438D42075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:11:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gWOWE6C0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438D42075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE7C36B0003; Mon, 15 Apr 2019 13:11:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C721A6B0006; Mon, 15 Apr 2019 13:11:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B133D6B0007; Mon, 15 Apr 2019 13:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 761266B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:11:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id p11so11694983plr.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UJEsUTCNFfIyBbbnOrDE7pUwegFdTm9ebJcWsc3y794=;
        b=gTjbQBvrk2dAYiZy6n1eDAtzQqujNRt4cSOfeBpsjan3/hd8+OCFFYMswUF6Kl9nf+
         eS+4IajuVahvF98lffxWMwP6hJnRgnp0n5lhzIUjzWrLTT0dGH0giUKDF3uD6L2qrh/B
         V5slZjsGeZ+yA2FShg9P3Zu08alP9Jiy3eAFMQrzFYU2AotpSY1fOQiKEdWCH/WD5xW6
         hw2SjJx1vK7wH6qDWtUitne2BLAUuFHZOgMnHWKVdMgafRIY4L99tXL/lkwN2W8yKNG5
         fYzVFgx0CimjbAdx/0d+K5ZRuQh1Wi5PUTBN+JQfJs8m5BF+8RrLVeaBL0XLCqkt8bSY
         Olmw==
X-Gm-Message-State: APjAAAXGkd1y5g3gkE9omSz1VskLWWQvJiguQrBP0fC6wr2F0jb+r12q
	E1e+kNlY+NqLG9fMbGmHucd5GsSDIvvvXAZA95LQzHxzn2x/ayrwqZG3Z8qfOnfL/UrN3qGYqmv
	rovrNywT8J14oZL/UxsGr3oKhiBwIczLKwuBlKCXkMn4Sw7Ckann83WUo93j5gQr7oA==
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr77596556plb.301.1555348315127;
        Mon, 15 Apr 2019 10:11:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzogxVDfDfVM4PcXBqDPAZRScAO75/qf9Cp9C0VvZ4m05yZISOotkRWRXOdz0f+wWyAJw0
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr77596452plb.301.1555348314139;
        Mon, 15 Apr 2019 10:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555348314; cv=none;
        d=google.com; s=arc-20160816;
        b=00Zhh/LeSMROOqaip650I/tLe6RTCzj19Gc9SQNOzk1e0t5NnLUwOW2v8CkNFbQsNQ
         RhnaYEJ9ibXjzOklfH/fmQcLP96nyCufoeVrMLs82EU6H98sPM3SO3SDNDr4gVYqeFae
         001I2goGbl9jpWVIOzy8/itfteeZ7wTOFho05fiHrGr8nvpUF6WLYvxh6EYmfS5vm4a7
         +JrRPoNA441He4eXbE/cG/2KF8BB0LkclPOSFKHvIt924desTjS7Qc7ehpICVFPJbhyj
         Q395pmFlYFiN9YIEGDjRPAna6Ury8EcmyhfTUJKMsHlbBS0jTmpxALAigbK4ybWc8HsL
         mAqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=UJEsUTCNFfIyBbbnOrDE7pUwegFdTm9ebJcWsc3y794=;
        b=YRnWj5ofg1Mhxz5A1VXvLH/q+K0bU1UnMUdEzq7LhgndKfNbyqExg8H9rYFtIsFTPY
         kL47Z1NqFkow53KxfaoGsIoYEJvRZSefuDAaBt/GJ7rqq1R3P35nzyVK8QS989Nl9ofM
         CE3nIoIJdrUE3aGSRF2DwJ5zmv6kKqXBVGH+07vdYkUPxm3/o/sdT0GFuJ+hBFP8pP2p
         tegc+dPkPCO28UcpDu3CXvd79QxtScLk448rnl0cQGtKyhbQbJv74n2Ebc2GZU8m9WAN
         wXayedD4iwM+hm5HzkJtijtb48V82BhTL2WlPEhN6iy40OsP5C7J36PlU4Kyyt7OYAkj
         GJSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gWOWE6C0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a33si25398365pld.123.2019.04.15.10.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:11:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gWOWE6C0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FH5B4Y107700;
	Mon, 15 Apr 2019 17:11:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=UJEsUTCNFfIyBbbnOrDE7pUwegFdTm9ebJcWsc3y794=;
 b=gWOWE6C04Iu8A35nw9FzfbFeYvpzrLpWwcmL3myzCq+US1Ag7hG0yQj4zoF950Jnwqns
 KEa4Wyuxg78p6PMIIqwKoD6Lfgw136Le28AkAeb5lQ/z7EytBaviVXmUyUeowvQ+/IZd
 maVe2UDewwq0CjTnCTxbEFFZYVx7HBmDykXSb9tgYUMy4aCZmFwM/ka/LEkONoYzutqn
 w/5oMyBDUqo+CvxlypDWcN+64+NJ+JWJzvUVqjjo6K4gD8XfCPS/ila5bjr3eM6e4uGg
 pmF1v3o1ft/Ydg7O+NWhfaSbLw37rT4aAbZmZW8z2Fc7cAL9vJ7e9FrA14AbcI5Vl2xn iw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2ru59d0433-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 17:11:43 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FHA5pS085829;
	Mon, 15 Apr 2019 17:11:42 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2rv2tua2ur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 17:11:42 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3FHBePI014024;
	Mon, 15 Apr 2019 17:11:40 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 15 Apr 2019 10:11:40 -0700
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
To: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Yufen Yu <yuyufen@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
 <20190415091500.GG3366@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
Date: Mon, 15 Apr 2019 10:11:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415091500.GG3366@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904150118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904150118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 2:15 AM, Michal Hocko wrote:
> On Mon 15-04-19 06:16:15, Naoya Horiguchi wrote:
>> On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
>>> On 4/11/19 9:02 PM, Yufen Yu wrote:
>>>> Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>>> ...
>>>> However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
>>>> free or modify i_mapping->private_data that is owned by bdev inode,
>>>> which is not expected!
>>> ...
>>>> We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
>>>> be more reasonable.
>>>
>>> Your patches force me to consider these potential issues.  Thank you!
>>>
>>> The root of all these problems (including the original leak) is that the
>>> open of a block special inode will result in bd_acquire() overwriting the
>>> value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
>>> resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
>>> not free the initially allocated resv_map.  In addition, when the
>>> inode is evicted/destroyed inode->i_mapping may point to an address space
>>> not associated with the hugetlbfs inode.  If code assumes inode->i_mapping
>>> points to hugetlbfs inode address space at evict time, there may be bad
>>> data references or worse.
>>
>> Let me ask a kind of elementary question: is there any good reason/purpose
>> to create and use block special files on hugetlbfs?  I never heard about
>> such usecases.

I am not aware of this as a common use case.  Yufen Yu may be able to provide
more details about how the issue was discovered.  My guess is that it was
discovered via code inspection.

>>                 I guess that the conflict of the usage of ->i_mapping is
>> discovered recently and that's because block special files on hugetlbfs are
>> just not considered until recently or well defined.  So I think that we might
>> be better to begin with defining it first.

Unless I am mistaken, this is just like creating a device special file
in any other filesystem.  Correct?  hugetlbfs is just some place for the
inode/file to reside.  What happens when you open/ioctl/close/etc the file
is really dependent on the vfs layer and underlying driver.

> A absolutely agree. Hugetlbfs is overly complicated even without that.
> So if this is merely "we have tried it and it has blown up" kinda thing
> then just refuse the create blockdev files or document it as undefined.
> You need a root to do so anyway.

Can we just refuse to create device special files in hugetlbfs?  Do we need
to worry about breaking any potential users?  I honestly do not know if anyone
does this today.  However, if they did I believe things would "just work".
The only known issue is leaking a resv_map structure when the inode is
destroyed.  I doubt anyone would notice that leak today.

Let me do a little more research.  I think this can all be cleaned up by
making hugetlbfs always operate on the address space embedded in the inode.
If nothing else, a change or explanation should be added as to why most code
operates on inode->mapping and one place operates on &inode->i_data.
-- 
Mike Kravetz

