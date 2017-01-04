Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0C716B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 03:06:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l2so56354287wml.5
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 00:06:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ix4si901808wjb.79.2017.01.04.00.06.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 00:06:43 -0800 (PST)
Date: Wed, 4 Jan 2017 09:06:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [KERNEL] Re: Bug 4.9 and memorymanagement
Message-ID: <20170104080639.GB25453@dhcp22.suse.cz>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
 <20161230111135.GG13301@dhcp22.suse.cz>
 <20161230165230.th274as75pzjlzkk@ikki.ethgen.ch>
 <20161230172358.GA4266@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230172358.GA4266@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 30-12-16 18:23:58, Michal Hocko wrote:
> On Fri 30-12-16 17:52:30, Klaus Ethgen wrote:
> > Sorry, did reply only you..
> > 
> > Am Fr den 30. Dez 2016 um 12:11 schrieb Michal Hocko:
> > > > If this turns out to be memory cgroup related then the patch from
> > > > http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz might
> > > > help.
> > >
> > > Did you get chance to test the above patch? I would like to send it for
> > > merging and having it tested on another system would be really helpeful
> > > and much appreciated.
> > 
> > Sorry, no, I was a bit busy when coming back from X-mass. ;-)
> > 
> > Maybe I can do so today.
> > 
> > The only think is, how can I find out if the bug is fixed? Is 7 days
> > enough? Or is there a change to force the bug to happen (or not)...?
> 
> Just try to run with the patch and do what you do normally. If you do
> not see any OOMs in few days it should be sufficient evidence. From your
> previous logs it seems you hit the problem quite early after few hours
> as far as I remember.

Did you have chance to run with the patch? I would like to post it for
inclusion and feedback from you is really useful.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
