Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id F23586B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 16:24:37 -0400 (EDT)
Received: by yhr47 with SMTP id 47so9259325yhr.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 13:24:37 -0700 (PDT)
Date: Wed, 1 Aug 2012 13:24:32 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120801202432.GE15477@google.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
 <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
 <20120731182330.GD21292@google.com>
 <50197348.9010101@gmail.com>
 <20120801182112.GC15477@google.com>
 <50197460.8010906@gmail.com>
 <20120801182749.GD15477@google.com>
 <50197E4A.7020408@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50197E4A.7020408@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Wed, Aug 01, 2012 at 09:06:50PM +0200, Sasha Levin wrote:
> Using a struct makes the dynamic case much easier, but it complicates the static case.
> 
> Previously we could create the buckets statically.
> 
> Consider this struct:
> 
> struct hash_table {
> 	u32 bits;
> 	struct hlist_head buckets[];
> };
> 
> We can't make any code that wraps this to make it work properly
> statically allocated nice enough to be acceptable.

I don't know.  Maybe you can create an anonymous outer struct / union
and play symbol trick to alias hash_table to its member.  If it is
gimped either way, I'm not sure whether it's really worthwhile to
create the abstraction.  It's not like we're saving a lot of
complexity.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
