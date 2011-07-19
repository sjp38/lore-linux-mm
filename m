Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C88666B00E8
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 04:45:18 -0400 (EDT)
Received: by qyk4 with SMTP id 4so2798949qyk.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 01:45:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311059367.15392.299.camel@sli10-conroe>
References: <1311059367.15392.299.camel@sli10-conroe>
Date: Tue, 19 Jul 2011 17:45:16 +0900
Message-ID: <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> kswapd2 are keeping running and I can't access filesystem, but most memory is
> free. This looks like a regression since commit 08951e545918c159.

Could you tell me what is 08951e545918c159?
You mean [ebd64e21ec5a,
mm-vmscan-only-read-new_classzone_idx-from-pgdat-when-reclaiming-successfully]
?


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
