Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A3EEF6B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 05:09:24 -0400 (EDT)
Date: Sun, 12 Jun 2011 11:09:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
Message-ID: <20110612090917.GA19493@tiehlicka.suse.cz>
References: <20110609212956.GA2319@redhat.com>
 <20110611081937.GB7042@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1106110839270.29336@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106110839270.29336@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>

On Sat 11-06-11 08:46:54, Hugh Dickins wrote:
> The discussion in https://lkml.org/lkml/2011/6/9/538
> has continued in https://lkml.org/lkml/2011/6/10/2

Thanks for the pointer, Hugh. I have missed that thread @kvack.
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
