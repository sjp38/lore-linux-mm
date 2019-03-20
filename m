Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97819C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:15:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4743920811
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:15:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="I4MFqD4e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4743920811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFDAE6B0003; Tue, 19 Mar 2019 20:15:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAB8D6B0006; Tue, 19 Mar 2019 20:15:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9C676B0007; Tue, 19 Mar 2019 20:15:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5646B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:15:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so624236pfn.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:15:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=JzKfgOBbaoVH9pmp6GyGxjfhu9ko3sMvr9QDvovZSwY=;
        b=qPDAQA4zxqBHFbKXn8d40pOTk7QEoDFA+njdzgiqamOHeOIp2MuTUDu4ZCPHgmeM5k
         yxKJYztFeDM2f4FXGmZLx8GebeR7K1G6onCfTgDaHJLNTfLsNEL8DTZqlwE/+q4Tkjsi
         smEu4F8pWiQfx9/pJrRIiwxvv07PQR0tGEMnGaOgcAhlDlmX6706zJASEaAUVfjRUSBB
         T65n5KEOSnwS2bsjn5fXDSgbC1o23YmD7RJCW+K+NK2slBq1kwxX5wdKs4geTkPBxWgX
         i4brb6tRovUD2TvZqBJ6Cxvr5n1+VOaL2rxTKVlkmA0f/yxj2OPmIdDCdqOI4Eh7TfUu
         Ilcw==
X-Gm-Message-State: APjAAAVIz6OKGURkAV3NW5AHdDWBNcoNL1xdOw+FR8UNKtcoNi9aKMMK
	0yhDJw1hR7l2GDpOyWEYNTIb6N3aX4J6BxVV8nLdTxNutzpDwi4hyh/A7CHwvfMxoqe2WC1WDlk
	UCHmYAAyNqOTZsliN+CX94TJdQFb73H2gCiE6b3eyeauwTkuglUZTM3i2pCnUPWweTg==
X-Received: by 2002:a63:1b21:: with SMTP id b33mr4468661pgb.245.1553040914132;
        Tue, 19 Mar 2019 17:15:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE2w8wXqfWxvEOOXZ85sj9uzdj7MUOjiHnR+APxaO3kwWQP8Hc950lObxL/lXvhHAeyCAa
X-Received: by 2002:a63:1b21:: with SMTP id b33mr4468586pgb.245.1553040913132;
        Tue, 19 Mar 2019 17:15:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040913; cv=none;
        d=google.com; s=arc-20160816;
        b=sr5/daoeoDK7ods+eO6QDi67ssiZ8zsjbJdB0S7JlBBYkYsav07ZRsN/bdotwLB1fu
         XRftv8abYQIqPHBrC0l3QHhTBAPfWrNaIObEiyDNs0kBqWxD11TkC+mWymsjTziiOC+s
         8JOoOEVn3f11ez9ObX50XCOvslRziumKVaUJbc8tmoG63sbaQhJDK2qnRCGhZTHv6FRC
         xuHd8qmliwBHLqoav2vmTwywBe5xeZJyrjgg2d+xex3vu/PMQrGB+hWo5ob16QbBdfe8
         n26zv0z6cJ3gwOvfcC9lCQCZNkzm31SIcgeW11byKld6HVfisbiXZIKdx5XT7jsZj+kP
         U5MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=JzKfgOBbaoVH9pmp6GyGxjfhu9ko3sMvr9QDvovZSwY=;
        b=tcAM1HrrJqpSsEbqn0jdVePSbZ0+aA1NE8oUj32+Mow5gNypG8Dy/SfxZ8GpHDzEPQ
         vmuTPo6cGhoVTFu4dL1tLaz17ArXulme6qSq6EivdgrGuIVDiE+bhs+Yb441nkmimfPX
         e8Wf1Cgtr+IquGLEfivfr5ONSg87akX7ohDiJz8iDESLruM+bASb1t7eCfawng7JVFCK
         tKS007Aqqeu5GTU78z/yzR0T6BzN5JyxRL75YLnur6O0ZduksGq0a4O+2WGHClAL02Ka
         J43cvGIo6X/jbTQNhqQJxDk1+w4ucKSWmxXskRYuhwh+uvrj5ntbgQEuwgwx4w3Rabx/
         uh4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I4MFqD4e;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id o8si288825pfh.136.2019.03.19.17.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 17:15:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I4MFqD4e;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9186120000>; Tue, 19 Mar 2019 17:15:14 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 17:15:12 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 19 Mar 2019 17:15:12 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 20 Mar
 2019 00:15:12 +0000
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>, <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com> <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard> <20190319220654.GC3096@redhat.com>
 <20190319235752.GB26298@dastard>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <e091a534-2b24-f632-a3bb-342958512815@nvidia.com>
