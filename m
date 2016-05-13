Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF006B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:44:09 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so30747608lbc.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:44:09 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id a196si4225185wma.76.2016.05.13.08.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:44:07 -0700 (PDT)
Date: Fri, 13 May 2016 16:43:57 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
In-Reply-To: <5735F4B1.1010704@laposte.net>
References: <5731CC6E.3080807@laposte.net>
	<20160513080458.GF20141@dhcp22.suse.cz>
	<573593EE.6010502@free.fr>
	<20160513095230.GI20141@dhcp22.suse.cz>
	<5735AA0E.5060605@free.fr>
	<20160513114429.GJ20141@dhcp22.suse.cz>
	<5735C567.6030202@free.fr>
	<20160513140128.GQ20141@dhcp22.suse.cz>
	<20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
	<5735F4B1.1010704@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

> But wouldn't those affect a given process at at time?
> Does that means that the OOM-killer is woken up to kill process X when those situations arise on process Y?

Not sure I understand the question.

> Also, under what conditions would copy-on-write fail?

When you have no memory or swap pages free and you touch a COW page that
is currently shared. At that point there is no resource to back to the
copy so something must die - either the process doing the copy or
something else.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
