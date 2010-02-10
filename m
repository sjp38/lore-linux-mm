Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 332376B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 19:32:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1A0W804029343
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Feb 2010 09:32:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4281A45DE50
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 09:32:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 238C445DE4D
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 09:32:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0975B1DB8038
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 09:32:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF39DE08002
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 09:32:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
In-Reply-To: <4B71927D.6030607@nortel.com>
References: <4B71927D.6030607@nortel.com>
Message-Id: <20100210093140.12D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Feb 2010 09:32:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> I'm hoping you can help me out.  I'm on a 2.6.27 x86 system and I'm
> seeing the "inactive" field in /proc/meminfo slowly growing over time to
> the point where eventually the oom-killer kicks in and starts killing
> things.  The growth is not evident in any other field in /proc/meminfo.
> 
> I'm trying to figure out where the memory is going, and what it's being
> used for.
> 
> As I've found, the fields in /proc/meminfo don't add up...in particular,
> active+inactive is quite a bit larger than
> buffers+cached+dirty+anonpages+mapped+pagetables+vmallocused.  Initially
> the difference is about 156MB, but after about 13 hrs the difference is
> 240MB.
> 
> How can I track down where this is going?  Can you suggest any
> instrumentation that I can add?
> 
> I'm reasonably capable, but I'm getting seriously confused trying to
> sort out the memory subsystem.  Some pointers would be appreciated.

can you please post your /proc/meminfo?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
