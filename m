Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C3CDA9000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 22:24:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F3E053EE0C1
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:24:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D53FE45DE6A
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:24:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC25045DE81
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:24:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6FB91DB8041
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:24:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D43C1DB803A
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:24:27 +0900 (JST)
Date: Mon, 26 Sep 2011 11:23:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Proposed memcg meeting at October Kernel Summit/European
 LinuxCon in Prague
Message-Id: <20110926112337.f713ad8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1316693805.10571.25.camel@dabdike>
References: <1316693805.10571.25.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <jbottomley@parallels.com>
Cc: Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 22 Sep 2011 12:16:47 +0000
James Bottomley <jbottomley@parallels.com> wrote:

> Hi All,
> 
> One of the major work items that came out of the Plumbers conference
> containers and Cgroups meeting was the need to work on memcg:
> 
> http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/tracks/105
> 
> (see etherpad and presentations)
> 
> Since almost everyone will be either at KS or LinuxCon, I thought doing
> a small meeting on the Wednesday of Linux Con (so those at KS who might
> not be staying for the whole of LinuxCon could attend) might be a good
> idea.  The object would be to get all the major players to agree on
> who's doing what.  You can see Parallels' direction from the patches
> Glauber has been posting.  Google should shortly be starting work on
> other aspects of the memgc as well.
> 
> As a precursor to the meeting (and actually a requirement to make it
> effective) we need to start posting our preliminary patches and design
> ideas to the mm list (hint, Google people, this means you).
> 
I'd like to see.

But if it's for performance improvement, please show performance numbers.


> I think I've got all of the interested parties in the To: field, but I'm
> sending this to the mm list just in case I missed anyone.  If everyone's
> OK with the idea (and enough people are going to be there) I'll get the
> Linux Foundation to find us a room.
> 

Thank you. I'll attend.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
