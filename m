Message-ID: <480E0324.6050006@qumranet.com>
Date: Tue, 22 Apr 2008 18:24:20 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
References: <ea87c15371b1bd49380c.1208872277@duo.random> <480DFC8A.8040105@cosmosbay.com> <20080422151529.GE24536@duo.random>
In-Reply-To: <20080422151529.GE24536@duo.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 04:56:10PM +0200, Eric Dumazet wrote:
>   
>> Andrea Arcangeli a ecrit :
>>     
>>> +
>>> +static int mm_lock_cmp(const void *a, const void *b)
>>> +{
>>> +	cond_resched();
>>> +	if ((unsigned long)*(spinlock_t **)a <
>>> +	    (unsigned long)*(spinlock_t **)b)
>>> +		return -1;
>>> +	else if (a == b)
>>> +		return 0;
>>> +	else
>>> +		return 1;
>>> +}
>>> +
>>>       
>> This compare function looks unusual...
>> It should work, but sort() could be faster if the
>> if (a == b) test had a chance to be true eventually...
>>     
>
> Hmm, are you saying my mm_lock_cmp won't return 0 if a==b?
>
>   

You need to compare *a to *b (at least, that's what you're doing for the 
< case).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
