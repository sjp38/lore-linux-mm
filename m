Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1F4856B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:32:24 -0500 (EST)
Message-ID: <50BDB511.5070107@parallels.com>
Date: Tue, 4 Dec 2012 12:32:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memcg: split part of memcg creation to css_online
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-4-git-send-email-glommer@parallels.com> <20121203173205.GI17093@dhcp22.suse.cz> <50BDAEC1.8040805@parallels.com> <20121204081756.GA31319@dhcp22.suse.cz>
In-Reply-To: <20121204081756.GA31319@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 12/04/2012 12:17 PM, Michal Hocko wrote:
>> But it should be extremely easy to protect against this. It is just a
>> > matter of not returning online css in the iterator: then we'll never see
>> > them until they are online. This also sounds a lot more correct than
>> > returning allocated css.
> Yes but... Look at your other patch which relies on iterator when counting
> children to find out if there is any available.
>  
And what is the problem with it ?

As I said: if the iterator will not return css that are not online, we
should not have a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
