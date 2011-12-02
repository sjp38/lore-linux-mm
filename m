Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A39A6B004D
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 09:44:27 -0500 (EST)
Date: Fri, 2 Dec 2011 08:44:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: remove unnecessary statistics,
 deactivate_to_head/tail
In-Reply-To: <1322814189-17318-2-git-send-email-alex.shi@intel.com>
Message-ID: <alpine.DEB.2.00.1112020844070.10975@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <1322814189-17318-2-git-send-email-alex.shi@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011, Alex Shi wrote:

> Since the head or tail were automaticly decided in add_partial(),
> we didn't need this statistics again.

You need to update tools/slub/slabinfo.c as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
