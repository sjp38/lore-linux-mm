Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5190E6B0075
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 09:30:55 -0400 (EDT)
Message-ID: <504601B8.2050907@parallels.com>
Date: Tue, 4 Sep 2012 17:27:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
References: <1346687211-31848-1-git-send-email-glommer@parallels.com> <20120903170806.GA21682@dhcp22.suse.cz> <5045BD25.10301@parallels.com> <20120904130905.GA15683@dhcp22.suse.cz>
In-Reply-To: <20120904130905.GA15683@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 09/04/2012 05:09 PM, Michal Hocko wrote:
> Not really. Do it slowly means that somebody actually _notices_ that
> something is about to change and they have a lot of time for that. This
> will be really hard with the config option saying N by default.  People
> will ignore that until it's too late.
> We are interested in those users who would keep the config default N and
> they are (ab)using use_hierarchy=0 in a way which is hard/impossible to
> fix. This is where distributions might help and they should IMHO but why
> to put an additional code into upstream? Isn't it sufficient that those
> who would like to help (and take the risk) would just take the patch?

At least Fedora, seem to frown upon heavily at non-upstream patches.
To follow up with what you say, what would you say if we would WARN_ON()
unconditionally even if this switch is turned off?

a warn on dmesg is almost impossible not to be seen by anyone who cares.
That warning would tell people to flip the Kconfig option for the
warning will disappear. But ultimately, we are still keeping the
behavior intact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
