Message-ID: <47FDFD3C.1030708@tiscali.nl>
Date: Thu, 10 Apr 2008 13:42:52 +0200
From: Roel Kluin <12o3l@tiscali.nl>
MIME-Version: 1.0
Subject: Re: [PATCH] pagewalk: don't pte_unmap(NULL) in walk_pte_range()
References: <47FC95AD.1070907@tiscali.nl> <87zls3qhop.fsf@saeurebad.de>
In-Reply-To: <87zls3qhop.fsf@saeurebad.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> Hi,
> 
> Roel Kluin <12o3l@tiscali.nl> writes:
> 
>> This is right isn't it?
>> ---
>> Don't pte_unmap a NULL pointer, but the previous.
> 
> Which NULL pointer?
> 
>> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
>> ---
>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>> index 1cf1417..6615f0b 100644
>> --- a/mm/pagewalk.c
>> +++ b/mm/pagewalk.c
>> @@ -15,7 +15,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>  		       break;
>>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>>  
>> -	pte_unmap(pte);
>> +	pte_unmap(pte - 1);
>>  	return err;
>>  }
> 
> This does not make any sense to me.

you are right, please ignore.

> 	Hannes

thanks,

Roel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
