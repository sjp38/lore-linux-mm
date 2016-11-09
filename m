Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5B66B0253
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:29:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id l8so104244460iti.6
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:29:28 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id 20si1155891iom.115.2016.11.09.13.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:29:28 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id e187so24483897itc.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:29:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161109212341.GC12670@char.us.oracle.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com> <20161109212341.GC12670@char.us.oracle.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 9 Nov 2016 13:29:27 -0800
Message-ID: <CAKgT0UdyKnERu5Vv8F2gw1XvFD4VczP5_C3nYZoC6=zcysjb3A@mail.gmail.com>
Subject: Re: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Nov 9, 2016 at 1:23 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Wed, Nov 09, 2016 at 10:19:57AM -0500, Alexander Duyck wrote:
>> This patch series is a subset of the patches originally submitted with the
>> above patch title.  Specifically all of these patches relate to the
>> swiotlb.
>>
>> I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
>> currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
>> no updates are required for the previous set then this patch set can be
>> ignored since most of the changes are just cosmetic.
>
> I already had tested v2 so if you have patches that you want to put on top
> of that please do send them.

I will rebase and if anything looks like it needs to be urgently fixed
I'll resubmit.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
