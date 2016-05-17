Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3406B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 04:57:28 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so5228150lbc.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 01:57:28 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id z191si2846886wme.56.2016.05.17.01.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 01:57:27 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id n129so130806162wmn.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 01:57:27 -0700 (PDT)
Date: Tue, 17 May 2016 10:57:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160517085724.GD14453@dhcp22.suse.cz>
References: <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz>
 <5735AA0E.5060605@free.fr>
 <20160513114429.GJ20141@dhcp22.suse.cz>
 <5735C567.6030202@free.fr>
 <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
 <5735F4B1.1010704@laposte.net>
 <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
 <573AD534.6050703@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573AD534.6050703@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 17-05-16 10:24:20, Sebastian Frias wrote:
[...]
> >> Also, under what conditions would copy-on-write fail?
> > 
> > When you have no memory or swap pages free and you touch a COW page that
> > is currently shared. At that point there is no resource to back to the
> > copy so something must die - either the process doing the copy or
> > something else.
> 
> Exactly, and why does "killing something else" makes more sense (or
> was chosen over) "killing the process doing the copy"?

Because that "something else" is usually a memory hog and so chances are
that the out of memory situation will get resolved. If you kill "process
doing the copy" then you might end up just not getting any memory back
because that might be a little forked process which doesn't own all that
much memory on its own. That would leave you in the oom situation for a
long time until somebody actually sitting on some memory happens to ask
for CoW... See the difference?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
