Message-ID: <48D3D836.40306@linux-foundation.org>
Date: Fri, 19 Sep 2008 11:49:58 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080919145859.062069850@quilx.com> <20080919145929.158651064@quilx.com> <48D3D2EF.5090808@cosmosbay.com>
In-Reply-To: <48D3D2EF.5090808@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:

>> +    unsigned long start;
>> +    int units = size_to_units(size);
>> +    void *ptr;
>> +    int first;
>> +    unsigned long flags;
>> +
>> +    if (!size)
>> +        return ZERO_SIZE_PTR;
>> +
>> +    WARN_ON(align > PAGE_SIZE);
> 
> if (align < UNIT_SIZE)
>     align = UNIT_SIZE;

size_to_units() does round up:


/*
 * How many units are needed for an object of a given size
 */
static int size_to_units(unsigned long size)
{
        return DIV_ROUND_UP(size, UNIT_SIZE);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
