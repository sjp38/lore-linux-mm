Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79E498E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:30:44 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y4-v6so5012730wma.0
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:30:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 205-v6sor1583192wmc.18.2018.09.27.04.30.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 04:30:43 -0700 (PDT)
Date: Thu, 27 Sep 2018 14:30:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-mm@ archive on lore.kernel.org (Was: [PATCH 0/2] thp
 nodereclaim fixes)
Message-ID: <20180927113040.buzebfcooivxsu5d@kshutemo-mobl1>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180926130850.vk6y6zxppn7bkovk@kshutemo-mobl1>
 <20180926152523.GA8154@chatter>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926152523.GA8154@chatter>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 26, 2018 at 11:25:23AM -0400, Konstantin Ryabitsev wrote:
> On Wed, Sep 26, 2018 at 04:08:50PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 25, 2018 at 02:03:24PM +0200, Michal Hocko wrote:
> > > Thoughts, alternative patches?
> > > 
> > > [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
> > > [2] http://lkml.kernel.org/r/20180830064732.GA2656@dhcp22.suse.cz
> > > [3] http://lkml.kernel.org/r/20180820032640.9896-2-aarcange@redhat.com
> > 
> > All these links are broken. lore.kernel.org doesn't have linux-mm@ archive.
> > 
> > Can we get it added?
> 
> Adding linux-mm to lore.kernel.org certainly should happen, but it will not
> fix the above problem, because lkml.kernel.org/r/<foo> links only work for
> messages on LKML, not for all messages passing through vger lists (hence the
> word "lkml" in the name).

What is the reason for the separation? From my POV it's beneficial to have
single url scheme to refer any message in the archive regardless of the
list.

-- 
 Kirill A. Shutemov
