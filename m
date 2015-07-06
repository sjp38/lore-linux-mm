Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 42BFB2802C2
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 13:45:59 -0400 (EDT)
Received: by labgy5 with SMTP id gy5so12284159lab.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 10:45:58 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id rn3si15838663lbb.5.2015.07.06.10.45.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 10:45:57 -0700 (PDT)
Date: Mon, 06 Jul 2015 18:45:50 +0100
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
	before basic setup
Message-Id: <1436204750.29787.3@cpanel21.proisp.no>
In-Reply-To: <20150624225028.GA97166@asylum.americas.sgi.com>
References: <20150624225028.GA97166@asylum.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

Hi Nate,

On Wed, Jun 24, 2015 at 11:50 PM, Nathan Zimmer <nzimmer@sgi.com> wrote:
> My apologies for taking so long to get back to this.
> 
> I think I did locate two potential sources of slowdown.
> One is the set_cpus_allowed_ptr as I have noted previously.
> However I only notice that on the very largest boxes.
> I did cobble together a patch that seems to help.
> 
> The other spot I suspect is the zone lock in free_one_page.
> I haven't been able to give that much thought as of yet though.
> 
> Daniel do you mind seeing if the attached patch helps out?

Just got back from travel, so apologies for the delays.

The patch doesn't mitigate the increasing initialisation time; summing 
the per-node times for an accurate measure, there was a total of 
171.48s before the patch and 175.23s after. I double-checked and got 
similar data.

Thanks,
  Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
