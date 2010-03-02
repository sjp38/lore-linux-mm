Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D83486B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 03:02:03 -0500 (EST)
Date: Tue, 2 Mar 2010 09:01:58 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100302080056.GA1548@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-4-git-send-email-arighi@develer.com>
 <20100302092309.bff454d7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100302092309.bff454d7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 09:23:09AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon,  1 Mar 2010 22:23:40 +0100
> Andrea Righi <arighi@develer.com> wrote:
> 
> > Apply the cgroup dirty pages accounting and limiting infrastructure to
> > the opportune kernel functions.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> 
> Seems nice.
> 
> Hmm. the last problem is moving account between memcg.
> 
> Right ?

Correct. This was actually the last item of the TODO list. Anyway, I'm
still considering if it's correct to move dirty pages when a task is
migrated from a cgroup to another. Currently, dirty pages just remain in
the original cgroup and are flushed depending on the original cgroup
settings. That is not totally wrong... at least moving the dirty pages
between memcgs should be optional (move_charge_at_immigrate?).

Thanks for your ack and the detailed review!

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
