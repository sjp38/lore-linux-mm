From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH] pagewalk: don't pte_unmap(NULL) in walk_pte_range()
References: <47FC95AD.1070907@tiscali.nl> <87zls3qhop.fsf@saeurebad.de>
Date: Thu, 10 Apr 2008 14:09:00 +0200
In-Reply-To: <87zls3qhop.fsf@saeurebad.de> (Johannes Weiner's message of "Wed\,
	09 Apr 2008 15\:30\:30 +0200")
Message-ID: <jer6dd9ajn.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Roel Kluin <12o3l@tiscali.nl>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@saeurebad.de> writes:

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

There is something fishy here.  If the loop ends because addr == end
then pte has been incremented past the pmd page for addr, no?

Andreas.

-- 
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstrasse 5, 90409 Nurnberg, Germany
PGP key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
