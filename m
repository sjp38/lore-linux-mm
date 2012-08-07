Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 596CE6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 21:53:43 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so1676679bkc.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 18:53:41 -0700 (PDT)
Message-ID: <5020754A.6090906@gmail.com>
Date: Tue, 07 Aug 2012 03:54:18 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 1/7] hashtable: introduce a small and naive hashtable
References: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com> <1344300317-23189-2-git-send-email-levinsasha928@gmail.com> <502073E9.8050205@cn.fujitsu.com>
In-Reply-To: <502073E9.8050205@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wei <lw@cn.fujitsu.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com

On 08/07/2012 03:48 AM, Li Wei wrote:
> On 08/07/2012 08:45 AM, Sasha Levin wrote:
>> +/**
>> + * hash_for_each - iterate over a hashtable
>> + * @name: hashtable to iterate
>> + * @bits: bit count of hashing function of the hashtable
>> + * @bkt: integer to use as bucket loop cursor
>> + * @node: the &struct list_head to use as a loop cursor for each bucket
>> + * @obj: the type * to use as a loop cursor for each bucket
>> + * @member: the name of the hlist_node within the struct
>> + */
>> +#define hash_for_each(name, bits, bkt, node, obj, member)		\
>> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)			\
>> +		hlist_for_each_entry(obj, node, &name[i], member)
> 
> Where is the 'i' coming from? maybe &name[bkt]?

Heh, yeah. And the only place that uses this macro had 'i' declared as the loop counter, so it didn't trigger any issues during testing.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
