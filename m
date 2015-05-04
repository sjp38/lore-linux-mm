Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 896076B006C
	for <linux-mm@kvack.org>; Mon,  4 May 2015 05:06:44 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so143454927wgy.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 02:06:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si10533737wix.19.2015.05.04.02.06.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 02:06:43 -0700 (PDT)
Date: Mon, 4 May 2015 10:06:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: VM_BUG on boot in set_pfnblock_flags_mask
Message-ID: <20150504090639.GA2462@suse.de>
References: <5546D9EB.4060602@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5546D9EB.4060602@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, May 03, 2015 at 10:31:07PM -0400, Sasha Levin wrote:
> Hi all,
> 
> I've decided to try and put more effort into testing on physical machines, but couldn't
> even get the box to boot :(
> 

Fix added to mmotm and should be in linux-next as
mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init-fix.patch

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
