Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8FAE06B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:33:56 -0400 (EDT)
Date: Wed, 23 May 2012 13:33:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 2/2] decrement static keys on real destroy time
Message-Id: <20120523133354.373f1bb4.akpm@linux-foundation.org>
In-Reply-To: <4FBCAAF4.4030803@parallels.com>
References: <1337682339-21282-1-git-send-email-glommer@parallels.com>
	<1337682339-21282-3-git-send-email-glommer@parallels.com>
	<20120522154610.f2f9b78e.akpm@linux-foundation.org>
	<4FBCAAF4.4030803@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Miller <davem@davemloft.net>

On Wed, 23 May 2012 13:16:36 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 05/23/2012 02:46 AM, Andrew Morton wrote:
> > Here, we're open-coding kinda-test_bit().  Why do that?  These flags are
> > modified with set_bit() and friends, so we should read them with the
> > matching test_bit()?
> 
> My reasoning was to be as cheap as possible, as you noted yourself two
> paragraphs below.

These aren't on any fast path, are they?

Plus: you failed in that objective!  The C compiler's internal
scalar->bool conversion makes these functions no more efficient than
test_bit().

> > So here are suggested changes from*some*  of the above discussion.
> > Please consider, incorporate, retest and send us a v7?
> 
> How do you want me to do it? Should I add your patch ontop of mine,
> and then another one that tweaks whatever else is left, or should I just
> merge those changes into the patches I have?

A brand new patch, I guess.  I can sort out the what-did-he-change view
at this end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
