Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 87BCD6B00EC
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 04:53:07 -0400 (EDT)
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
References: <1311059367.15392.299.camel@sli10-conroe>
	 <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jul 2011 16:53:04 +0800
Message-ID: <1311065584.15392.300.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, 2011-07-19 at 16:45 +0800, Minchan Kim wrote:
> On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> > kswapd2 are keeping running and I can't access filesystem, but most memory is
> > free. This looks like a regression since commit 08951e545918c159.
> 
> Could you tell me what is 08951e545918c159?
> You mean [ebd64e21ec5a,
> mm-vmscan-only-read-new_classzone_idx-from-pgdat-when-reclaiming-successfully]
> ?
ha, sorry, I should copy the commit title.
08951e545918c159(mm: vmscan: correct check for kswapd sleeping in
sleeping_prematurely)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
