Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 34C2D6B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 14:29:34 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Improving OOM killer
Date: Wed, 3 Feb 2010 20:29:31 +0100
References: <201002012302.37380.l.lunak@suse.cz> <4B698CEE.5020806@redhat.com> <20100203170127.GH19641@balbir.in.ibm.com> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
In-reply-To: <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002032029.34145.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: balbir@linux.vnet.ibm.com, riel@redhat.com, l.lunak@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, npiggin@suse.de, jkosina@suse.cz
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> /*
> * /proc/pid/oom_adj ranges from -1000 to +1000 to either
> * completely disable oom killing or always prefer it.
> */
> points += p->signal->oom_adj;
> 

Wouldn't that cause a rather huge compatibility issue given that the 
current oom_adj works in a totally different way:

! 3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
! ------------------------------------------------------
! This file can be used to adjust the score used to select which processes
! should be killed in an  out-of-memory  situation.  Giving it a high score
! will increase the likelihood of this process being killed by the
! oom-killer.  Valid values are in the range -16 to +15, plus the special
! value -17, which disables oom-killing altogether for this process.

?

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
