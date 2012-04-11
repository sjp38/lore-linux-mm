Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B54CD6B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 19:54:39 -0400 (EDT)
Received: by iajr24 with SMTP id r24so2628941iaj.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 16:54:39 -0700 (PDT)
Date: Wed, 11 Apr 2012 16:54:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
In-Reply-To: <1334162298-18942-1-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.00.1204111651290.26528@eggly.anvils>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 11 Apr 2012, Mel Gorman wrote:
> 
> Removing lumpy reclaim saves almost 900K of text where as the full series
> removes 1200K of text.

Impressive...

> 
>    text	   data	    bss	    dec	    hex	filename
> 6740375	1927944	2260992	10929311	 a6c49f	vmlinux-3.4.0-rc2-vanilla
> 6739479	1927944	2260992	10928415	 a6c11f	vmlinux-3.4.0-rc2-lumpyremove-v2
> 6739159	1927944	2260992	10928095	 a6bfdf	vmlinux-3.4.0-rc2-nosync-v2

... but I fear you meant " bytes" instead of "K" ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
