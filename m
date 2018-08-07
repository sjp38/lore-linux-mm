Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72D1E6B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:52:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u9-v6so11597128wmc.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:52:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e204-v6sor438001wma.48.2018.08.07.07.52.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 07:52:40 -0700 (PDT)
Date: Tue, 7 Aug 2018 16:52:38 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Message-ID: <20180807145238.GA5512@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
 <20180807141922.GA5244@techadventures.net>
 <d0ea36f7-9329-f947-3862-011827aee20c@redhat.com>
 <20180807142826.GB5309@techadventures.net>
 <6d07f588-cc40-132e-2d89-26e00fff5a88@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d07f588-cc40-132e-2d89-26e00fff5a88@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 04:41:33PM +0200, David Hildenbrand wrote:
> I am not close to an RFC (spent most time looking into the details -
> still have plenty to learn in the MM area - and wondering on how to
> handle ZONE_DEVICE). It might take some time for me to get something
> clean up and running.

That is probably the way to go, details like ZONE_DEVICE what I thought
it was about to be easier.
This has been broken for a while, so a few more weeks(or more) will not hurt.
Also, I need to catch up with ZONE_DEVICE myself and I will be on vacation
for a few weeks, so that is it.

Feel free to re-use anything you find useful in these series(in case you find something).

Thanks
-- 
Oscar Salvador
SUSE L3
