Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id ABEFD6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:59:08 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so418821eek.25
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 03:59:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si4043810eel.7.2013.12.19.03.59.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 03:59:07 -0800 (PST)
Date: Thu, 19 Dec 2013 11:59:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/18] mm: numa: Avoid unnecessary disruption of NUMA
 hinting during migration
Message-ID: <20131219115905.GI11295@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <1386690695-27380-11-git-send-email-mgorman@suse.de>
 <52B0D5F9.5030208@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52B0D5F9.5030208@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 05:53:45PM -0500, Sasha Levin wrote:
> Hi Mel,
> 
> On 12/10/2013 10:51 AM, Mel Gorman wrote:
> >+
> >+	/* mmap_sem prevents this happening but warn if that changes */
> >+	WARN_ON(pmd_trans_migrating(pmd));
> >+
> 
> I seem to be hitting this warning with latest -next kernel:
> 

Patch will follow shortly. I appreciate these trinity bug reports but in
the future is there any chance you could include the trinity command line
and the config file you used? Details on the machine would also be nice. In
this case, knowing if the machine was NUMA or not would have been helpful.

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
