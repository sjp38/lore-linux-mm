Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A7DA56B0088
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:19:51 -0500 (EST)
Message-ID: <4B547C09.8010906@redhat.com>
Date: Mon, 18 Jan 2010 17:19:37 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
References: <20100118133755.GG30698@redhat.com>	 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>	 <20100118141938.GI30698@redhat.com>	 <20100118143232.0a0c4b4d@lxorguk.ukuu.org.uk>	 <1263826198.4283.600.camel@laptop>  <20100118150159.GB14345@redhat.com>	 <1263827194.4283.609.camel@laptop>  <4B547A31.4090106@redhat.com> <1263827683.4283.610.camel@laptop>
In-Reply-To: <1263827683.4283.610.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gleb Natapov <gleb@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 01/18/2010 05:14 PM, Peter Zijlstra wrote:
> On Mon, 2010-01-18 at 17:11 +0200, Avi Kivity wrote:
>    
>> On 01/18/2010 05:06 PM, Peter Zijlstra wrote:
>>      
>>> On Mon, 2010-01-18 at 17:01 +0200, Gleb Natapov wrote:
>>>
>>>        
>>>> There are valid uses for mlockall()
>>>>
>>>>          
>>> That's debatable.
>>>
>>>
>>>        
>> Real-time?
>>      
> I would not advice that, just mlock() the text and data you need for the
> real-time thread. mlockall() is a really blunt instrument.
>    

May not be feasible due to libraries.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
