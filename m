Message-ID: <4019C729.8050505@cyberone.com.au>
Date: Fri, 30 Jan 2004 13:53:29 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [BENCHMARKS] 2.6 kbuild results (with add_to_swap patch)
References: <16407.59031.17836.961587@laputa.namesys.com> <20040128134425.0c00fb2f.akpm@osdl.org>
In-Reply-To: <20040128134425.0c00fb2f.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nikita Danilov <Nikita@Namesys.COM> wrote:
>
>>Hello,
>>
>>shrink_list() checks PageSwapCache() before calling add_to_swap(), this
>>means that anonymous page that is going to be added to the swap right
>>now these checks return false and:
>>
>> (*) it will be unaccounted for in nr_mapped, and
>>
>> (*) it won't be written to the swap if gfp_flags include __GFP_IO but
>>     not __GFP_FS.
>>
>>(Both will happen only on the next round of scanning.)
>>
>
>OK.  Does it make a measurable change in any benchmarks?
>
>

Small big significantly better on kbuild when tested on top of the other
two patches (dont-rotate-active-list and my mapped-fair).

With this patch as well, we are now as good or better than 2.4 on
medium and heavy swapping kbuilds and much better than stock 2.6
with light swapping loads (not as good as 2.4 but close).

http://www.kerneltrap.org/~npiggin/vm/3/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
