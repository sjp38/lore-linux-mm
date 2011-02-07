Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7AB8A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 16:16:04 -0500 (EST)
Date: Mon, 7 Feb 2011 22:16:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: khugepaged eating 100%CPU
Message-ID: <20110207211601.GA25665@tiehlicka.suse.cz>
References: <20110207210517.GA24837@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110207210517.GA24837@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 07-02-11 22:06:54, Michal Hocko wrote:
> Hi Andrea,
> 
> I am currently running into an issue when khugepaged is running 100% on
> one of my CPUs for a long time (at least one hour as I am writing the
> email). The kernel is the clean 2.6.38-rc3 (i386) vanilla kernel.
> 
> I have tried to disable defrag but it didn't help (I haven't rebooted
> after setting the value). I am not sure what information is helpful and
> also not sure whether I am able to reproduce it after restart (it is the
> first time I can see this problem) so sorry for the poor report.
> 
> Here is some basic info which might be useful (config and sysrq+t are
> attached):
> =========

And I have just realized that I forgot about the daemon stack:
# cat /proc/573/stack 
[<c019c981>] shrink_zone+0x1b9/0x455
[<c019d462>] do_try_to_free_pages+0x9d/0x301
[<c019d803>] try_to_free_pages+0xb3/0x104
[<c01966d7>] __alloc_pages_nodemask+0x358/0x589
[<c01bf314>] khugepaged+0x13f/0xc60
[<c014c301>] kthread+0x67/0x6c
[<c0102db6>] kernel_thread_helper+0x6/0x10
[<ffffffff>] 0xffffffff
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
