Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 30C356B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 04:39:44 -0400 (EDT)
Received: by mail-lf0-f43.google.com with SMTP id p188so131390985lfd.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 01:39:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si12215989wmg.24.2016.04.04.01.39.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 01:39:42 -0700 (PDT)
Date: Mon, 4 Apr 2016 09:39:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: Fix memory corruption caused by deferred page
 initialization
Message-ID: <20160404083939.GC21128@suse.de>
References: <1458921929-15264-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <3qXFh60DRNz9sDH@ozlabs.org>
 <20160326133708.GA382@gwshan>
 <20160327134827.GA24644@gwshan>
 <20160331022734.GA12552@gwshan>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160331022734.GA12552@gwshan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, zhlcindy@linux.vnet.ibm.com

On Thu, Mar 31, 2016 at 01:27:34PM +1100, Gavin Shan wrote:
> >So the issue is only existing when CONFIG_NO_BOOTMEM=n. The alternative fix would
> >be similar to what we have on !CONFIG_NO_BOOTMEM: In early stage, all page structs
> >for bootmem reserved pages are initialized and mark them with PG_reserved. I'm
> >not sure it's worthy to fix it as we won't support bootmem as Michael mentioned.
> >
> 
> Mel, could you please confirm if we need a fix on !CONFIG_NO_BOOTMEM? If we need,
> I'll respin and send a patch for review.
> 

Given that CONFIG_NO_BOOTMEM is not supported and bootmem is meant to be
slowly retiring, I would suggest instead making deferred memory init
depend on NO_BOOTMEM. 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
