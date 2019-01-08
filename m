Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2998F8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:08:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so2777566pfa.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:08:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17sor42675505pga.2.2019.01.08.06.08.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 06:08:49 -0800 (PST)
Date: Tue, 8 Jan 2019 17:08:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190108140844.tgabxo325enuvu6y@kshutemo-mobl1>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz>
 <nycvar.YFH.7.76.1901052016250.16954@cbobk.fhfr.pm>
 <fb0414ea-953b-0252-b1d1-12028b190949@suse.cz>
 <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
 <nycvar.YFH.7.76.1901081235380.16954@cbobk.fhfr.pm>
 <8c9feac8-fecb-a56a-afaf-c1352a666991@petrovitsch.priv.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c9feac8-fecb-a56a-afaf-c1352a666991@petrovitsch.priv.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Jiri Kosina <jikos@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Jan 08, 2019 at 02:53:00PM +0100, Bernd Petrovitsch wrote:
> On 08/01/2019 12:37, Jiri Kosina wrote:
> > On Tue, 8 Jan 2019, Bernd Petrovitsch wrote:
> > 
> >> Shouldn't the application use e.g. mlock()/.... to guarantee no page 
> >> faults in the first place?
> > 
> > Calling mincore() on pages you've just mlock()ed is sort of pointless 
> > though.
> 
> Obviously;-)
> 
> Sorry for being unclear above: If I want my application to
> avoid suffering from page faults, I use simply mlock()
> (and/or friends) to nail the relevant pages into physical
> RAM and not "look if they are out, if yes, get them in" which
> has also the risk that these important pages are too soon
> evicted again.

Note, that mlock() doesn't prevent minor page faults. Mlocked memory is
still subject to mechanisms that makes the page temporary unmapped. For
instance migration (including NUMA balancing), compaction, khugepaged...

-- 
 Kirill A. Shutemov
