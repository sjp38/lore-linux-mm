Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 3FDD66B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 14:59:29 -0400 (EDT)
Message-ID: <51476402.7050102@zytor.com>
Date: Mon, 18 Mar 2013 11:59:14 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
References: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com>
In-Reply-To: <CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, penberg@kernel.org, jacob.shin@amd.com

On 03/18/2013 11:53 AM, Yinghai Lu wrote:
> On Mon, Mar 18, 2013 at 3:21 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
>> For x86 PUD_SHIFT is 30 and PMD_SHIFT is 21, so the consequence of
>> (PUD_SHIFT-PMD_SHIFT)/2 is 4. Update the comments to the code.
>>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>> ---
>>  arch/x86/mm/init.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
>> index 59b7fc4..637a95b 100644
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -389,7 +389,7 @@ static unsigned long __init init_range_memory_mapping(
>>         return mapped_ram_size;
>>  }
>>
>> -/* (PUD_SHIFT-PMD_SHIFT)/2 */
>> +/* (PUD_SHIFT-PMD_SHIFT)/2+1 */
>>  #define STEP_SIZE_SHIFT 5
>>  void __init init_mem_mapping(void)
>>  {
> 
> 9/2=4.5, so it becomes 5.
> 

No, it doesn't.  This is C, not elementary school  Now I'm really bothered.

The comment doesn't say *why* (PUD_SHIFT-PMD_SHIFT)/2 or any other
variant is correct, furthermore I suspect that the +1 is misplaced.
However, what is really needed is:

1. Someone needs to explain what the logic should be and why, and
2. replace the macro with a symbolic macro, not with a constant and a
   comment explaining, incorrectly, how that value was derived.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
