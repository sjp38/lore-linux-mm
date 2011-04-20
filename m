Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAF688D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 02:59:48 -0400 (EDT)
Date: Wed, 20 Apr 2011 08:59:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH followup] mm: get rid of CONFIG_STACK_GROWSUP ||
 CONFIG_IA64
Message-ID: <20110420065943.GA18799@tiehlicka.suse.cz>
References: <20110419091022.GA21689@tiehlicka.suse.cz>
 <20110419110956.GD21689@tiehlicka.suse.cz>
 <20110420093326.45EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420093326.45EF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Kosaki,

On Wed 20-04-11 09:33:26, KOSAKI Motohiro wrote:
> > While I am in the cleanup mode. We should use VM_GROWSUP rather than
> > tricky CONFIG_STACK_GROWSUP||CONFIG_IA64.
> > 
> > What do you think?
> 
> Now, VM_GROWSUP share the same value with VM_NOHUGEPAGE.
> (this trick use the fact that thp don't support any stack growup architecture)

I am not sure I understand you. AFAICS, VM_GROWSUP is defined to non 0
only if CONFIG_STACK_GROWSUP||CONFIG_IA64 (include/linux/mm.h).
And we use it to determine whether expand_stack_growsup[*] should be
defined (in include/linux/mm.h).

The patch basically unifies the way how we export expand_stack_growsup
function and how define it (in mm/mmap.c).

So either we should use CONFIG_STACK_GROWSUP||CONFIG_IA64 at both places
or we should use VM_GROWSUP trick. I am for the later one.

Am I missing something?

--- 
[*] the previous patch renamed expand_growsup to expand_stack_growsup.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
