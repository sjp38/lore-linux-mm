Message-ID: <40226C49.4010307@cyberone.com.au>
Date: Fri, 06 Feb 2004 03:16:09 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat"
References: <20040205014405.5a2cf529.akpm@osdl.org> <40222D4B.6050608@cyberone.com.au> <68430000.1075997516@[10.10.2.4]>
In-Reply-To: <68430000.1075997516@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Martin J. Bligh wrote:

>--Nick Piggin <piggin@cyberone.com.au> wrote (on Thursday, February 05, 2004 22:47:23 +1100):
>
>
>>Andrew Morton wrote:
>>
>>
>>>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2/2.6.2-mm1/
>>>
>>>
>>>- Merged some page reclaim fixes from Nick and Nikita.  These yield some
>>> performance improvements in low memory and heavy paging situations.
>>>
>>>
>>>
>>Nikita's vm-dont-rotate-active-list.patch still has this:
>>
>>+/* dummy pages used to scan active lists */
>>+static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
>>+
>>
>>Which probably needs its nodes and cachelines untangled.
>>Maybe it doesn't - I really don't know.
>>
>
>The idle toad's way is to shove it in the pgdat.
>Maybe even the zone structure?
>
>

It logically belongs in the zone structure, but apparently
dependancies will not allow that right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
