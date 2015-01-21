Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD966B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:58:52 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so24287831iga.0
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:58:52 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id u1si7806216icx.100.2015.01.21.14.58.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 14:58:51 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so3950648igb.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:58:50 -0800 (PST)
Date: Wed, 21 Jan 2015 14:58:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
In-Reply-To: <20150114233630.GA14615@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi> <20150114152225.GB31484@google.com> <20150114233630.GA14615@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Petr Cermak <petrcermak@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Thu, 15 Jan 2015, Kirill A. Shutemov wrote:

> I'm not sure if it should be considered ABI break or not. Just asking.
> 
> I would like to hear opinion from other people.
>  

I think the bigger concern would be that this, and any new line such as 
resettable_hiwater_rss, invalidates itself entirely.  Any process that 
checks the hwm will not know of other processes that reset it, so the 
value itself has no significance anymore.  It would just be the mark since 
the last clear at an unknown time.  Userspace can monitor the rss of a 
process by reading /proc/pid/stat, there's no need for the kernel to do 
something that userspace can do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
