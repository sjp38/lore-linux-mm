Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7BA2F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 15:14:59 -0400 (EDT)
Message-ID: <514767A5.4020601@zytor.com>
Date: Mon, 18 Mar 2013 12:14:45 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
References: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com> <51476402.7050102@zytor.com> <CAE9FiQUZDqqeAp2y=Pc9yFT81Pf+ei2SEx4NUD6jC+nQmd6PcA@mail.gmail.com>
In-Reply-To: <CAE9FiQUZDqqeAp2y=Pc9yFT81Pf+ei2SEx4NUD6jC+nQmd6PcA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, penberg@kernel.org, jacob.shin@amd.com

On 03/18/2013 12:13 PM, Yinghai Lu wrote:
>>
>> No, it doesn't.  This is C, not elementary school  Now I'm really bothered.
>>
>> The comment doesn't say *why* (PUD_SHIFT-PMD_SHIFT)/2 or any other
>> variant is correct, furthermore I suspect that the +1 is misplaced.
>> However, what is really needed is:
>>
>> 1. Someone needs to explain what the logic should be and why, and
>> 2. replace the macro with a symbolic macro, not with a constant and a
>>    comment explaining, incorrectly, how that value was derived.
> 
> yes, we should find out free_mem_size instead to decide next step size.
> 
> But that will come out page table size estimation problem again.
> 

Sorry, that comment is double nonsense for someone who isn't intimately
familiar with the code, and it sounds like it is just plain wrong.

Instead, try to explain why 5 is the correct value in the current code
and how it is (or should be!) derived.

	-hpa



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
