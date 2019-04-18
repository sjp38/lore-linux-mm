Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F022C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:56:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0E57217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:56:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="dUpWznY8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0E57217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1DE6B0007; Thu, 18 Apr 2019 11:56:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A22A6B0008; Thu, 18 Apr 2019 11:56:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BC396B000A; Thu, 18 Apr 2019 11:56:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6C96B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:56:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id m13so2386949wrr.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:56:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=j5/kNl/9jg2RLilHg0X3VlWf56T+l7hUmvmFB/1Kfpk=;
        b=UXDb18wt0wqE9Mva6IeHxnPa5OPv98MkNf+7RMDPPD94ud55cZgmfqD+gZwWNRjogL
         7/FtJIoZRx1yc2WDCmYgWIfRzrYro0gpYW3wa/QaY2aKkb6SojxbsqIqsd2dSPc+UunK
         vuueZaDIOXLGz1lDffxHfoE3j4ZVmk7hl5K78j7iGS0UTQOIGaAJtr/84/qTCcVnzkaZ
         B+zTKSDDJTxi6Zf8XC0YEIQW7MhFJK8NLzNfR58sdeOarMprvgZE978dwYi72XPWKTvJ
         uvWyR9fswvSjCwsD+KMMu3KwrVvJFml8imd2dGtF6aGVQI8/Vi6Y72vPFyJfhZ3d/GWm
         2fkQ==
X-Gm-Message-State: APjAAAVAp7OIvlQaXh3to2+W8IeBiLMCxUUEPhrBnYuA6mRsflF4nAx6
	FdAlkTdX8F3KE7C8lVugP4rUz+tL0zQOafhmB1QJn9X51882TTX3A62UNKh0C0AXRW86jKFefC9
	q9nvLv/dYyTYiJDFk2ck3iJNaVwpqmvceev5YitTNnb6POKu/tPoP/RcU3QoYpOlRmg==
X-Received: by 2002:a05:600c:28b:: with SMTP id 11mr3514054wmk.129.1555602978478;
        Thu, 18 Apr 2019 08:56:18 -0700 (PDT)
X-Received: by 2002:a05:600c:28b:: with SMTP id 11mr3514024wmk.129.1555602977768;
        Thu, 18 Apr 2019 08:56:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602977; cv=none;
        d=google.com; s=arc-20160816;
        b=Ggnu3ip+UwEgodzwQQR4DQ/lVLZee1i1MYwrdVbj5PNhbjvzsjd9N5F1V1koyNUV7W
         ui+yEvaTPTUdajjkLhx0ntt4nkEXyLVME2Qjir6Cd1ECexDRt+XJdaIQ3cMA/18DsxRr
         XKBAS2/7j1flIfDhDTXbsI/f+ONefAb3yXQElKH4ymay6W7K3Bn55ZPblKNGV9H7609D
         mNJ1cU2kvES9tn7eecAR8UeiqgJSpNNEzL5mm8G+C9L4lIWrtTEDAze4+zsSePW4Ukke
         4XYUQDurVrGn6Mx7cjxpbEvUjV1bQityj6JkTDaDvyAQeYnonpTKL2v1R1kcfMEBp76X
         /+bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject:dkim-signature;
        bh=j5/kNl/9jg2RLilHg0X3VlWf56T+l7hUmvmFB/1Kfpk=;
        b=J8yeDmGbmjpJzR34U9Ei6aFiuvs8wflSRtqhDjpSL2qZsArYdI7hwT2rat9uK/RIzf
         1upTraDgON2ZrsYaaP6bOf8BuUY4ALrLYUDABgTbhdBB+kHXZwV2w1pDa5uJCQhgMCFE
         wtDetEka0j945FH3m6rVjwR4KQ5yJmS8k3ygO5/ZLnMd2GDg0H9L/On0oQ+mfd1k87jh
         RWy4UHKTF2TLwNAA4HkqxUbWPM/lSu2gQdVKPYxO4Wk/wDiNoxRGWv14O5YoVtsG8b9c
         oh6NsMsJEWDDXKEkWhF/ztfQczvjdhr0tBM5gMJFUwpSsQnvohpe8BLGDnxgSovp8VtD
         gPzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=dUpWznY8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor1476305wmk.13.2019.04.18.08.56.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:56:17 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=dUpWznY8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=j5/kNl/9jg2RLilHg0X3VlWf56T+l7hUmvmFB/1Kfpk=;
        b=dUpWznY8DCr/ZDhSOM3cV0k5qfIfRJC6nUisP93SRbysdHNg3CGhq3n8UsT5+fFob7
         1PTJDpfOm+xxRxRQplTaT/N5lsT9iGMCgrYAh0zsUZ5Pf2joUzgyfiSsvL8BnjGYdWhU
         Z9m2kbKb5FOZPmu1NQggo+FdxFtM0bK5Cr/afQ/hmI7TCM9Ib4Hi79hyuUxCyVpWPtPw
         902vYZBmeCjFCvKH4cGzpeMGk63ysiAFpqT9sukoBJhXKTrhPaqOpxOv8zaarPei5TxP
         /tYVw9mFJFZaml2+Cr05rAVskwOdtCtkINWxHzX/glFgq02re1wk6JiB+Sm+ZEppboYD
         mtBw==
X-Google-Smtp-Source: APXvYqyDxQihas8VahgRTCxS6yq2sfHFGfCAy1vISwrqg0mAuZIX7LkIwS/Li3PIR8LKF/hbphdEiQ==
X-Received: by 2002:a1c:cb0f:: with SMTP id b15mr3657594wmg.88.1555602977287;
        Thu, 18 Apr 2019 08:56:17 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.googlemail.com with ESMTPSA id r18sm3916458wme.18.2019.04.18.08.56.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:56:16 -0700 (PDT)
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Dan Williams <dan.j.williams@intel.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <CAPcyv4hgs8fC+CeLTwqbjVqFE_HFiV-UQBankMBp5NmCniuBFA@mail.gmail.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org,
 Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>,
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
 ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>,
 Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <577a5ba2-6be0-e2b8-a7ae-57da856f9839@plexistor.com>
Date: Thu, 18 Apr 2019 18:56:13 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hgs8fC+CeLTwqbjVqFE_HFiV-UQBankMBp5NmCniuBFA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/04/19 00:54, Dan Williams wrote:
<>
> 
> If it's not a pfn then it shouldn't be an unsigned long named "bv_pfn".
> 

Off course not:
	ulong bv_page_gup;


But I hope it is not needed at all

Thanks
Boaz

