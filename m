Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0B140900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 17:06:59 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id w7so1873031lbi.38
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 14:06:59 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id t13si20631657lal.121.2014.10.27.14.06.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 14:06:58 -0700 (PDT)
Date: Mon, 27 Oct 2014 22:06:56 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: isolate_freepages_block(): very high intermittent overhead
Message-ID: <20141027210656.GC348@x4>
References: <20141027204003.GB348@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027204003.GB348@x4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>

On 2014.10.27 at 21:40 +0100, Markus Trippelsdorf wrote:
> On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
> high (>20%) in perf top during the configuration phase of software
> builds. It increases build time considerably.
> 
> Unfortunately the issue is not 100% reproducible, because it appears
> only intermittently. And the symptoms vanish after a few minutes.
> 
> I think the "mm, compaction" series from Vlastimil is to blame, but it's
> hard to be sure when bisection doesn't work.

Here is an example:

Overhead  Shared Object      Symbol
59.12%    [kernel]           [k] isolate_freepages_block
4.75%     [kernel]           [k] amd_e400_idle
1.10%     [kernel]           [k] clear_page_c
0.89%     [kernel]           [k] get_pfnblock_flags_mask
0.64%     ld-2.19.90.so      [.] do_lookup_x
0.64%     [kernel]           [k] unmap_single_vma
0.58%     [kernel]           [k] copy_page_rep
0.54%     libc-2.19.90.so    [.] memcpy@@GLIBC_2.14
0.52%     [kernel]           [k] filemap_map_pages
0.47%     [kernel]           [k] _cond_resched

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
