Received: by rv-out-0708.google.com with SMTP id k29so5724642rvb.2
        for <linux-mm@kvack.org>; Wed, 29 Oct 2008 00:20:25 -0700 (PDT)
Message-ID: <2f11576a0810290020i362441edkb494b10c10b17401@mail.gmail.com>
Date: Wed, 29 Oct 2008 16:20:24 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <20081028134536.9a7a5351.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081027145509.ebffcf0e.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0810280914010.15939@quilx.com>
	 <20081028134536.9a7a5351.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, npiggin@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, torvalds@linux-foundation.org, riel@redhat.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I guess we should document our newly discovered schedule_on_each_cpu()
> problems before we forget about it and later rediscover it.

Now, schedule_on_each_cpu() is only used by lru_add_drain_all().
and smp_call_function() is better way for cross call.

So I propose
   1. lru_add_drain_all() use smp_call_function()
   2. remove schedule_on_each_cpu()


Thought?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
