Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 937C36B02F3
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 15:59:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w91so1514184wrb.13
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 12:59:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w22si26465465wrb.325.2017.06.02.12.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 12:59:47 -0700 (PDT)
Date: Fri, 2 Jun 2017 12:59:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-Id: <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
In-Reply-To: <20170602071818.GA29840@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170601115936.GA9091@dhcp22.suse.cz>
	<201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
	<20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Fri, 2 Jun 2017 09:18:18 +0200 Michal Hocko <mhocko@suse.com> wrote:

> On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > 
> > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > > >
> > > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > > on the vanilla up-to-date kernel?
> > > > 
> > > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > > enterprise distributions would choose for their next long term supported
> > > > version.
> > > > 
> > > > And please stop saying "can you reproduce your problem with latest
> > > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > > up-to-date kernel!
> > > 
> > > The changelog mentioned that the source of stalls is not clear so this
> > > might be out-of-tree patches doing something wrong and dump_stack
> > > showing up just because it is called often. This wouldn't be the first
> > > time I have seen something like that. I am not really keen on adding
> > > heavy lifting for something that is not clearly debugged and based on
> > > hand waving and speculations.
> > 
> > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > output from concurrent calls getting all jumbled together?
> 
> dump_stack already serializes concurrent calls.

Sure.  But warn_alloc() doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
