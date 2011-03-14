Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AB5F58D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:30:29 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p2EHUROa015777
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:30:27 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by hpaq6.eem.corp.google.com with ESMTP id p2EHTjdm002213
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:30:26 -0700
Received: by qyk35 with SMTP id 35so1494468qyk.13
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:30:25 -0700 (PDT)
Date: Mon, 14 Mar 2011 10:30:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: swap: Unlock swapfile inode mutex before closing
 file on bad swapfiles
In-Reply-To: <20110314122746.GA32408@suse.de>
Message-ID: <alpine.LSU.2.00.1103141026480.2894@sister.anvils>
References: <20110314122746.GA32408@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Mar 2011, Mel Gorman wrote:

> This patch releases the mutex if its held before calling filep_close()
> so swapon fails as expected without deadlock when the swapfile is backed
> by NFS.  If accepted for 2.6.39, it should also be considered a -stable
> candidate for 2.6.38 and 2.6.37.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Hugh Dickins <hughd@google.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
