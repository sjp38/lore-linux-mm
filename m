Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA7D06B005A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 22:42:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5O2hNig019961
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Jun 2009 11:43:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 125BE45DE55
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 11:43:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E59D045DE52
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 11:43:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D5D1DB8038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 11:43:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 799141DB8043
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 11:43:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
In-Reply-To: <20090624023251.GA16483@localhost>
References: <7561.1245768237@redhat.com> <20090624023251.GA16483@localhost>
Message-Id: <20090624114055.225D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Jun 2009 11:43:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 23, 2009 at 10:43:57PM +0800, David Howells wrote:
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > David, could you try running this when it occurred again?
> > > 
> > >         make Documentation/vm/page-types
> > >         Documentation/vm/page-types --raw  # run as root
> > 
> > Okay.  I managed to catch it between the first and second OOMs, and ran the
> > command you asked for.
> 
> Thank you!
> 
> > 0x0000000000000000	    142261      555  ________________________________	
> > 0x0000000000000400	      6797       26  __________B_____________________	buddy
> 
> The buddy+free numbers are pretty high. 26MB PG_buddy pages means much
> more actual free pages. So I bet the 555MB no-flag pages are mostly free pages.

You mean our VM can make OOM although it have 600MB free pages?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
