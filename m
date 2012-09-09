Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C9C2D6B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 16:34:17 -0400 (EDT)
Date: Sun, 9 Sep 2012 22:34:11 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with swappiness==0
Message-ID: <20120909203411.GC13847@1wt.eu>
References: <5038E7AA.5030107@gmail.com> <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk> <504CCECF.9020104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <504CCECF.9020104@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ben Hutchings <ben@decadent.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Zdenek Kaspar <zkaspar82@gmail.com>, linux-mm@kvack.org

On Sun, Sep 09, 2012 at 01:15:59PM -0400, Rik van Riel wrote:
> >>http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=fe35004fbf9eaf67482b074a2e032abb9c89b1dd
> >>
> >>In short: this patch seems beneficial for users trying to avoid memory
> >>swapping at all costs but they want to keep swap for emergency reasons.
> >>
> >>More details: https://lkml.org/lkml/2012/3/2/320
> >>
> >>Its included in 3.5, so could this be considered for -longterm kernels ?
> >
> >Andrew, Rik, does this seem appropriate for longterm?
> 
> Yes, absolutely.  Default behaviour is not changed at all, and
> the patch makes swappiness=0 do what people seem to expect it
> to do.

Just for the record, in 3.0 and below we don't have vmscan_swappiness(),
so if the match makes sense there, that function will need to be backported,
in which mem_cgroup_swappiness() will have to be replaced by get_swappiness().

Regards,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
