Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D11E6B0261
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:26:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so11742965wme.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:26:39 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id yd10si7609595wjc.152.2016.05.13.08.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:26:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so4373856wmn.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:26:38 -0700 (PDT)
Date: Fri, 13 May 2016 17:26:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513152636.GV20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net>
 <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <20160513145101.GS20141@dhcp22.suse.cz>
 <5735EBBC.6050705@free.fr>
 <20160513161104.330ab3d6@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513161104.330ab3d6@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Mason <slash.tmp@free.fr>, Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 16:11:04, One Thousand Gnomes wrote:
> > It seems important to point out that Sebastian's patch does NOT change
> > the default behavior. It merely creates a knob allowing one to override
> > the default via Kconfig.
> > 
> > +choice
> > +	prompt "Overcommit Mode"
> > +	default OVERCOMMIT_GUESS
> > +	depends on EXPERT
> 
> Which is still completely pointless given that its a single sysctl value
> set at early userspace time and most distributions ship with things like
> sysctl and /etc/sysctl.conf
> 
> We have a million other such knobs, putting them in kconfig just gets
> silly.

Exactly my point from the very begining. Thanks for being so direct
here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
