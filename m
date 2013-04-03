Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 303256B00C1
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:54:33 -0400 (EDT)
Message-ID: <515BEE65.40503@parallels.com>
Date: Wed, 3 Apr 2013 12:55:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 05/28] dcache: remove dentries from LRU before putting
 on dispose list
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-6-git-send-email-glommer@parallels.com> <CAFj3OHU_o5o_n_kcci1U_=M0tCpYEwy8abRvHKBdp-GoJ-cs3w@mail.gmail.com>
In-Reply-To: <CAFj3OHU_o5o_n_kcci1U_=M0tCpYEwy8abRvHKBdp-GoJ-cs3w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2013 10:51 AM, Sha Zhengju wrote:
>     +static void
>     +shrink_dcache_list(
>     +       struct list_head *dispose)
>     +{
>     +       struct dentry *dentry;
>     +
>     +       rcu_read_lock();
>     +       list_for_each_entry_rcu(dentry, dispose, d_lru) {
>     +               spin_lock(&dentry->d_lock);
>     +               dentry->d_flags |= DCACHE_SHRINK_LIST;
>     +               this_cpu_dec(nr_dentry_unused);
> 
> 
> Why here dec nr_dentry_unused again? Has it been decreased in the
> following shrink_dcache_sb()?

You analysis seems to be correct, and the decrement in shrink_dcache_sb
seems not to be needed.

Dave, have comments on this ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
