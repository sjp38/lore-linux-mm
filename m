Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67D6FC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 22:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DC5C2070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 22:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HRHy43z6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC5C2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B71C06B0005; Thu, 20 Jun 2019 18:13:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFC3A8E0002; Thu, 20 Jun 2019 18:13:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99B508E0001; Thu, 20 Jun 2019 18:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72A396B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 18:13:23 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id m1so1753170vkl.11
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:13:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=OsSBTvuyKOZHpYxr7BMRKlrDJF74SMWishCpQlewDkg=;
        b=HmkA9L/8Gmtr0H/joT7wJyC9F0lu7AQesPOxpd5CxfA61PrW/rFlTem0hTdHFToXP2
         03d2NJ703iKnIq3e3ho/2O0yYxX1SU6cfCz+PCDK3G76ph9P+EVg8TeAqBzfPtEK20OM
         qY01KmovhZ6F2F6s4KhHlgE7ZDzmhkafwBapDe1Yqq2WESh4UcxwCXJx/35tRZcF/MJw
         /i1jQzb+SjBeTqnC5BweoFSf7rxXDqTxMdeRTGyuRYRGuDHYLxrD65+brjRJGQghASAH
         ZQ7UfXBPFuFxOSA44n4aNLhRk+7YyQ71ygfQjUovkXQfdlUpHiowSEJzTMQWGUX4FAYj
         dq1w==
X-Gm-Message-State: APjAAAWnpuj1PGTU8yEQj6zbj7vEP1vsW+MMZWG+EByTaPu3vqjTF7Vz
	07qPqEqm8uGP6IFaNL1egqFlP1FvblQLbmG7Nnjg6osGTwnQSCEWqk/wsyvPwLj9O0rmZzYKs5y
	aXizeqfeoDJ1zgUsuwwN/RUQb6PhZlzJyCCkE91x8oGh6/qBOKppartVMAImZzmdcsA==
X-Received: by 2002:ab0:5499:: with SMTP id p25mr66411979uaa.2.1561068803052;
        Thu, 20 Jun 2019 15:13:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1HbELUbZLYUZDvbbj77SjiUrPyoFqTwpr+g+MDcVfioUbLjVY8XcoSag4Omi7mIWDfaUT
X-Received: by 2002:ab0:5499:: with SMTP id p25mr66411948uaa.2.1561068802450;
        Thu, 20 Jun 2019 15:13:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561068802; cv=none;
        d=google.com; s=arc-20160816;
        b=LvWILLxUGfG6Wvv9iHHwE4BsnLhWilnhmeSPBcWbGHxsFUhG0kPalxLuQu0PPlgEeq
         pAkHEB0OoFbvSz2pVRqkoDiadc9YbrjgPrFEE97jrkP0kFz8woc0jJBbHTv6iK8YWiGK
         hL0EP1cx9fGqpyainFSTWf8NmL0bvjtSp5NDriWehml1vAZVuaapr4ES6W5/S5lYD/SZ
         RoViSFa8coazC5v6PUZknz3JO/LOfmEVCrRN/qeVMKJgCi1Z4AwjM+ufDESi9/wf6jZg
         prP4C8zpCL57NbkgH3v/o1eTF+5MMTqSUrU0Q46wHJ7TRzq3iT/Rawx7Kl7NLg9/RQtk
         T3xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=OsSBTvuyKOZHpYxr7BMRKlrDJF74SMWishCpQlewDkg=;
        b=l6PSPD0LNMRukNuM8kRIh409TPby5xP/8WBWVB5iTZxqQ1uKfNDhZMNaqqw82F4Rue
         +JNgj3YjnrRUQtgWAjzj9ecCCTW9XzTQ7gThlN45ZVAN7L7KmTIlvp6SdF4CHctKYIIS
         e7MIScbOwy2MmnB0jsTpN3ccsjtUkK7e2k4sBVfiF3KlVT61ky9WjZEG9cQyQ7XXAxwZ
         QlCbgcjH0twefmhIAsO1q4ylXPq9l7P2iu+pETVv/WwCexsrWEUamC0EtMdv1PzZZtlS
         i5m/jf8UfjgGRNsUaMK48GmK5ocdTHvVyk/eSReO0/77ZprbpnBCgNpt7CemQoU1u+n5
         ZBVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HRHy43z6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w8si131720uag.240.2019.06.20.15.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 15:13:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HRHy43z6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KM3nsv109072;
	Thu, 20 Jun 2019 22:13:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=OsSBTvuyKOZHpYxr7BMRKlrDJF74SMWishCpQlewDkg=;
 b=HRHy43z65mymGGo6sWVVPuVFpItbR12cz3YFYbaCqJGOBgvqYtfpb/PeLVjuuEVqrQv2
 GpZIrIgzJZC0+U+yXwJ1Vqs3qY3UMIfqSIwL3pZPIfdyZff3jwYOEkEcKtjd/YwH/Sq6
 aV/5TlsmcdKu7KhrpVNfWRmjrbQlir4Di4CKy0hExq7FpxJJYc99Sw4feLIcaNKWlvrK
 5xy4bURhqhJGb38LoU38YZ1npKwLTXMnl7fXFWWSALJ4esecgPStCOfTzz7/fuGUuQ5/
 3Ls5Aj1t1c7iY5R0EC3GWYb2yjGGpkr0/0/gtaJLRnwOzAdzATduot/C0pAUHfoTLX0u QQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t7809kgm8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 22:13:13 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5KMCXI6043214;
	Thu, 20 Jun 2019 22:13:12 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t77ypm9eb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 20 Jun 2019 22:13:12 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5KMDCTk044443;
	Thu, 20 Jun 2019 22:13:12 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t77ypm9e2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 22:13:12 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5KMD85F022773;
	Thu, 20 Jun 2019 22:13:09 GMT
