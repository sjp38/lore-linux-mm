Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id C895E6B00D3
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 08:43:25 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id pa12so1691520veb.30
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 05:43:24 -0700 (PDT)
Date: Wed, 7 Aug 2013 08:43:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to
 memcg
Message-ID: <20130807124321.GA27006@htj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <20130805160107.GM10146@dhcp22.suse.cz>
 <20130805162958.GF19631@mtj.dyndns.org>
 <20130805191641.GA24003@dhcp22.suse.cz>
 <20130805194431.GD23751@mtj.dyndns.org>
 <20130806155804.GC31138@dhcp22.suse.cz>
 <20130806161509.GB10779@mtj.dyndns.org>
 <20130807121836.GF8184@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807121836.GF8184@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Michal.

On Wed, Aug 07, 2013 at 02:18:36PM +0200, Michal Hocko wrote:
> How is it specific to memcg? The fact only memcg uses the interface
> doesn't imply it is memcg specific.

I don't follow.  It's only for memcg.  That is *by definition* memcg
specific.  It's the verbatim meaning of the word.  Now, I do
understand that it can be a concern the implementation details as-is
could be a bit too invasive into cgroup core to be moved to memcg, but
that's something we can work on, right?  Can you at least agree that
the feature is nmemcg specific and it'd be better to be located in
memcg if possible?  That really isn't not much to ask and is a logical
thing to do.

> There are other ways to achieve the same. E.g. not ack new usage of
> register callback users. We have done similar with other things like
> use_hierarchy...

Yes, but those are all inferior to actually moving the code where it
belongs.  Those makes the code harder to follow and people
misunderstand and waste time working on stuff (either in the core or
controllers) which eventually end up getting nacked.  Why do that when
we can easily do better?  What's the rationale behind that?

> The cleanup is removing 2 callbacks with a cost of moving non-memcg
> specific code inside memcg. That is what I am objecting to.

I don't really get your "non-memcg" specific code assertion when it is
by definition memcg-specific.  What are you talking about?

> I will not repeat myself. We seem to disagree on where the code belongs.
> As I've said I will not ack this code, try to find somebody else who
> think it is a good idea. I do not see any added value.

Nacking is part of your authority as maintainer but you should still
provide plausible rationale for that.  Are you saying that even if the
code is restructured so that it's not invasive into cgroup core, you
are still gonna disagree with it because it's still somehow not
memcg-specifc?  Please don't repeat yourself but do explain your
rationale.  That's part of your duty as a maintainer too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
