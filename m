Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6846B4D74
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 16:03:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w126-v6so5384567qka.11
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:03:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z64-v6si4736268qkc.44.2018.08.29.13.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 13:03:33 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828160150.9a45ee293c92708edb511eab@linux-foundation.org>
 <20180829175405.GA17337@linux.vnet.ibm.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <9d5a85f6-29fc-b33e-f0c5-d2b65d0f70de@redhat.com>
Date: Wed, 29 Aug 2018 16:03:32 -0400
MIME-Version: 1.0
In-Reply-To: <20180829175405.GA17337@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/29/2018 01:54 PM, Paul E. McKenney wrote:
> On Tue, Aug 28, 2018 at 04:01:50PM -0700, Andrew Morton wrote:
>> Another pet peeve ;)
>>
>> On Tue, 28 Aug 2018 13:19:40 -0400 Waiman Long <longman@redhat.com> wrote:
>>
>>>  /**
>>> + * list_lru_add_head: add an element to the lru list's head
>>> + * @list_lru: the lru pointer
>>> + * @item: the item to be added.
>>> + *
>>> + * This is similar to list_lru_add(). The only difference is the location
>>> + * where the new item will be added. The list_lru_add() function will add
>> People often use the term "the foo() function".  I don't know why -
>> just say "foo()"!
> For whatever it is worth...
>
> I tend to use "The foo() function ..." instead of "foo() ..." in order
> to properly capitalize the first word of the sentence.  So I might say
> "The call_rcu() function enqueues an RCU callback." rather than something
> like "call_rcu() enqueues an RCU callback."  Or I might use some other
> trick to keep "call_rcu()" from being the first word of the sentence.
> But if the end of the previous sentence introduced call_rcu(), you
> usually want the next sentence's first use of "call_rcu()" to be very
> early in the sentence, because otherwise the flow will seem choppy.
>
> And no, I have no idea what I would do if I were writing in German,
> where nouns are capitalized, given that function names tend to be used
> as nouns.  Probably I would get yelled at a lot for capitalizing my
> function names.  ;-)
>
> 							Thanx, Paul
>
Yes, doing proper capitalization of the first letter of a sentence is
the main reason I used "The foo() function" in a sentence.

Cheers,
Longman
