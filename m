Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE0E06B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:15:57 -0500 (EST)
Date: Mon, 21 Nov 2011 11:15:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 3/3] slub: min order when debug_guardpage_minorder >
 0
In-Reply-To: <1321633507-13614-3-git-send-email-sgruszka@redhat.com>
Message-ID: <alpine.DEB.2.00.1111211115380.4771@router.home>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com> <1321633507-13614-3-git-send-email-sgruszka@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 18 Nov 2011, Stanislaw Gruszka wrote:

> Disable slub debug facilities and allocate slabs at minimal order when
> debug_guardpage_minorder > 0 to increase probability to catch random
> memory corruption by cpu exception.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
