Message-ID: <478CD698.1090402@sgi.com>
Date: Tue, 15 Jan 2008 07:51:52 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] x86: Change size of node ids from u8 to u16 V2
References: <20080115021735.779102000@sgi.com> <20080115021736.236433000@sgi.com> <478C4BBD.9050707@cosmosbay.com>
In-Reply-To: <478C4BBD.9050707@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
>
>> --- a/include/asm-x86/mmzone_64.h
>> +++ b/include/asm-x86/mmzone_64.h
>> @@ -15,8 +15,8 @@
>>  struct memnode {
>>      int shift;
>>      unsigned int mapsize;
>> -    u8 *map;
>> -    u8 embedded_map[64-16];
>> +    u16 *map;
>> +    u16 embedded_map[64-16];
> 
> Must change to 32-8 here, or 64-8 and change the comment (total size =
> 128 bytes). If you change to 32-8, check how .map is set to embedded_map.
> 
>>  } ____cacheline_aligned; /* total size = 64 bytes */
>>  extern struct memnode memnode;
>>  #define memnode_shift memnode.shift

Thanks! 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
