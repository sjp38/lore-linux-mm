Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 789A56B00F7
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 09:41:37 -0400 (EDT)
Message-ID: <515ED4B4.2030101@parallels.com>
Date: Fri, 5 Apr 2013 17:42:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/7] memcg: use css_get in sock_update_memcg()
References: <515BF233.6070308@huawei.com> <515BF249.50607@huawei.com> <515C2788.90907@parallels.com> <20130403152934.GL16471@dhcp22.suse.cz> <515E8688.3000504@parallels.com> <20130405133815.GE31132@dhcp22.suse.cz>
In-Reply-To: <20130405133815.GE31132@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

> 
> OK, I guess I understand.
> 
> Thanks for the clarification, Galuber!

You're welcome Mihcal!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
