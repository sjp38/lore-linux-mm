Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 12EB36B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 13:14:34 -0400 (EDT)
Date: Wed, 19 Jun 2013 10:14:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 25/25] list_lru: dynamically adjust node arrays
Message-Id: <20130619101414.49da3bfb.akpm@linux-foundation.org>
In-Reply-To: <20130619132904.GA4031@localhost.localdomain>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
	<1370550898-26711-26-git-send-email-glommer@openvz.org>
	<1371548521.2984.6.camel@ThinkPad-T5421>
	<20130619073154.GA1990@localhost.localdomain>
	<1371633148.2984.18.camel@ThinkPad-T5421>
	<20130619132904.GA4031@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Li Zhong <lizhongfs@gmail.com>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>

On Wed, 19 Jun 2013 17:29:06 +0400 Glauber Costa <glommer@gmail.com> wrote:

> > > Thanks for taking a look at this.
> > > 
> > > list_lru_destroy is called by deactivate_lock_super, so we should be fine already.
> > 
> > Sorry, I'm a little confused...
> > 
> > I didn't see list_lru_destroy() called in deactivate_locked_super().
> > Maybe I missed something? 
> 
> Err... the code in my tree reads:
> 
>         unregister_shrinker(&s->s_shrink);
>         list_lru_destroy(&s->s_dentry_lru);
>         list_lru_destroy(&s->s_inode_lru);
>         put_filesystem(fs);
>         put_super(s);
> 
> But then I have just checked Andrew's, and it is not there - thank you.

That is added by "super: targeted memcg reclaim", which is in the part
of the series which we decided to defer.

> Andrew, should I send a patch for you to fold it ?

Sure.  Perhaps you could check for any other things which should be
brought over from the not-merged-yet patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
