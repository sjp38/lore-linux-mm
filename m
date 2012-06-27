Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A90706B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:07:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2247029pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 10:07:38 -0700 (PDT)
Date: Wed, 27 Jun 2012 10:07:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120627170734.GI15811@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626185542.GE27816@cmpxchg.org>
 <20120626191450.GT3869@google.com>
 <20120626205924.GH27816@cmpxchg.org>
 <20120626211907.GX3869@google.com>
 <4FEACAE8.6000500@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEACAE8.6000500@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 27, 2012 at 12:57:12PM +0400, Glauber Costa wrote:
> >I have to disagree with that.  Deployment sometimes can be very
> >painful.  In some cases, even flipping single parameter in sysfs
> >depending on kernel version takes considerable effort.  The behavior
> >has been the contract that we offered userland for quite some time
> >now.  We shouldn't be changing that underneath them without any clear
> >way for them to notice it.
> 
> Yes, and that's why once you deploy, you keep your updates to a
> minimum. Because hell, even *perfectly legitimate bug fixes* can
> change your behavior in a way you don't want. And you don't expect
> people to refrain from fixing bugs because of that.

Dude, there are numerous organizations running all types of
infrastructures.  I personally know some running debian + mainline
kernel with regular kernel refresh (no, they aren't small).  Silent
behavior switches like this will be a big glowing fuck-you to those
people and I don't wanna do that.  And then there are infrastructures
where new machines are continuously deployed and you know what? new
machines often require new kernels.  What are you gonna tell them?
Don't cycle-upgrade your machines once you're in production?

Please stop trying to argue that silently switching major behavior
like this is okay.  It simply isn't.  This is breaching one of the
most basic assumptions that our direct users make.  NONONONONONONO.

> That is precisely why people in serious environments tend to run
> -stable, distro LTSes, or anything like that. Because they don't
> want any change, however minor, to potentially affect their stamped
> behavior. I am not proposing this patch to -stable, btw...

Yeah, because once an environment is in prod, the only update they
need is -stable and we can switch behaviors willy-nilly on any
release.  Ugh......

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
