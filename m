Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 35AF26B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 22:40:53 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id i18so4242678oag.32
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:40:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1212191439530.32757@chino.kir.corp.google.com>
References: <1355925061-3858-1-git-send-email-handai.szj@taobao.com>
	<alpine.DEB.2.00.1212191439530.32757@chino.kir.corp.google.com>
Date: Fri, 21 Dec 2012 11:40:52 +0800
Message-ID: <CAFj3OHXBFg=xZbvFwWwMQNipC0mCn2hS9pFH59HDmzS9YKqz4Q@mail.gmail.com>
Subject: Re: [PATCH V5] memcg, oom: provide more precise dump info while memcg
 oom happening
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, mhocko@suse.cz, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sha Zhengju <handai.szj@taobao.com>

> I'd ask that you put a limit on the number of memcgs you print statistics
> for to prevent spamming the kernel log, otherwise it would be trivial to
> overwrite the entire buffer.  Do we really need the memory statistics forank
> the memcg 32 levels above us, for example?

Yeah, now there is no limit on numbers of printed memcg. But do we really
need to build so complicate memcg hierarchy for 32 levels? There is no
such usage now at least in our environment. : )


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
