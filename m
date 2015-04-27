Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 172CB6B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 19:01:28 -0400 (EDT)
Received: by wiun10 with SMTP id n10so8168345wiu.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:01:27 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id cg3si18978244wjb.89.2015.04.27.16.01.26
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 16:01:26 -0700 (PDT)
Date: Tue, 28 Apr 2015 02:01:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: compaction: BUG in isolate_migratepages_block()
Message-ID: <20150427230118.GA32541@node.dhcp.inet.fi>
References: <553EB993.7030401@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <553EB993.7030401@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 06:34:59PM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew:
> 
> [ 4249.344788] kernel BUG at include/linux/page-flags.h:575!

This should help: https://lkml.org/lkml/2015/4/27/218

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
