Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DEE386B004D
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:06:21 -0500 (EST)
Date: Fri, 26 Feb 2010 09:05:48 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <alpine.DEB.2.00.1002260904311.6641@router.home>
Message-ID: <alpine.DEB.2.00.1002260905280.6641@router.home>
References: <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box>
 <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box>
 <alpine.DEB.2.00.1002260904311.6641@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


I mean why the core changes if this is an x86 issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
