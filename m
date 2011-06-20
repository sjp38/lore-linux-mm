Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BAD4B6B0122
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:59:56 -0400 (EDT)
Date: Mon, 20 Jun 2011 13:59:52 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110620175952.GD4749@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <20110620165844.GA9396@suse.de>
 <4DFF7E3B.1040404@redhat.com>
 <4DFF7F0A.8090604@redhat.com>
 <4DFF8106.8090702@redhat.com>
 <4DFF8327.1090203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFF8327.1090203@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, Jun 20, 2011 at 01:28:07PM -0400, Rik van Riel wrote:

[..]
> I'm not convinced that a 10kB memory reduction is
> worth the price of never being able to enable
> transparent hugepages when a system is booted with
> THP disabled...

Agreed.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
