Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED7436B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:05:01 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id tb5so24560751lbb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:05:01 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h201si2401083wme.86.2016.05.13.01.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 01:05:00 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so2085578wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:05:00 -0700 (PDT)
Date: Fri, 13 May 2016 10:04:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513080458.GF20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5731CC6E.3080807@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>

On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
[...]
> NOTE: I understand that the overcommit mode can be changed dynamically thru
> sysctl, but on embedded systems, where we know in advance that overcommit
> will be disabled, there's no reason to postpone such setting.

To be honest I am not particularly happy about yet another config
option. At least not without a strong reason (the one above doesn't
sound that way). The config space is really large already.
So why a later initialization matters at all? Early userspace shouldn't
consume too much address space to blow up later, no?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
