Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 991336B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:04:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so39960088lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:04:22 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id jd1si22544235wjb.248.2016.05.13.08.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:04:21 -0700 (PDT)
Date: Fri, 13 May 2016 16:04:10 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
In-Reply-To: <20160513140128.GQ20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
	<20160513080458.GF20141@dhcp22.suse.cz>
	<573593EE.6010502@free.fr>
	<20160513095230.GI20141@dhcp22.suse.cz>
	<5735AA0E.5060605@free.fr>
	<20160513114429.GJ20141@dhcp22.suse.cz>
	<5735C567.6030202@free.fr>
	<20160513140128.GQ20141@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

> > Perhaps Sebastian's choice could be made to depend on CONFIG_EMBEDDED,
> > rather than CONFIG_EXPERT?  
> 
> Even if the overcommit behavior is different on those systems the
> primary question hasn't been answered yet. Why cannot this be done from
> the userspace? In other words what wouldn't work properly?

Most allocations in C have no mechanism to report failure.

Stakc expansion failure is not reportable. Copy on write failure is not
reportable and so on.

Alan
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
