Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 376EAC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 21:39:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E72AD20657
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 21:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NmPuNZz/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E72AD20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C58F8E0003; Tue, 15 Jan 2019 16:39:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 773E98E0002; Tue, 15 Jan 2019 16:39:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6631E8E0003; Tue, 15 Jan 2019 16:39:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34D458E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:39:20 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id k69so1983821ywa.12
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:39:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=PQJy2KoRlTDwuAHKEBF9mbcBgC8EwEXbZLfrRVfnbhE=;
        b=gG3q/P7bnqyziHtsNfJBPPJO4Hb7JgrRrWXfm3U4z6iQMqLZqss4lsN79ICCxn7Yd1
         HvN5VUFbw0tcUa1l8hpC9N0r4MWlvS7lOxesc+Qph7f2jMF3C5W4wX4j7dvkRx2RrG/t
         Nu/B9KzGeYs/UJAbD6/VaHveuzA3AQsBtl+u6G2XdnNiLSGXibr3HGJ3iaZ+EpXNiSKO
         9N4fFFpyimCwJH2EILxZBREJU0vrdO8zxFjTcX8E7qR+GRO8jW4uAz0HEymlNjWzOmw4
         Arq74v+o5Xr2gRjhFRGyJZ3C9UNhg2dFFq4QMC1+PglBEPYMln4iyx9+dyRrF7QGoywd
         Rqtw==
X-Gm-Message-State: AJcUukfG5IuLekIoaWKWbJbJwXNMSD6u6H6ItR1ZijbWaQLgNJa642Hw
	KMFCNRH+KwB04EgZiRQhEjGQW9+wOYFh1tpEjoGiZ8djXG068ENOosSwKcXRgyIfhcGGJSy1/q5
	2XeCYmMHwjfMrm0HFLkUz7+zcnBDtDb0RWvgADNtjn16VocrMMT4gge86+IxvLpyuIQ==
X-Received: by 2002:a0d:e4c5:: with SMTP id n188mr4918454ywe.349.1547588359834;
        Tue, 15 Jan 2019 13:39:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6rixq/KpkT7paLBWY2s2+kBxEscqn/sOwZBjO1RlObvXqQIQiMxmuxMAJgpeWevBHh6aCX
X-Received: by 2002:a0d:e4c5:: with SMTP id n188mr4918421ywe.349.1547588359163;
        Tue, 15 Jan 2019 13:39:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547588359; cv=none;
        d=google.com; s=arc-20160816;
        b=Mn7nscR4WvNknQmizGRcWMaVR/Cdzrap2gug9RZI+240vdWMv9gbeUcUenZp4DlyIn
         T/x91yc1ro4vV1jb5uEToZ23Kwo623fcq4cJV5/3gV5naBR5a/Bxs1ofYzUkbCZjY6v/
         7ZMbvr6aZuMid+7E2MQu7SFGBIIHEQbJUDrcHrr5q7quqnTSmE/wWD13tpeZdsKY9C+z
         DeNwVdhS1buIMlxmbutSJ9ApF/qioJE6MPXWEje6dVw5egyMplKp7CiV2UYLZSJ3hzJ0
         Xlf336sRR74BG5+iunmOaOYxTrZwdi8h+8PFe5Fo4S/SQo8Ba6i5neusvkXtNr3wQNMb
         3h1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=PQJy2KoRlTDwuAHKEBF9mbcBgC8EwEXbZLfrRVfnbhE=;
        b=JCKIm/FWMOn9aR3XxigIypCbqf1pw0n7FUQW0YLZlEDH450wLC4R/TI0WtTxC+zxxU
         k1lpGs5mL7wtYbqyUO0Rp4fpMGbYn/Osd5dfE5L9BrgDPHFC9xF0NzApfxpSulLgTR3W
         mklFBpWsFIBZ1ySZuTr5fQHpMsQhHQSKVf9VkdWJ+75/yt3OvM4GTFVFw/eQ7vAWZG/5
         LTYQMswrFn6HqHDRp4rpk4CsB5xqfMyrus0in8h5ozb+uPms02HnnUcT0UIJNBgnwj1i
         HlBGOi9hagr0bMsqFN0unHNTU3o7OPIoNhGfFgw40L9h2+W66tYdI9m24+FBBgrnsmhR
         O3WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="NmPuNZz/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z6si2907590ybk.249.2019.01.15.13.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 13:39:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="NmPuNZz/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c3e52f10001>; Tue, 15 Jan 2019 13:38:58 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 15 Jan 2019 13:39:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 15 Jan 2019 13:39:18 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 15 Jan
 2019 21:39:17 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jan Kara <jack@suse.cz>
