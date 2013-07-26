Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id BCBF66B0070
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:37:58 -0400 (EDT)
Date: Fri, 26 Jul 2013 17:37:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130726213750.GE17975@cmpxchg.org>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, Jul 26, 2013 at 02:44:29PM +0200, Michal Hocko wrote:
> I would like to resurrect Dave's patch.  It was originally posted here
> https://lkml.org/lkml/2010/9/16/250 and I have resurrected it here
> https://lkml.org/lkml/2012/10/12/175 for the first time. There didn't
> seem to be any strong opposition but the patch has been dropped later
> from the mm tree.
> 
> To summarize concerns:
> Kosaki was worried about possible excessive logging when somebody drops
> caches too often (but then he claimed he didn't have a strong opinion on
> that) and later acked the patch (https://lkml.org/lkml/2012/10/12/350).
> I would even dare to say opposite. If somebody drops caches too often
> then I would really like to know that from the log when supporting a
> system because it almost for sure means that there is something fishy
> going on. It is also worth mentioning that only root can write drop
> caches so this is not an flooding attack vector.

Agreed.

> Andrew was worried (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00605.html)
> about people hating us because they are using this as a solution to
> their issues. I concur that most of those are just hacks that found
> their way into scripts looong time agon and stayed there. We should
> rather not feed these cargo cults and rather fix the real bugs. History
> has been showing us that users are usually getting rid of old hacks when
> something starts screeming at them. So let's screem.

Agreed.  The whole point of this is to be a pain in the ass in order
to establish a feedback loop.

> Boris then noted (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00659.html)
> that he is using drop_caches to make s2ram faster but as others noted
> this just adds the overhead to the resume path so it might work only for
> certain use cases. Having a low priority message under such conditions
> shouldn't such a big deal.

A oneliner like this should drown in the overall noise of the
suspend-resume path.

> I am bringing the patch up again because this has proved being really
> helpful when chasing strange performance issues which (surprise
> surprise) turn out to be related to artificially dropped caches done
> because the admin thinks this would help... So mostly those who support
> machines which are not in their hands would benefit from such a change.
> 
> I have just refreshed the original patch on top of the current mm tree
> and lowered priority to KERN_INFO to make the message less hysterical.
> 
> : From: Dave Hansen <dave@linux.vnet.ibm.com>
> : Date: Fri, 12 Oct 2012 14:30:54 +0200
> :
> : There is plenty of anecdotal evidence and a load of blog posts
> : suggesting that using "drop_caches" periodically keeps your system
> : running in "tip top shape".  Perhaps adding some kernel
> : documentation will increase the amount of accurate data on its use.
> :
> : If we are not shrinking caches effectively, then we have real bugs.
> : Using drop_caches will simply mask the bugs and make them harder
> : to find, but certainly does not fix them, nor is it an appropriate
> : "workaround" to limit the size of the caches.
> :
> : It's a great debugging tool, and is really handy for doing things
> : like repeatable benchmark runs.  So, add a bit more documentation
> : about it, and add a little KERN_NOTICE.  It should help developers
> : who are chasing down reclaim-related bugs.
> 
> [mhocko@suse.cz: refreshed to current -mm tree]
> [akpm@linux-foundation.org: checkpatch fixes]
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
