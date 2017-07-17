Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60F3E6B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:56:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m81so1463973wmh.6
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:56:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k63si4469293wmf.26.2017.07.17.08.56.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 08:56:18 -0700 (PDT)
Date: Mon, 17 Jul 2017 16:56:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170717155616.jpyi7xdl33mcafyf@suse.de>
References: <cover.1498751203.git.luto@kernel.org>
 <20170705085657.eghd4xbv7g7shf5v@gmail.com>
 <20170717095715.yzmuhhp6txqsxtpf@suse.de>
 <20170717150625.2depy7bqkx7qt7zv@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170717150625.2depy7bqkx7qt7zv@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Jul 17, 2017 at 05:06:25PM +0200, Ingo Molnar wrote:
> > > I'll push it all out when it passes testing.
> > > 
> > > If it's all super stable I plan to tempt Linus with a late merge window pull 
> > > request for all these preparatory patches. (Unless he objects that is. Hint, hint.)
> > > 
> > > Any objections?
> > > 
> > 
> > What was the final verdict here? I have a patch ready that should be layered
> > on top which will need a backport. PCID support does not appear to have
> > made it in this merge window so I'm wondering if I should send the patch
> > as-is for placement on top of Andy's work or go with the backport and
> > apply a follow-on patch after Andy's work gets merged.
> 
> It's en route for v4.14 - it narrowly missed v4.13.
> 

Grand. I sent out a version that doesn't depend on Andy's work to Andrew
as it's purely a mm patch. If that passes inspection then I'll send a
follow-on patch to apply on top of the PCID work.

Thanks Ingo.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
