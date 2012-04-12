Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3850F6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 01:44:49 -0400 (EDT)
Date: Thu, 12 Apr 2012 06:44:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
Message-ID: <20120412054443.GK3789@suse.de>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.00.1204111651290.26528@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204111651290.26528@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 11, 2012 at 04:54:18PM -0700, Hugh Dickins wrote:
> On Wed, 11 Apr 2012, Mel Gorman wrote:
> > 
> > Removing lumpy reclaim saves almost 900K of text where as the full series
> > removes 1200K of text.
> 
> Impressive...
> 
> > 
> >    text	   data	    bss	    dec	    hex	filename
> > 6740375	1927944	2260992	10929311	 a6c49f	vmlinux-3.4.0-rc2-vanilla
> > 6739479	1927944	2260992	10928415	 a6c11f	vmlinux-3.4.0-rc2-lumpyremove-v2
> > 6739159	1927944	2260992	10928095	 a6bfdf	vmlinux-3.4.0-rc2-nosync-v2
> 
> ... but I fear you meant " bytes" instead of "K" ;)
> 

Whoops, I do :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
