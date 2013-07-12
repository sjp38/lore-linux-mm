Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9950C6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 07:50:31 -0400 (EDT)
Date: Fri, 12 Jul 2013 13:50:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [-] drop_caches-add-some-documentation-and-info-messsge.patch
 removed from -mm tree
Message-ID: <20130712115028.GC15307@dhcp22.suse.cz>
References: <51ddc31f.zotz9WDKK3lWXtDE%akpm@linux-foundation.org>
 <20130711073644.GB21667@dhcp22.suse.cz>
 <20130711145034.3ec774d0a44742cf5d8e1177@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711145034.3ec774d0a44742cf5d8e1177@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>

On Thu 11-07-13 14:50:34, Andrew Morton wrote:
> On Thu, 11 Jul 2013 09:36:44 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 10-07-13 13:25:03, Andrew Morton wrote:
> > [...]
> > > This patch was dropped because it has gone stale
> > 
> > Is there really a strong reason to not take this patch? 
> 
> I flushed out a whole bunch of MM patches which had been floating
> around in indecisive limbo.
> 
> I don't recall all the review issues surrounding this one.

Kosaki was concerned about annoying number of messages if somebody drops
caches too often (https://lkml.org/lkml/2010/9/20/450). As I noted in
the changelog
"
    Kosaki was worried about possible excessive logging when somebody drops
    caches too often (but then he claimed he didn't have a strong opinion on
    that) but I would say opposite.  If somebody does that then I would really
    like to know that from the log when supporting a system because it almost
    for sure means that there is something fishy going on.  It is also worth
    mentioning that only root can write drop caches so this is not an flooding
    attack vector.
"

Kosaki then Acked the patch.

You were worried (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00605.html)
about people hating us because they are using this as a solution to
their issues. I concur that most of those are just hacks that found
their way into scripts looong time agon and stayed there.

Boris then noted (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00659.html)
that he is using drop_caches to make s2ram faster but as others noted
this just adds the overhead to the resume path so it might work only for
certain use cases so a user space solution is more appropriate and
Boris' use case really sounds valid.

As a compromise I can lower the log level. Would KERN_INFO work for
you? Or even KERN_DEBUG?

I still find printk less intrusive than fiddling with vmstat counters.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