Received: from localhost (/10.145.179.81)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 20 Jun 2019 15:13:08 -0700
Date: Thu, 20 Jun 2019 15:13:06 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Theodore Ts'o" <tytso@mit.edu>, matthew.garrett@nebula.com,
        yuchao0@huawei.com, ard.biesheuvel@linaro.org, josef@toxicpanda.com,
        clm@fb.com, adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk,
        jack@suse.com, dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
        reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 1/6] mm/fs: don't allow writes to immutable files
Message-ID: <20190620221306.GD5375@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
 <156022837711.3227213.11787906519006016743.stgit@magnolia>
 <20190620215212.GG4650@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620215212.GG4650@mit.edu>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9294 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=570 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906200158
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 05:52:12PM -0400, Theodore Ts'o wrote:
> On Mon, Jun 10, 2019 at 09:46:17PM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > The chattr manpage has this to say about immutable files:
> > 
> > "A file with the 'i' attribute cannot be modified: it cannot be deleted
> > or renamed, no link can be created to this file, most of the file's
> > metadata can not be modified, and the file can not be opened in write
> > mode."
> > 
> > Once the flag is set, it is enforced for quite a few file operations,
> > such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
> > don't check for immutability when doing a write(), a PROT_WRITE mmap(),
> > a truncate(), or a write to a previously established mmap.
> > 
> > If a program has an open write fd to a file that the administrator
> > subsequently marks immutable, the program still can change the file
> > contents.  Weird!
> > 
> > The ability to write to an immutable file does not follow the manpage
> > promise that immutable files cannot be modified.  Worse yet it's
> > inconsistent with the behavior of other syscalls which don't allow
> > modifications of immutable files.
> > 
> > Therefore, add the necessary checks to make the write, mmap, and
> > truncate behavior consistent with what the manpage says and consistent
> > with other syscalls on filesystems which support IMMUTABLE.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> 
> I note that this patch doesn't allow writes to swap files.  So Amir's
> generic/554 test will still fail for those file systems that don't use
> copy_file_range.

I didn't add any IS_SWAPFILE checks here, so I'm not sure to what you're
referring?

> I'm indifferent as to whether you add a new patch, or include that
> change in this patch, but perhaps we should fix this while we're
> making changes in these code paths?

The swapfile patches should be in a separate patch, which I was planning
to work on but hadn't really gotten around to it.

--D


> 				- Ted

