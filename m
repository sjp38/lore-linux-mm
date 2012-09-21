Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 9478F6B0062
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:14:11 -0400 (EDT)
Received: by padhz10 with SMTP id hz10so455371pad.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 02:14:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <505C2856.70900@parallels.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
	<1347977050-29476-7-git-send-email-glommer@parallels.com>
	<CAAmzW4ONnc7n3kZbYnE6n2Cg0ZyPXW0QU2NMr0uRkyTxnGpNqQ@mail.gmail.com>
	<505C2856.70900@parallels.com>
Date: Fri, 21 Sep 2012 18:14:10 +0900
Message-ID: <CAAmzW4MbqMevvxk1ibcogr2ED74kR2_46MRX=VO5dLLa4CZkAA@mail.gmail.com>
Subject: Re: [PATCH v3 06/13] memcg: kmem controller infrastructure
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

>> "*_memcg = memcg" should be executed when "memcg_charge_kmem" is success.
>> "memcg_charge_kmem" return 0 if success in charging.
>> Therefore, I think this code is wrong.
>> If I am right, it is a serious bug that affect behavior of all the patchset.
>
> Which is precisely what it does. ret is a boolean, that will be true
> when charge succeeded (== 0 test)

Ahh...Okay! I didn't see (== 0 test)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
