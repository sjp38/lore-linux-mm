Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADED18D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 03:08:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3A2823EE0AE
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:08:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FFEE45DE95
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:08:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 08F0D45DE88
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:08:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0991E38002
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:08:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE063E08003
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:08:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH followup] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
In-Reply-To: <20110420065943.GA18799@tiehlicka.suse.cz>
References: <20110420093326.45EF.A69D9226@jp.fujitsu.com> <20110420065943.GA18799@tiehlicka.suse.cz>
Message-Id: <20110420160946.4629.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 16:08:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

> Hi Kosaki,
> 
> On Wed 20-04-11 09:33:26, KOSAKI Motohiro wrote:
> > > While I am in the cleanup mode. We should use VM_GROWSUP rather than
> > > tricky CONFIG_STACK_GROWSUP||CONFIG_IA64.
> > > 
> > > What do you think?
> > 
> > Now, VM_GROWSUP share the same value with VM_NOHUGEPAGE.
> > (this trick use the fact that thp don't support any stack growup architecture)
> 
> I am not sure I understand you. AFAICS, VM_GROWSUP is defined to non 0
> only if CONFIG_STACK_GROWSUP||CONFIG_IA64 (include/linux/mm.h).
> And we use it to determine whether expand_stack_growsup[*] should be
> defined (in include/linux/mm.h).
> 
> The patch basically unifies the way how we export expand_stack_growsup
> function and how define it (in mm/mmap.c).
> 
> So either we should use CONFIG_STACK_GROWSUP||CONFIG_IA64 at both places
> or we should use VM_GROWSUP trick. I am for the later one.
> 
> Am I missing something?
> 
> --- 
> [*] the previous patch renamed expand_growsup to expand_stack_growsup.

Right you are. sorry.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
