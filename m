Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 153B09003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:20:32 -0400 (EDT)
Received: by iecri3 with SMTP id ri3so3068027iec.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:20:31 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id s83si5928789ioi.169.2015.07.23.13.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 13:20:31 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so1512134pdb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:20:31 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:20:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, page_isolation: make set/unset_migratetype_isolate()
 file-local
In-Reply-To: <1437630002-25936-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1507231320150.31024@chino.kir.corp.google.com>
References: <1437630002-25936-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 23 Jul 2015, Naoya Horiguchi wrote:

> Nowaday, set/unset_migratetype_isolate() is defined and used only in
> mm/page_isolation, so let's limit the scope within the file.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
