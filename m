Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D30B6B0038
	for <linux-mm@kvack.org>; Sat, 16 Sep 2017 05:34:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 187so5188610wmn.2
        for <linux-mm@kvack.org>; Sat, 16 Sep 2017 02:34:15 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id k10si2935964edi.383.2017.09.16.02.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Sep 2017 02:34:14 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id A4C521C26B5
	for <linux-mm@kvack.org>; Sat, 16 Sep 2017 10:34:13 +0100 (IST)
Date: Sat, 16 Sep 2017 10:34:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: meminit: mark init_reserved_page as __meminit
Message-ID: <20170916093412.xdqb7wne4s5xufeq@techsingularity.net>
References: <20170915193149.901180-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170915193149.901180-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 15, 2017 at 09:31:30PM +0200, Arnd Bergmann wrote:
> The function is called from __meminit context and calls other
> __meminit functions but isn't it self mark as such today:
> 
> WARNING: vmlinux.o(.text.unlikely+0x4516): Section mismatch in reference from the function init_reserved_page() to the function .meminit.text:early_pfn_to_nid()
> The function init_reserved_page() references
> the function __meminit early_pfn_to_nid().
> This is often because init_reserved_page lacks a __meminit
> annotation or the annotation of early_pfn_to_nid is wrong.
> 
> On most compilers, we don't notice this because the function
> gets inlined all the time. Adding __meminit here fixes the
> harmless warning for the old versions and is generally the
> correct annotation.
> 
> Fixes: 7e18adb4f80b ("mm: meminit: initialise remaining struct pages in parallel with kswapd")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
