Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 843A86B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 17:02:55 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so37399943pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 14:02:55 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id rf7si5848441pdb.172.2015.08.27.14.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 14:02:54 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so668707pac.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 14:02:53 -0700 (PDT)
Date: Thu, 27 Aug 2015 14:02:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, migrate: count pages failing all retries in vmstat
 and tracepoint
In-Reply-To: <1440685227-747-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1508271401040.30543@chino.kir.corp.google.com>
References: <1440685227-747-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 27 Aug 2015, Vlastimil Babka wrote:

> Migration tries up to 10 times to migrate pages that return -EAGAIN until it
> gives up. If some pages fail all retries, they are counted towards the number
> of failed pages that migrate_pages() returns. They should also be counted in
> the /proc/vmstat pgmigrate_fail and in the mm_migrate_pages tracepoint.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

I assume nothing else other than stats and tracepoints are affected by 
this and this isn't a critical bugfix :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
