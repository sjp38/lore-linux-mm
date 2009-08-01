Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78B986B004D
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 01:13:01 -0400 (EDT)
Message-ID: <4A73CF12.4040902@nortel.com>
Date: Fri, 31 Jul 2009 23:13:54 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Dirty page tracking & on-the-fly memory mirroring
References: <4A738FFD.8020705@redhat.com>
In-Reply-To: <4A738FFD.8020705@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jim Paradis <jparadis@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jim Paradis wrote:
> Following are two patches against 2.6.31-rc3 which implement dirty page 
> tracking and on-the-fly memory mirroring.  The idea is to be able to 
> copy the entire physical memory over to another processor node or memory 
> module while the system is running.  Stratus makes use of this 
> functionality to bring a new partner node online.

We've been using something like this to mirror specific applications.
Our API is a bit different, it's per-process and lets the app specify
memory regions to monitor.  Another task sharing the memory map can
query the system for the addresses of pages that have been dirtied since
it last asked.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
