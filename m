Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B0226B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:02:32 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so1640936fga.8
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 06:02:26 -0700 (PDT)
Date: Wed, 28 Oct 2009 14:02:23 +0100
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/3] Reduce GFP_ATOMIC allocation failures, partial fix
	V3
Message-ID: <20091028130223.GB14476@bizet.domek.prywatny>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 01:40:30PM +0000, Mel Gorman wrote:
> The following bug becomes very difficult to reproduce with these patches;
> 
> [Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100

Minor clarification -- bug becomes difficult to reproduce _quickly_.

I've always saw this bug after many suspend-resume cycles (interlaved
with "real work").  Since testing one kernel in normal usage scenario
would take many days I've tried to immitate "real work" by lots of
memory intensive/fragmenting processes.

Hovewer, this bug shows itself (sooner or later) in every kernel
except 2.6.30 (or earlier).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
