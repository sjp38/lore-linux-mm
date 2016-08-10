Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 084196B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:13:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so89450191pfx.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:13:48 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id dw6si3415997pad.261.2016.08.10.09.13.48
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:13:48 -0700 (PDT)
Date: Wed, 10 Aug 2016 19:13:45 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [REGRESSION] !PageLocked(page) assertion with tcpdump
Message-ID: <20160810161345.GA67522@black.fi.intel.com>
References: <c711e067-0bff-a6cb-3c37-04dfe77d2db1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c711e067-0bff-a6cb-3c37-04dfe77d2db1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 10, 2016 at 07:33:38AM -0700, Laura Abbott wrote:
> Hi,
> 
> There have been several reports[1] of assertions tripping when using
> tcpdump on the latest master:
> 
> [ 1013.718212] device wlp2s0 entered promiscuous mode
> [ 1013.736003] page:ffffea0004380000 count:2 mapcount:0 mapping:
> (null) index:0x0 compound_mapcount: 0
> [ 1013.736013] flags: 0x17ffffc0004000(head)
> [ 1013.736017] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> [ 1013.736044] ------------[ cut here ]------------
> [ 1013.736091] kernel BUG at mm/rmap.c:1288!

The patch below should do the trick.
