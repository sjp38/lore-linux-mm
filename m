Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6124A6B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 05:52:33 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id f14so25852365lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 02:52:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id mw4si21355593wjb.85.2016.05.13.02.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 02:52:31 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so2609264wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 02:52:31 -0700 (PDT)
Date: Fri, 13 May 2016 11:52:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513095230.GI20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573593EE.6010502@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>
Cc: Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 10:44:30, Mason wrote:
> On 13/05/2016 10:04, Michal Hocko wrote:
> 
> > On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
> > [...]
> >> NOTE: I understand that the overcommit mode can be changed dynamically thru
> >> sysctl, but on embedded systems, where we know in advance that overcommit
> >> will be disabled, there's no reason to postpone such setting.
> > 
> > To be honest I am not particularly happy about yet another config
> > option. At least not without a strong reason (the one above doesn't
> > sound that way). The config space is really large already.
> > So why a later initialization matters at all? Early userspace shouldn't
> > consume too much address space to blow up later, no?
> 
> One thing I'm not quite clear on is: why was the default set
> to over-commit on?

Because many applications simply rely on large and sparsely used address
space, I guess. That's why the default is GUESS where we ignore the
cumulative charges and simply check the current state and blow up only
when the current request is way too large.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
