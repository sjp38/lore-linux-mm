Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2CC0A6B0062
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 17:13:54 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so941566wgb.26
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 14:13:52 -0700 (PDT)
Message-ID: <501C3F2B.7080004@gmail.com>
Date: Fri, 03 Aug 2012 23:14:19 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 7/7] net,9p: use new hashtable implementation
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>  <1344003788-1417-8-git-send-email-levinsasha928@gmail.com> <1344016851.9299.1415.camel@edumazet-glaptop>
In-Reply-To: <1344016851.9299.1415.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On 08/03/2012 08:00 PM, Eric Dumazet wrote:
> On Fri, 2012-08-03 at 16:23 +0200, Sasha Levin wrote:
>>  	/* initialize hash table */
>> -	for (bucket = 0; bucket < ERRHASHSZ; bucket++)
>> -		INIT_HLIST_HEAD(&hash_errmap[bucket]);
>> +	hash_init(&hash_errmap, ERRHASHSZ);
> 
> Why is hash_init() even needed ?
> 
> If hash is "DEFINE_STATIC_HASHTABLE(...)", its already ready for use !

Indeed it is.

I've removed it, and then decided to put it back since the definition of the hashtable isn't fully cooked yet, and I didn't want to miss this initialization point if it turn out we need to initialize that hashtable afterall.

I will remove it once the hashtable definitions are clear.

The rest of the review comments will be addressed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
