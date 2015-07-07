Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0F36B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 18:51:49 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so144232621ieb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 15:51:49 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id u3si760087igh.52.2015.07.07.15.51.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 15:51:48 -0700 (PDT)
Received: by igrv9 with SMTP id v9so153123349igr.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 15:51:48 -0700 (PDT)
Message-ID: <559C5803.50007@gmail.com>
Date: Tue, 07 Jul 2015 18:51:47 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Change unlabeled block of code to a else block in
 the function dma_pool_free
References: <1436225431-5880-1-git-send-email-xerofoify@gmail.com> <20150707154106.cd2f4e024a11c02993f02298@linux-foundation.org>
In-Reply-To: <20150707154106.cd2f4e024a11c02993f02298@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: khalasa@piap.pl, bigeasy@linutronix.de, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2015-07-07 06:41 PM, Andrew Morton wrote:
> On Mon,  6 Jul 2015 19:30:31 -0400 Nicholas Krause <xerofoify@gmail.com> wrote:
> 
>> This fixes the unlabeled block of code after the if statement that
>> executes if the passed dma variable of type dma_addr_t minus the
>> structure pointer page's dma member is equal to the variable offset
>> into a else block as this block should run when the if statement check
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  mm/dmapool.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/dmapool.c b/mm/dmapool.c
>> index fd5fe43..ce7ff4b 100644
>> --- a/mm/dmapool.c
>> +++ b/mm/dmapool.c
>> @@ -434,8 +434,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
>>  			       "dma_pool_free %s, %p (bad vaddr)/%Lx\n",
>>  			       pool->name, vaddr, (unsigned long long)dma);
>>  		return;
>> -	}
>> -	{
>> +	} else {
>>  		unsigned int chain = page->offset;
>>  		while (chain < pool->allocation) {
>>  			if (chain != offset) {
> 
> This patch has no effect?
> 
It's a cleanup as clearly people didn't make this into a if/else statement block as clearly this 
needs to run if the if statement fails and making into a else block makes this easier to understand
them a unnamed block. If you prefer we can just remove the brackets creating this block otherwise
that's my reasoning.
Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
