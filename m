Subject: Re: [PATCH] struct page shrinkage
Message-ID: <OF8A6868F1.312B7C40-ON85256B74.005CB22E@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Wed, 6 Mar 2002 11:58:43 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


>Rik van Riel wrote:
>>
>> +               clear_bit(PG_locked, &p->flags);
>
>Please don't do this.  Please use the macros.  If they're not
>there, please create them.
>
>Bypassing the abstractions in this manner confounds people
>who are implementing global locked-page accounting.
>

Andrew,
I have an application which needs to know the total number of locked and
dirtied pages at any given time.  In which application locked-page
accounting is done?   I don't see it in base 2.5.5.   Are there any patches
or such that you can give pointers to?
Bulent


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
