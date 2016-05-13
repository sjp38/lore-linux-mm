Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45D6C6B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:41:26 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so30721589lbc.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:41:26 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id c191si4242898wme.44.2016.05.13.08.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:41:24 -0700 (PDT)
Date: Fri, 13 May 2016 16:41:13 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513164113.6317c491@lxorguk.ukuu.org.uk>
In-Reply-To: <5735EE7A.4010600@laposte.net>
References: <5731CC6E.3080807@laposte.net>
	<20160513080458.GF20141@dhcp22.suse.cz>
	<573593EE.6010502@free.fr>
	<5735A3DE.9030100@laposte.net>
	<20160513120042.GK20141@dhcp22.suse.cz>
	<5735CAE5.5010104@laposte.net>
	<20160513145101.GS20141@dhcp22.suse.cz>
	<5735EE7A.4010600@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

> My understanding is that there was a time when there was no overcommit at all.
> If that's the case, understanding why overcommit was introduced would be helpful.

Linux always had overcommit.

The origin of overcommit is virtual memory for the most part. In a
classic swapping system without VM the meaning of brk() and thus malloc()
is that it allocates memory (or swap). Likewise this is true of fork()
and stack extension.

In a virtual memory system these allocate _address space_. It does not
become populated except by page faulting, copy on write and the like. It
turns out that for most use cases on a virtual memory system we get huge
amounts of page sharing or untouched space.

Historically Linux did guess based overcommit and I added no overcommit
support way back when, along with 'anything is allowed' support for
certain HPC use cases.

The beancounter patches combined with this made the entire setup
completely robust but the beancounters never hit upstream although years
later they became part of the basis of the cgroups.

You can sort of set a current Linux up for definitely no overcommit using
cgroups and no overcommit settings. It works for most stuff although last
I checked most graphics drivers were terminally broken (and not just to
no overcommit but to the point you can remote DoS Linux boxes with a
suitably constructed web page and chrome browser)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