CC: Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, <tom@talpey.com>,
	Al Viro <viro@zeniv.linux.org.uk>, <benve@cisco.com>, Christoph Hellwig
	<hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>,
	<mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <fdece7f8-7e4f-f679-821f-1d05ed748c15@nvidia.com>
 <20190115083412.GD29524@quack2.suse.cz>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9be3c203-6e44-6b9d-2331-afbcc269d0ff@nvidia.com>
Date: Tue, 15 Jan 2019 13:39:17 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190115083412.GD29524@quack2.suse.cz>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547588338; bh=PQJy2KoRlTDwuAHKEBF9mbcBgC8EwEXbZLfrRVfnbhE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NmPuNZz/AwQn5IGofNFU+LTwSUqYAwFl9sooH6S5IFHOEcYgT+ZlrFlsLW6nssika
	 knPQW5sAfmGMK8Bt2X3XVo0RbeDFVxM1lzBDxbOEAo6ZnNED2UY1v7GiEzWoH93RRN
	 rsEtZMOnhMmIDf5QlWFB5oPbmcaXlA2laapazQoQGs/QUzbwIkkGSqZv3whgL4uyAB
	 tkpTZAXPvw57wYwnOeLIzgiTbpr57i0WPSgS0iZXAWVqFOIIiqSAmE/BDiTALxl/Y3
	 06ebt8reuOlZM9t+Xm+1BMX+jIkJcJzh87shpFY0q0wEOL3pbhJj9GDDNLoFoV3LMI
	 n54hPkmvaQNrA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115213917.Jr928qIvGonmWW0NuSq_8qMFYr93DspkX1-UxcBwMp0@z>

On 1/15/19 12:34 AM, Jan Kara wrote:
> On Mon 14-01-19 11:09:20, John Hubbard wrote:
>> On 1/14/19 9:21 AM, Jerome Glisse wrote:
>>>>
[...]
> 
>> For example, the following already survives a basic boot to graphics mode.
>> It requires a bunch of callsite conversions, and a page flag (neither of which
>> is shown here), and may also have "a few" gross conceptual errors, but take a 
>> peek:
> 
> Thanks for writing this down! Some comments inline.
> 

I appreciate your taking a look at this, Jan. I'm still pretty new to gup.c, 
so it's really good to get an early review.


>> +/*
>> + * Manages the PG_gup_pinned flag.
>> + *
>> + * Note that page->_mapcount counting part of managing that flag, because the
>> + * _mapcount is used to determine if PG_gup_pinned can be cleared, in
>> + * page_mkclean().
>> + */
>> +static void track_gup_page(struct page *page)
>> +{
>> +	page = compound_head(page);
>> +
>> +	lock_page(page);
>> +
>> +	wait_on_page_writeback(page);
> 
> ^^ I'd use wait_for_stable_page() here. That is the standard waiting
> mechanism to use before you allow page modification.

OK, will do. In fact, I initially wanted to use wait_for_stable_page(), but 
hesitated when I saw that it won't necessarily do wait_on_page_writeback(), 
and I then I also remembered Dave Chinner recently mentioned that the policy
decision needed some thought in the future (maybe something about block 
device vs. filesystem policy):

void wait_for_stable_page(struct page *page)
{
	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
		wait_on_page_writeback(page);
}

...but like you say, it's the standard way that fs does this, so we should
just use it.

> 
>> +
>> +	atomic_inc(&page->_mapcount);
>> +	SetPageGupPinned(page);
>> +
>> +	unlock_page(page);
>> +}
>> +
>> +/*
>> + * A variant of track_gup_page() that returns -EBUSY, instead of waiting.
>> + */
>> +static int track_gup_page_atomic(struct page *page)
>> +{
>> +	page = compound_head(page);
>> +
>> +	if (PageWriteback(page) || !trylock_page(page))
>> +		return -EBUSY;
>> +
>> +	if (PageWriteback(page)) {
>> +		unlock_page(page);
>> +		return -EBUSY;
>> +	}
> 
> Here you'd need some helper that would return whether
> wait_for_stable_page() is going to wait. Like would_wait_for_stable_page()
> but maybe you can come up with a better name.

Yes, in order to wait_for_stable_page(), that seems necessary, I agree.


thanks,
-- 
John Hubbard
NVIDIA

