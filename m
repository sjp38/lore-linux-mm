Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6165C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F4C7214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:22:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="N+9Ixzzi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F4C7214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D148E0168; Mon, 11 Feb 2019 16:22:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBCD38E0165; Mon, 11 Feb 2019 16:22:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D84948E0168; Mon, 11 Feb 2019 16:22:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A54F68E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:22:14 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so257707ywc.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:22:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=DjZRhIk6nj+66m80d2y4KoL4uboyuqGSUxmbuZ6C5i8=;
        b=d8O8y+gb3cupe2r7FnSxiQbkPb/kytcOcQmv+kWZ4HYP6cOt0TFwmaUGsHkqKmWhNN
         DdvcgIdhLa6itfT2Ihg+OfrdXh9JVAHTZDAbfrDOkpJCukGmjh5mZpXSpfCaFCEyZ/tx
         iAPRxrbX7KfRRYHezh0/gXFr4VjaDTr+qD/mjptAlUpcNwwws4V7jYUJdJ7DlnLfJmYG
         aX4G9tVIrlv5Usf8AZeyCUapDFS6O2Jb2vR+3Iiid4VKVXYLKQ49Ag4TOnpI+h+35gqP
         90NwsU5tLifHz7y1eMDW8CFoIt7IstsTVievmI1W0j3/1gGxeG/sHTq6igVcCf0s8fvg
         ursg==
X-Gm-Message-State: AHQUAubsAMEAexU+r3nq520dN9fL6yfgBHynXsYwHgvAULJrNnAu69Pr
	NqwmCbyYMwtStI2xIBjAQboGH907UtAaT7ARwq+rNVL43aEgCi8ijqHP9czTSD6BbI9dPDX43wD
	lDDqA4U32mWEJdiZwXFbZ6rprrksdir0tlOYhBZEoHIsEe+t3ovuwsKBpHPhoe0kXGg==
X-Received: by 2002:a81:2f03:: with SMTP id v3mr234712ywv.136.1549920134382;
        Mon, 11 Feb 2019 13:22:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbgUSfAFaZdEjOQSJU+dVY8R0Q3GlUktCU9K2nZhjD7NSJEJg2C2WskOEW9zCZPdb7B78jL
X-Received: by 2002:a81:2f03:: with SMTP id v3mr234683ywv.136.1549920133839;
        Mon, 11 Feb 2019 13:22:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549920133; cv=none;
        d=google.com; s=arc-20160816;
        b=LsjFd1CCkl8VZoxYWo6ZuQ9lzdiODoFaPnUTxXOpVa1eqQFG1uPkxl5lsY8MXsXwm3
         mPMeSDwZwoyyzaD4btCAkeqH3Rf9OVIEbSVvTHNDrLcsktvRGWpDKAWN8/myu7w8baw/
         nYyUHM7Y5w12kum9q1AlFPjnRd217KoYneDdHmkhdtR10Tsvv1P/Dndm74M50SvVmQ3p
         8x814ZGi+Q7VPRHIjdEDxzD4djqtdVSQDc1NncQ5r0zafhHb3FH6ddTuTgNZBwXuRU+O
         7Kxn79ugJ7S8CjSLVcKZzR6p3Wv5Y26v2PLh3BlwscDoqypikrDiLhZ9sgA+RpsByDfh
         s21Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=DjZRhIk6nj+66m80d2y4KoL4uboyuqGSUxmbuZ6C5i8=;
        b=0gN6N9TxLf6NQFERagZ6l1CMzQnQ+IzkSb/DG4RrmoNp0ywlFbbTHx7BdPQR03OdTw
         xyWXuo1fHsVtq2sR/85oInlnK+8/obkXF9aqCRT9msFkzyra3R8DIQjWMVqPJ6ua5S6Z
         /Qqoymh9PmIuOzfyDtdVT7fdirIWnFEbRhHLkO8JLm/PjYcC0sJEmacl2ngxNpNcBoKq
         BkHWLY+QbMVQTQkFd0qayId32pCHH0RwG72ZtGtiL5VkEXlVSAeQQ3fcO19zXne6XaY/
         FKID2uOHOoXpTRvhqKVFoN1x2dsEDLudPeSkR/AmiFAmMvgQ6JDxkDtXFfg10nmeWVOm
         n8Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N+9Ixzzi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 134si6262665ybc.79.2019.02.11.13.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:22:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N+9Ixzzi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61e7620000>; Mon, 11 Feb 2019 13:21:38 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 13:22:12 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 11 Feb 2019 13:22:12 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 21:22:12 +0000
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>
CC: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Dave
 Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>, Doug
 Ledford <dledford@redhat.com>, Matthew Wilcox <willy@infradead.org>,
	<lsf-pc@lists.linux-foundation.org>, linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>, Michal
 Hocko <mhocko@kernel.org>
References: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com>
Date: Mon, 11 Feb 2019 13:22:11 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549920098; bh=DjZRhIk6nj+66m80d2y4KoL4uboyuqGSUxmbuZ6C5i8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=N+9IxzziTXqH/Fz777iPdO26xuw8ZbKxPM7kRnNSRVXNsIaFbmKoZMzMEpboec7Re
	 ljo6HMwO8Y/66jKpjoOzBjlG+8bJ4sZ1YCHUYdZDEvpQZhKbUIDSUZ42zfweoclQJL
	 XbP/TIVO642z/clG3ILn8hZwLlC/hjT/tXOaKiomlGbhpPbci1Mp/68A6pKpTZACeJ
	 Tuj94uUpRl3BLr0QmejPoETKhVMg5B/ojN5UwwUvE2jSV2kzMZoraIiPobHIdalr/A
	 SiLVhoepPUfMnPcdz/xQhlmXYrTYUVcB8GaSUXUijPb+o2kGWiuiGpFMPs35QJ6OG0
	 oazuwFxQPOUMw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 10:19 AM, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
>> On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
[...]
> John's patches will indicate to the FS that the page is gup pinned.  But they
> will not indicate longterm vs not "shorterm".  A shortterm pin could be handled
> as a "real truncate".  So, are we back to needing a longterm "bit" in struct
> page to indicate a longterm pin and allow the FS to perform this "virtual
> write" after truncate?
> 
> Or is it safe to consider all gup pinned pages this way?
> 
> Ira
> 

I mentioned this in another thread, but I'm not great at email threading. :)
Anyway, it seems better to just drop the entire "longterm" concept from the 
internal APIs, and just deal in "it's either gup-pinned *at the moment*, or 
it's not". And let the filesystem respond appropriately. So for a pinned page 
that hits clear_page_dirty_for_io or whatever else care about pinned pages:

-- fire mmu notifiers, revoke leases, generally do everything as if it were a
long term gup pin

-- if it's long term, then you've taken the right actions.

-- if the pin really is short term, everything works great anyway.


The only way that breaks is if longterm pins imply an irreversible action, such
as blocking and waiting in a way that you can't back out of or get interrupted
out of. And the design doesn't seem to be going in that direction, right?

thanks,
-- 
John Hubbard
NVIDIA

