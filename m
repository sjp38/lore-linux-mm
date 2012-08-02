Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7BA226B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 17:46:35 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so5028bkc.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 14:46:33 -0700 (PDT)
Message-ID: <501AF555.3050004@gmail.com>
Date: Thu, 02 Aug 2012 23:47:01 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <5019B0B4.1090102@gmail.com> <20120801224556.GF15477@google.com> <501A4FC1.8040907@gmail.com> <20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com> <501A7AD3.7000008@gmail.com> <20120802161556.GA25572@leaf> <501AAF47.3090708@gmail.com> <20120802174457.GA6251@jtriplet-mobl1> <501ABEE2.10007@gmail.com> <20120802204157.GB7916@jtriplet-mobl1>
In-Reply-To: <20120802204157.GB7916@jtriplet-mobl1>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On 08/02/2012 10:41 PM, Josh Triplett wrote:
> On Thu, Aug 02, 2012 at 07:54:42PM +0200, Sasha Levin wrote:
>> /* I've "preprocessed" the DEFINE macro below */
>> union {
>> 	struct hash_table table;
>> 	struct {
>> 		size_t bits;
>> 		struct hlist_head buckets[32];
>> 	}
>> } my_hashtable;
> 
> That expansion doesn't match the macros.  Using the most recent
> definitions of DEFINE_HASHTABLE and DEFINE_STATIC_HASHTABLE from above,
> the definition would look something like this:
> 
> static union {
> 	struct hash_table my_hashtable;
> 	struct {
> 		size_t bits;
> 		struct hlist_head buckets[1 << 5];
> 	} __my_hashtable;
> } = { .my_hashtable.bits = 5 };

It's different because I don't think you can do what you did above with global variables.

You won't be defining any instances of that anonymous struct, so my_hashtable won't exist anywhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
