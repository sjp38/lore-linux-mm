Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 91EC96B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 14:43:15 -0500 (EST)
Message-ID: <50F9A5E3.9000406@parallels.com>
Date: Fri, 18 Jan 2013 11:43:31 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] memcg: provide online test for memcg
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-4-git-send-email-glommer@parallels.com> <20130118153715.GG10701@dhcp22.suse.cz> <20130118155621.GH10701@dhcp22.suse.cz> <50F9A5B3.8050203@parallels.com>
In-Reply-To: <50F9A5B3.8050203@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/18/2013 11:42 AM, Glauber Costa wrote:
>> And the later patch in the series shows that it is really not helpful on
>> > its own. You need to rely on other lock to be helpful.
> No, no need not.
geee, what kind of phrase is that??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
