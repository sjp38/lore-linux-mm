Message-ID: <4791052C.3090507@sgi.com>
Date: Fri, 18 Jan 2008 11:59:40 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86: Change size of node ids from u8 to u16 fixup
References: <20080118183011.354965000@sgi.com> <20080118183011.527888000@sgi.com> <Pine.LNX.4.64.0801182055190.15604@fbirervta.pbzchgretzou.qr>
In-Reply-To: <Pine.LNX.4.64.0801182055190.15604@fbirervta.pbzchgretzou.qr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

Jan Engelhardt wrote:
> On Jan 18 2008 10:30, travis@sgi.com wrote:
>> --- a/include/linux/numa.h
>> +++ b/include/linux/numa.h
>> @@ -10,4 +10,10 @@
>>
>> #define MAX_NUMNODES    (1 << NODES_SHIFT)
>>
>> +#if MAX_NUMNODES > 256
>> +typedef u16 numanode_t;
>> +#else
>> +typedef u8 numanode_t;
>> +#endif
>> +
> 
> Do we really need numanode_t in userspace? I'd rather not, especially
> when its type is dependent on MAX_NUMNODES. Wrap with #ifdef __KERNEL__.


Will do, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
