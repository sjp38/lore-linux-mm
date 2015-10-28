Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DD96482F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:55:33 -0400 (EDT)
Received: by pasz6 with SMTP id z6so21014990pas.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:55:33 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id y12si73860233pbt.182.2015.10.28.16.55.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 16:55:33 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so21019683pad.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:55:32 -0700 (PDT)
Date: Wed, 28 Oct 2015 16:55:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
In-Reply-To: <20151027175140.GC14722@redhat.com>
Message-ID: <alpine.DEB.2.10.1510281655010.15960@chino.kir.corp.google.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com> <20151026172012.GC9779@dhcp22.suse.cz> <20151026174048.GP15046@redhat.com> <20151027080920.GA9891@dhcp22.suse.cz> <20151027154341.GA14722@redhat.com> <20151027162047.GK9891@dhcp22.suse.cz>
 <20151027175140.GC14722@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <arozansk@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 27 Oct 2015, Aristeu Rozanski wrote:

> Hi Michal,
> On Tue, Oct 27, 2015 at 05:20:47PM +0100, Michal Hocko wrote:
> > Yes this is a mess. But I think it is worth cleaning up.
> > dump_stack_print_info (arch independent) has a log level parameter.
> > show_stack_log_lvl (x86) has a loglevel parameter which is unused.
> > 
> > I haven't checked other architectures but the transition doesn't have to
> > be all at once I guess.
> 
> Ok, will keep working on it then.
> 

No objection on changing the loglevel of the stack trace from the oom 
killer and the bonus is that we can avoid yet another tunable, yay!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
