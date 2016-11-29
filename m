Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C98E6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:25:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so45407967wma.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:25:18 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id sd16si60092847wjb.290.2016.11.29.08.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 08:25:16 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so25249813wme.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:25:16 -0800 (PST)
Date: Tue, 29 Nov 2016 17:25:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161129162515.GD9796@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <20161122163801.GA2919@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161122163801.GA2919@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Stable tree <stable@vger.kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Marc MERLIN <marc@merlins.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 22-11-16 17:38:01, Greg KH wrote:
> On Tue, Nov 22, 2016 at 05:14:02PM +0100, Vlastimil Babka wrote:
> > On 11/22/2016 05:06 PM, Marc MERLIN wrote:
> > > On Mon, Nov 21, 2016 at 01:56:39PM -0800, Marc MERLIN wrote:
> > >> On Mon, Nov 21, 2016 at 10:50:20PM +0100, Vlastimil Babka wrote:
> > >>>> 4.9rc5 however seems to be doing better, and is still running after 18
> > >>>> hours. However, I got a few page allocation failures as per below, but the
> > >>>> system seems to recover.
> > >>>> Vlastimil, do you want me to continue the copy on 4.9 (may take 3-5 days) 
> > >>>> or is that good enough, and i should go back to 4.8.8 with that patch applied?
> > >>>> https://marc.info/?l=linux-mm&m=147423605024993
> > >>>
> > >>> Hi, I think it's enough for 4.9 for now and I would appreciate trying
> > >>> 4.8 with that patch, yeah.
> > >>
> > >> So the good news is that it's been running for almost 5H and so far so good.
> > > 
> > > And the better news is that the copy is still going strong, 4.4TB and
> > > going. So 4.8.8 is fixed with that one single patch as far as I'm
> > > concerned.
> > > 
> > > So thanks for that, looks good to me to merge.
> > 
> > Thanks a lot for the testing. So what do we do now about 4.8? (4.7 is
> > already EOL AFAICS).
> > 
> > - send the patch [1] as 4.8-only stable. Greg won't like that, I expect.
> >   - alternatively a simpler (againm 4.8-only) patch that just outright
> > prevents OOM for 0 < order < costly, as Michal already suggested.
> > - backport 10+ compaction patches to 4.8 stable
> > - something else?
> 
> Just wait for 4.8-stable to go end-of-life in a few weeks after 4.9 is
> released?  :)

OK, so can we push this through to 4.8 before EOL and make sure there
won't be any additional pre-mature high order OOM reports? The patch
should be simple enough and safe for the stable tree. There is no
upstream commit because 4.9 is fixed in a different way which would be
way too intrusive for the stable backport.
--- 
