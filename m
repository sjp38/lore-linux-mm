Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 294B8C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0B2A21743
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:39:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="De7r6lQU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0B2A21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C53E6B0007; Tue,  6 Aug 2019 16:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 675C36B0008; Tue,  6 Aug 2019 16:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 517356B000A; Tue,  6 Aug 2019 16:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAD06B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 16:39:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so56642393pfj.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 13:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=kP7gTuC3ZdPRsl2ZM8hKtRsMZoJPCXuUqs/7ZYFYlas=;
        b=YnZNgX3LSsJufTS0kCcV3kkuRtQ/7Z6+GZZZTEond+CW38iA3erZhQeVewLykqtNnN
         6/4hxzIixLB8EsgaIvO9HuL5eD/E1c5ZXnAUgIaz53oTCUFhXhyc+0B2ilMq25v8D9BO
         QTpncuOC+EBXgIT/+29irz8TuhjK1rLZYDE5cbuMWZNGGQnGMQSj886HYHIblufJeIdq
         WWbg3xpGvrxksWd0a4T+w8zJ0jp/kPYKG8mxkZ1soblpprHt4+jiPA2dTSCJKumPfX4e
         MvZ5AiKbiJHzfYk9q5lF5yUToSj9U8cd0lG4cwD+i90ZKHsuvngDnP1NmvfrmvmcZoBa
         DuoQ==
X-Gm-Message-State: APjAAAWLMC1UjkExOTVk/mBDARYbffhDKClTHwpbNh9sIAvYOxG4aSNA
	MUmJj2rUmrtf85l/HlPiUcR8mTMsGe8rksgru6mY78ENk6Y9aiXP9CSEzxZKKnnFwM73kqNbdi6
	co24qnHdCgNayvsekzEwKOcluj5fA6dSZCZP2KjF3gLjstkMG7nZDgxMZmcjQ/wE8ZQ==
X-Received: by 2002:aa7:9f8b:: with SMTP id z11mr5726353pfr.121.1565123961573;
        Tue, 06 Aug 2019 13:39:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMEUMB4gGv2Hh9xfmhlYN8RgI+9DJMIB8GfHzXfxCJ4G8UIpQjdjIa0k2/baFOA7d+77M7
X-Received: by 2002:aa7:9f8b:: with SMTP id z11mr5726303pfr.121.1565123960665;
        Tue, 06 Aug 2019 13:39:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565123960; cv=none;
        d=google.com; s=arc-20160816;
        b=oqYeoVhYLy8wBGx3xjHzzIT/0ZQVVt6568p86Ztwf1GLVV0MVHW7NRjZpI6D5bCNw+
         q552Q9vAa9YpQipw0WnDakMr6IEt/dCO7xKNMrgju2W/KusoZuOIuZH+a41lg0jFuezt
         zeRXot1duLpKFQETclPmzrrqsHy7+jyeNS+9DQejiMLls41xktEJGS7Goiy08obReEv4
         BYdMDK280BR7onm4JryWeqLMC8D7iDl5Bpl7yTKip5cugTHKOpXicqB6OZekBr5fMSn1
         pHzLTApBpccVMGf7cAuHo96jlyB1I3bwb5O3aQCHLAOOPJQHKFIDdZCqw9U06IQDJHf1
         OkQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=kP7gTuC3ZdPRsl2ZM8hKtRsMZoJPCXuUqs/7ZYFYlas=;
        b=KP4+CksCb2ie1BNfGFuC40G4gZGrD5lIl4ivCaFJHnJmDAFDeyLx7wQP9OtphGyuQa
         VOYiTU5mXy60Mh2fbBzorqg4OfIB2nzNorZWDeyVhUZwnh6zM0kj5wnYrxhac/yK2F9f
         QtQVNictVV+SbhBWbm0tmKQsqKRt4lSKyYrqtqZFY3HuY8P08PWlxAjanAjuvD9+Lc4/
         8CTLHAvso120aN8dzpkzakPxJWO2ELqVt7XBXwHWlRvV+gPg1P+MYPVIBezuBNlnaPXw
         57Z42MSoJ+B4l0XebIjcdd6IyeNhMu+kRQBV1zAUtAbq4aKlV5eo9vZ0leeWB6WN2rTm
         +QEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=De7r6lQU;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c22si42918233plz.361.2019.08.06.13.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 13:39:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=De7r6lQU;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d49e5760000>; Tue, 06 Aug 2019 13:39:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 06 Aug 2019 13:39:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 06 Aug 2019 13:39:17 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 6 Aug
 2019 20:39:16 +0000
