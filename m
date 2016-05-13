Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9A346B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:01:31 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id f14so29272325lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:01:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v198si3849495wmv.34.2016.05.13.07.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:01:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so3907905wmn.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:01:29 -0700 (PDT)
Date: Fri, 13 May 2016 16:01:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513140128.GQ20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz>
 <5735AA0E.5060605@free.fr>
 <20160513114429.GJ20141@dhcp22.suse.cz>
 <5735C567.6030202@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735C567.6030202@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>
Cc: Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 14:15:35, Mason wrote:
> On 13/05/2016 13:44, Michal Hocko wrote:
> 
> > Anyway, this is my laptop where I do not run anything really special
> > (xfce, browser, few consoles, git, mutt):
> > $ grep Commit /proc/meminfo
> > CommitLimit:     3497288 kB
> > Committed_AS:    3560804 kB
> > 
> > I am running with the default overcommit setup so I do not care about
> > the limit but the Committed_AS will tell you how much is actually
> > committed. I am definitelly not out of memory:
> > $ free
> >               total        used        free      shared  buff/cache   available
> > Mem:        3922584     1724120      217336      105264     1981128     2036164
> > Swap:       1535996      386364     1149632
> 
> I see. Thanks for the data point.
> 
> I had a different type of system in mind.
> 256 to 512 MB of RAM, no swap.
> Perhaps Sebastian's choice could be made to depend on CONFIG_EMBEDDED,
> rather than CONFIG_EXPERT?

Even if the overcommit behavior is different on those systems the
primary question hasn't been answered yet. Why cannot this be done from
the userspace? In other words what wouldn't work properly?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
