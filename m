Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id D67C86B00E6
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:17:04 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so1827244eaj.26
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:17:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p9si11259659eew.118.2013.12.09.13.17.04
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 13:17:04 -0800 (PST)
Date: Mon, 9 Dec 2013 22:16:57 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: kernel BUG in munlock_vma_pages_range
In-Reply-To: <52A5F83F.4000207@oracle.com>
Message-ID: <alpine.LRH.2.00.1312092215340.1515@twin.jikos.cz>
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 9 Dec 2013, Sasha Levin wrote:

> Not really, the fuzzer hit it once and I've been unable to trigger it 
> again. 

If you are ever able to trigger it again, I think having crashdump 
available would be very helpful here, to see how exactly does the VMA/THP 
layout look like at the time of crash.

Any chance you run your fuzzing with crashkernel configured for a while?

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