Subject: Re: [PATCH v2 01/34] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>, Christoph Hellwig <hch@lst.de>, Matthew
 Wilcox <willy@infradead.org>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
 <20190804224915.28669-2-jhubbard@nvidia.com>
 <20190806173945.GA4748@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0e232d84-e6ea-159e-91d4-77e938377161@nvidia.com>
Date: Tue, 6 Aug 2019 13:39:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806173945.GA4748@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565123958; bh=kP7gTuC3ZdPRsl2ZM8hKtRsMZoJPCXuUqs/7ZYFYlas=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=De7r6lQUtbn+GTEsMqljgVKTlQIrCw8ZESuRqc7w4LEYPASOCDyQM6KfNGQouIjYR
	 fh0BckBJVbNT9AbXMQb66ZhMKSleBMpCp4Q67sEppT12m031guaO+mSQiN77Vubrty
	 dLwAVLGyjRDyH8bKz/ie59UuEUjWXDBsQB9IGYcfiHyqrDkJ8dhLAwUMAPjRDqyeiY
	 KJw8zEX2A8/HIUmoazoyVwItiLDzuGpYh0geDqgdodA5dwJzt0S2azlo+PhdmfDHXO
	 6GhmRkzx66GKpfVpxeAm8ztIGHTRgebRJf3i5iJHgoMtdv7J6YmmRpepQCyIfl7KA0
	 CyUb7h3ZsvM+w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 10:39 AM, Ira Weiny wrote:
> On Sun, Aug 04, 2019 at 03:48:42PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
...
>> -
>>  /**
>> - * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
>> - * @pages:  array of pages to be marked dirty and released.
>> + * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
>> + * @pages:  array of pages to be maybe marked dirty, and definitely released.
> 
> Better would be.
> 
> @pages:  array of pages to be put

OK, I'll change to that wording.

> 
>>   * @npages: number of pages in the @pages array.
>> + * @make_dirty: whether to mark the pages dirty
>>   *
>>   * "gup-pinned page" refers to a page that has had one of the get_user_pages()
>>   * variants called on that page.
>>   *
>>   * For each page in the @pages array, make that page (or its head page, if a
>> - * compound page) dirty, if it was previously listed as clean. Then, release
>> - * the page using put_user_page().
>> + * compound page) dirty, if @make_dirty is true, and if the page was previously
>> + * listed as clean. In any case, releases all pages using put_user_page(),
>> + * possibly via put_user_pages(), for the non-dirty case.
> 
> I don't think users of this interface need this level of detail.  I think
> something like.
> 
>  * For each page in the @pages array, release the page.  If @make_dirty is
>  * true, mark the page dirty prior to release.

Yes, it is too wordy, I'll change to that.

> 
...
>> -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
>> -{
>> -	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
>> +	/*
>> +	 * TODO: this can be optimized for huge pages: if a series of pages is
>> +	 * physically contiguous and part of the same compound page, then a
>> +	 * single operation to the head page should suffice.
>> +	 */
> 
> I think this comment belongs to the for loop below...  or just something about
> how to make this and put_user_pages() more efficient.  It is odd, that this is
> the same comment as in put_user_pages()...

Actually I think I'll just delete the comment entirely, it's just noise really.

> 
> The code is good.  So... Other than the comments.
> 
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>


Thanks for the review!


thanks,
-- 
John Hubbard
NVIDIA

