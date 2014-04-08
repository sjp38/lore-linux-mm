Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 19E896B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 15:56:55 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j17so1621167oag.14
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:56:53 -0700 (PDT)
Received: from smtp.01.com (smtp.01.com. [199.36.142.181])
        by mx.google.com with ESMTP id pu6si2560229oeb.178.2014.04.08.12.56.53
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 12:56:53 -0700 (PDT)
Message-ID: <53445481.3030202@agliodbs.com>
Date: Tue, 08 Apr 2014 15:56:49 -0400
From: Josh Berkus <josh@agliodbs.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>	<5343A494.9070707@suse.cz>	<alpine.DEB.2.10.1404080914280.8782@nuc> <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com> <WM!55d2a092da9f6180473043487a4eb612ae8195f78d2ffdd83f673ed5cb2cb9659cf61e0c8d5bae23f5c914057bcd2ee4!@asav-3.01.com>
In-Reply-To: <WM!55d2a092da9f6180473043487a4eb612ae8195f78d2ffdd83f673ed5cb2cb9659cf61e0c8d5bae23f5c914057bcd2ee4!@asav-3.01.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Haas <robertmhaas@gmail.com>, Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On 04/08/2014 03:53 PM, Robert Haas wrote:
> In an ideal world, the kernel would put the hottest pages on the local
> node and the less-hot pages on remote nodes, moving pages around as
> the workload shifts.  In practice, that's probably pretty hard.
> Fortunately, it's not nearly as important as making sure we don't
> unnecessarily hit the disk, which is infinitely slower than any memory
> bank.

Even if the kernel could do this, we would *still* have to disable it
for PostgreSQL, since our double-buffering makes our pages look "cold"
to the kernel ... as discussed.

-- 
Josh Berkus
PostgreSQL Experts Inc.
http://pgexperts.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
