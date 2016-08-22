Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2ED6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 07:20:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so59425087wme.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:20:39 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id k10si15814321wmh.11.2016.08.22.04.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 04:20:38 -0700 (PDT)
Date: Mon, 22 Aug 2016 13:20:36 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822112036.GA305@x4>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822101614.GA314@x4>
 <20160822105653.GI13596@dhcp22.suse.cz>
 <20160822110113.GB314@x4>
 <20160822111344.GJ13596@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822111344.GJ13596@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2016.08.22 at 13:13 +0200, Michal Hocko wrote:
> On Mon 22-08-16 13:01:13, Markus Trippelsdorf wrote:
> > On 2016.08.22 at 12:56 +0200, Michal Hocko wrote:
> > > On Mon 22-08-16 12:16:14, Markus Trippelsdorf wrote:
> > > > On 2016.08.22 at 11:32 +0200, Michal Hocko wrote:
> > > > > [1] http://lkml.kernel.org/r/20160731051121.GB307@x4
> > > > 
> > > > For the report [1] above:
> > > > 
> > > > markus@x4 linux % cat .config | grep CONFIG_COMPACTION
> > > > # CONFIG_COMPACTION is not set
> > > 
> > > Hmm, without compaction and a heavy fragmentation then I am afraid we
> > > cannot really do much. What is the reason to disable compaction in the
> > > first place?
> > 
> > I don't recall. Must have been some issue in the past. I will re-enable
> > the option.
> 
> Well, without the compaction there is no source of high order pages at
> all. You can only reclaim and hope that some of the reclaimed pages will
> find its buddy on the list and form the higher order page. This can take
> for ever. We used to have the lumpy reclaim and that could help but this
> is long gone.
> 
> I do not think we can really sanely optimize for high-order heavy loads
> without COMPACTION sanely. At least not without reintroducing lumpy
> reclaim or something similar. To be honest I am even not sure which
> configurations should disable compaction - except for really highly
> controlled !mmu or other one purpose systems.

I now recall. It was an issue with CONFIG_TRANSPARENT_HUGEPAGE, so I
disabled that option. This then de-selected CONFIG_COMPACTION...

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
