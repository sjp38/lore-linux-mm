Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9A4E36B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:34:19 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so5277442bkc.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 09:34:17 -0700 (PDT)
Message-ID: <501AAC26.6030703@gmail.com>
Date: Thu, 02 Aug 2012 18:34:46 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <20120731182330.GD21292@google.com> <50197348.9010101@gmail.com> <20120801182112.GC15477@google.com> <50197460.8010906@gmail.com> <20120801182749.GD15477@google.com> <50197E4A.7020408@gmail.com> <20120801202432.GE15477@google.com> <5019B0B4.1090102@gmail.com> <20120801224556.GF15477@google.com> <501A4FC1.8040907@gmail.com> <20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com> <87txwl1dsq.fsf@xmission.com>
In-Reply-To: <87txwl1dsq.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Josh Triplett <josh@joshtriplett.org>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On 08/02/2012 06:03 PM, Eric W. Biederman wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
>> On 08/02/2012 12:32 PM, Josh Triplett wrote:
>>> What about using a C99 flexible array member?  Kernel style prohibits
>>> variable-length arrays, but I don't think the same rationale applies to
>>> flexible array members.
>>>
>>> struct hash_table {
>>>     size_t count;
>>>     struct hlist_head buckets[];
>>> };
>>>
>>> #define DEFINE_HASH_TABLE(name, length) struct hash_table name = { .count = length, .buckets = { [0 ... (length - 1)] = HLIST_HEAD_INIT } }
>>
>> The limitation of this approach is that the struct hash_table variable
>> must be 'static', which is a bit limiting - see for example the use of
>> hashtable in 'struct user_namespace'.
> 
> You mean the hash table that was made static in 3.5?
> 
> You might want to try basing your patches on something a little more current.
> 
> Eric
> 

Heh, I've started working on it in April, and just returned to this. Didn't think about rebasing to something new.

will fix - Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
