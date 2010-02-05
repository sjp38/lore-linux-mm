Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 25C486B0047
	for <linux-mm@kvack.org>; Sun,  7 Feb 2010 17:58:04 -0500 (EST)
From: Oliver Neukum <oliver@neukum.org>
Subject: Re: Improving OOM killer
Date: Fri, 5 Feb 2010 08:35:30 +0100
References: <201002012302.37380.l.lunak@suse.cz> <alpine.LNX.2.00.1002041044080.15395@pobox.suse.cz> <alpine.DEB.2.00.1002041335140.6071@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002041335140.6071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002050835.30550.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 4. Februar 2010 22:39:08 schrieb David Rientjes:
> > If we really want kernel to detect forkbombs (*), we'd have to establish 
> > completely separate infrastructure for that (with its own knobs for tuning 
> > and possibilities of disabling it completely).
> > 
> 
> That's what we're trying to do, we can look at the shear number of 
> children that the parent has forked and check for it to be over a certain 
> "forkbombing threshold" (which, yes, can be tuned from userspace), the 
> uptime of those children, their resident set size, etc., to attempt to 
> find a sane heuristic that penalizes them.

Wouldn't it be saner to have a selection by user, so that users that
are over the overcommit limit are targeted?

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