Date: Tue, 19 Mar 2019 17:15:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319235752.GB26298@dastard>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553040915; bh=JzKfgOBbaoVH9pmp6GyGxjfhu9ko3sMvr9QDvovZSwY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=I4MFqD4eEiuzA5NlvzD55jVQhcTiA3I4SFlvhPa3mUXdLBjXVKf2y2yKsPdOkmw5r
	 7WW93xZmuA69Iqz1sdjjcnzpldvNdKMdlAPJv/OWWgpnsfRAj59w+ainBQoQX5flpH
	 Rj0rpTdE4Wyy6ECsEWJveymWT5VHNQ87cYxhxjm3oL6Z4UYYddlG1h6+JNbxqBeb9y
	 y0k0wQ/UhADbGt414GKbQM8A5eDTe3w9EvWNDQU+eFdnwg26wyv9euuSkboLKPdNZE
	 ftRF7qaxfBfaY2r1snR5Jotc2RM+OOr7vISZPOKGuuljIHR7xeQYvrQc+mjuTYOt0D
	 tb6PntrfpDGNQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 4:57 PM, Dave Chinner wrote:
> On Tue, Mar 19, 2019 at 06:06:55PM -0400, Jerome Glisse wrote:
>> On Wed, Mar 20, 2019 at 08:23:46AM +1100, Dave Chinner wrote:
>>> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
>>>> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
>>>>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>>>>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>> [...]
>>>> Forgot to mention one thing, we had a discussion with Andrea and Jan
>>>> about set_page_dirty() and Andrea had the good idea of maybe doing
>>>> the set_page_dirty() at GUP time (when GUP with write) not when the
>>>> GUP user calls put_page(). We can do that by setting the dirty bit
>>>> in the pte for instance. They are few bonus of doing things that way:
>>>>     - amortize the cost of calling set_page_dirty() (ie one call for
>>>>       GUP and page_mkclean()
>>>>     - it is always safe to do so at GUP time (ie the pte has write
>>>>       permission and thus the page is in correct state)
>>>>     - safe from truncate race
>>>>     - no need to ever lock the page
>>>
>>> I seem to have missed this conversation, so please excuse me for
>>
>> The set_page_dirty() at GUP was in a private discussion (it started
>> on another topic and drifted away to set_page_dirty()).
>>
>>> asking a stupid question: if it's a file backed page, what prevents
>>> background writeback from cleaning the dirty page ~30s into a long
>>> term pin? i.e. I don't see anything in this proposal that prevents
>>> the page from being cleaned by writeback and putting us straight
>>> back into the situation where a long term RDMA is writing to a clean
>>> page....
>>
>> So this patchset does not solve this issue.
> 
> OK, so it just kicks the can further down the road.

Hi Dave,

My take on this is that all of the viable solution proposals so far require
tracking of gup-pinned pages. That's why I'm trying to get started now on 
at least the tracking aspects: it seems like the tracking part is now well
understood. And it does have some lead time, because I expect the call site
conversions probably have to go through various maintainers' trees.

However, if you are thinking that this is unwise, and that's it's smarter 
to wait until the entire design is completely worked out, I'm open to that,
too. 

Thoughts?

thanks,
-- 
John Hubbard
NVIDIA

> 
>>     [3..N] decide what to do for GUPed page, so far the plans seems
>>          to be to keep the page always dirty and never allow page
>>          write back to restore the page in a clean state. This does
>>          disable thing like COW and other fs feature but at least
>>          it seems to be the best thing we can do.
> 
> So the plan for GUP vs writeback so far is "break fsync()"? :)
> 
> We might need to work on that a bit more...
> 
> Cheers,
> 
> Dave.
> 

