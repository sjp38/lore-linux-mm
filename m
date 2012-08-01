Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2DE156B005A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 18:41:28 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so4780167bkc.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 15:41:26 -0700 (PDT)
Message-ID: <5019B0B4.1090102@gmail.com>
Date: Thu, 02 Aug 2012 00:41:56 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com> <1343757920-19713-2-git-send-email-levinsasha928@gmail.com> <20120731182330.GD21292@google.com> <50197348.9010101@gmail.com> <20120801182112.GC15477@google.com> <50197460.8010906@gmail.com> <20120801182749.GD15477@google.com> <50197E4A.7020408@gmail.com> <20120801202432.GE15477@google.com>
In-Reply-To: <20120801202432.GE15477@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On 08/01/2012 10:24 PM, Tejun Heo wrote:
> On Wed, Aug 01, 2012 at 09:06:50PM +0200, Sasha Levin wrote:
>> Using a struct makes the dynamic case much easier, but it complicates the static case.
>>
>> Previously we could create the buckets statically.
>>
>> Consider this struct:
>>
>> struct hash_table {
>> 	u32 bits;
>> 	struct hlist_head buckets[];
>> };
>>
>> We can't make any code that wraps this to make it work properly
>> statically allocated nice enough to be acceptable.
> 
> I don't know.  Maybe you can create an anonymous outer struct / union
> and play symbol trick to alias hash_table to its member.  If it is
> gimped either way, I'm not sure whether it's really worthwhile to
> create the abstraction.  It's not like we're saving a lot of
> complexity.

I must be missing something here, but how would you avoid it?

How would your DEFINE_HASHTABLE look like if we got for the simple 'struct hash_table' approach?

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
