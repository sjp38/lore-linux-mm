Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 396366B005A
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 12:35:02 -0500 (EST)
Received: by yenq10 with SMTP id q10so11229514yen.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 09:35:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120104084611.GA12581@tiehlicka.suse.cz>
References: <1325633632-9978-1-git-send-email-kosaki.motohiro@gmail.com> <20120104084611.GA12581@tiehlicka.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 4 Jan 2012 12:34:39 -0500
Message-ID: <CAHGf_=o-mBAZxAW=vHSKKBCGqtzc+ooXrc9+vHvPoo_t4A9Chg@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: root_mem_cgroup makes static
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org

2012/1/4 Michal Hocko <mhocko@suse.cz>:
> On Tue 03-01-12 18:33:51, kosaki.motohiro@gmail.com wrote:
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> root_mem_cgroup is only referenced from memcontrol.c. It should be static.
>
> This has been already posted by Kirill
> https://lkml.org/lkml/2011/12/23/292

Oops. I haven't noticed.

Thank you, Michal!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
