Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 24CD36B0071
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:19:23 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so4686863bkc.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 11:19:21 -0700 (PDT)
Message-ID: <50197348.9010101@gmail.com>
Date: Wed, 01 Aug 2012 20:19:52 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com> <1343757920-19713-2-git-send-email-levinsasha928@gmail.com> <20120731182330.GD21292@google.com>
In-Reply-To: <20120731182330.GD21292@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On 07/31/2012 08:23 PM, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Tue, Jul 31, 2012 at 08:05:17PM +0200, Sasha Levin wrote:
>> +#define HASH_INIT(name)							\
>> +({									\
>> +	int __i;							\
>> +	for (__i = 0 ; __i < HASH_SIZE(name) ; __i++)			\
>> +		INIT_HLIST_HEAD(&name[__i]);				\
>> +})
> 
> Why use macro?
> 
>> +#define HASH_ADD(name, obj, key)					\
>> +	hlist_add_head(obj, &name[					\
>> +		hash_long((unsigned long)key, HASH_BITS(name))]);
> 
> Ditto.

Oh, yes, I've started working on this and remembered why it's macro in the first place.

Notice that we don't store hashtable size anywhere, this is because we can get it directly from the size of the hashtable array itself.

If we switch to using functions, we could no longer hide it anywhere (we'd need to either turn the buckets into a struct, or have the user pass it around to all functions).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
