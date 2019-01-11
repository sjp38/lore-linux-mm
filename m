Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4561D8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:55:40 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d6so4601338wrm.19
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:55:40 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id b84si13275605wme.1.2019.01.11.05.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 05:55:38 -0800 (PST)
Date: Fri, 11 Jan 2019 08:55:39 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190111135538.iv3vvashdnis5b2s@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
 <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
 <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Laura Abbott <labbott@redhat.com>, Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Mike,

On Mon, Jan 07, 2019 at 06:06:21PM -0800, Mike Kravetz wrote:
> On 1/7/19 10:13 AM, Ga�l PORTAY wrote:
> > (...)
> > 
> > I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
> > and it worked (in my case).
> > 
> > But I did not do the proper magic because I am not sure of what should
> > be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 
> 
> If we remove the mutex, I am pretty sure we would want to distinguish
> between the (at least) two types of _EBUSY that can be returned by
> alloc_contig_range().  Seems that the retry logic should be different if
> a page block is busy as opposed to pages within the range.
> 
> I'm busy with other things, but could get to this later this week or early
> next week unless someone else has the time.

Thank you.

To not hesitate to ping me if you need to test things.

Regards,
Gael
