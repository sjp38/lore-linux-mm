Message-ID: <48E20F98.4010106@linux-foundation.org>
Date: Tue, 30 Sep 2008 06:38:00 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080929193500.470295078@quilx.com>	 <20080929193516.278278446@quilx.com> <1222756559.10002.23.camel@penberg-laptop>
In-Reply-To: <1222756559.10002.23.camel@penberg-laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:

>> +/*
>> + * Basic allocation unit. A bit map is created to track the use of each
>> + * UNIT_SIZE element in the cpu area.
>> + */
>> +#define UNIT_TYPE int
>> +#define UNIT_SIZE sizeof(UNIT_TYPE)
>> +
>> +int units;	/* Actual available units */
> 
> What is this thing? Otherwise looks good to me.

This is the number of units available from the cpu allocator. Its determined
on bootup and the bitmap is sized correspondingly.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
