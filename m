Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D19EF6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:56:36 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id b13so5168934wgh.30
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:56:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p46si14877231eem.168.2013.12.10.07.56.36
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:56:36 -0800 (PST)
Date: Tue, 10 Dec 2013 15:56:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/17] NUMA balancing segmentation fault fixes and misc
 followups v4
Message-ID: <20131210155633.GL11295@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 10, 2013 at 03:51:18PM +0000, Mel Gorman wrote:
> Changelog since V3
> o Dropped a tracing patch
> o Rebased to 3.13-rc3
> o Removed unnecessary ptl acquisition
> 

*sigh*

There really are only 17 patches in the series. 18/18 does not exist.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
