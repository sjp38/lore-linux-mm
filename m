Message-ID: <4020392F.1000709@cyberone.com.au>
Date: Wed, 04 Feb 2004 11:13:35 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: VM benchmarks
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org> <401D95C2.3080208@cyberone.com.au> <20040202165044.GA8156@k3.hellgate.ch> <401EDAA5.7020802@cyberone.com.au> <20040203231649.GA30715@k3.hellgate.ch>
In-Reply-To: <20040203231649.GA30715@k3.hellgate.ch>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Roger Luethi wrote:

>On Tue, 03 Feb 2004 10:17:57 +1100, Nick Piggin wrote:
>
>>I have 3 patches here http://www.kerneltrap.org/~npiggin/vm/
>>that should apply in order. If you apply to the -mm tree, please
>>back out the rss limit patch first.
>>
>>If you can test them it would be good.
>>
>
>I added results for all 3 patches of yours combined (2.6.1 patched)
>and for the reversal patch I posted (2.6.0 revert). Clear improvements
>for compiling. Might be interesting to test the patches individually,
>but I will likely be unable to conduct further tests til next week. Let
>me know if there are any tests you are specifically interested in,
>and I will do more testing when I get back.
>
>

Thanks Roger,
Hmm results aren't bad... although the active/inactive balance
tuning you see here: http://www.kerneltrap.org/~npiggin/vm/4/
isn't included (you're testing the green kernel)

If I can get things a bit more into shape today I'll post another
patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
