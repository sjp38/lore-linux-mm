Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E1B896B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:44:37 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so1902107qcy.0
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:44:37 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id r70si12189313qga.92.2014.04.18.09.44.36
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 09:44:37 -0700 (PDT)
Date: Fri, 18 Apr 2014 11:44:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
In-Reply-To: <20140418154918.GD4523@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1404181143390.9558@gentwo.org>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <20140418154918.GD4523@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 18 Apr 2014, Michal Hocko wrote:

> Auto-enabling caused so many reports in the past that it is definitely
> much better to not be clever and let admins enable zone_reclaim where it
> is appropriate instead.
>
> For both patches.
> Acked-by: Michal Hocko <mhocko@suse.cz>

I did not get any objections from SGI either.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
