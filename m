Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D0B296B029F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 13:51:44 -0400 (EDT)
Received: by widic2 with SMTP id ic2so21466848wid.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 10:51:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mn10si15012213wjc.72.2015.07.16.10.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jul 2015 10:51:43 -0700 (PDT)
Date: Thu, 16 Jul 2015 18:51:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [mminit] [ INFO: possible recursive locking detected ]
Message-ID: <20150716175139.GB2561@suse.de>
References: <20150714000910.GA8160@wfg-t540p.sh.intel.com>
 <20150714103108.GA6812@suse.de>
 <CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, nicstange@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>

On Thu, Jul 16, 2015 at 08:13:38PM +0300, Konstantin Khlebnikov wrote:
> > @@ -1187,14 +1195,14 @@ void __init page_alloc_init_late(void)
> >  {pgdat_init_rwsempgdat_init_rwsempgdat_init_rwsem
> >         int nid;
> >
> > +       /* There will be num_node_state(N_MEMORY) threads */
> > +       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
> >         for_each_node_state(nid, N_MEMORY) {
> > -               down_read(&pgdat_init_rwsem);
> 
> Rw-sem have special "non-owner" mode for keeping lockdep away.
> This should be enough:
> 

I think in this case that the completions look nicer though so I think
I'll keep them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
