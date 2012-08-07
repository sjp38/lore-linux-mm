Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 72AC86B0044
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 05:49:07 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so1850658bkc.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 02:49:05 -0700 (PDT)
Message-ID: <5020E4B5.4040702@gmail.com>
Date: Tue, 07 Aug 2012 11:49:41 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 1/7] hashtable: introduce a small and naive hashtable
References: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com> <1344300317-23189-2-git-send-email-levinsasha928@gmail.com> <20120807025520.GA3823@leaf>
In-Reply-To: <20120807025520.GA3823@leaf>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com

On 08/07/2012 04:55 AM, Josh Triplett wrote:
> On Tue, Aug 07, 2012 at 02:45:10AM +0200, Sasha Levin wrote:
>> +/**
>> + * hash_add - add an object to a hashtable
>> + * @hashtable: hashtable to add to
>> + * @bits: bit count used for hashing
>> + * @node: the &struct hlist_node of the object to be added
>> + * @key: the key of the object to be added
>> + */
>> +#define hash_add(hashtable, bits, node, key)				\
>> +	hlist_add_head(node, &hashtable[hash_min(key, bits)]);
> 
> Any particular reason to make this a macro rather than a static inline?

Yes. As Eric Dumazet pointed out, hash_64() is slower than hash_32() so we should be calling hash_32() if possible (if key size is 32bits long).

This way we can call hash_min() without knowing the key size. See also the definition of hash_min() above.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
