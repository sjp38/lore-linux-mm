Date: Wed, 4 Feb 2004 00:16:49 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: VM benchmarks
Message-ID: <20040203231649.GA30715@k3.hellgate.ch>
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org> <401D95C2.3080208@cyberone.com.au> <20040202165044.GA8156@k3.hellgate.ch> <401EDAA5.7020802@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <401EDAA5.7020802@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 03 Feb 2004 10:17:57 +1100, Nick Piggin wrote:
> I have 3 patches here http://www.kerneltrap.org/~npiggin/vm/
> that should apply in order. If you apply to the -mm tree, please
> back out the rss limit patch first.
> 
> If you can test them it would be good.

I added results for all 3 patches of yours combined (2.6.1 patched)
and for the reversal patch I posted (2.6.0 revert). Clear improvements
for compiling. Might be interesting to test the patches individually,
but I will likely be unable to conduct further tests til next week. Let
me know if there are any tests you are specifically interested in,
and I will do more testing when I get back.

Roger

kbuild (make -j 24, 64 MB system)
		avg
2.4.21		120     101  107  110  112  114  116  128  134  135  143
2.4.23		140.4   116  118  124  125  132  150  153  157  161  168
2.4.25-pre6	161.8   141  145  148  153  155  156  169  173  185  193
pre6-rmap15l	441.8   274  383  387  439  462  464  468  492  500  549
2.6.0		513     387  446  493  498  512  512  546  550  592  594
2.6.1 patched	351.6   304  312  334  345  349  357  359  361  392  403
2.6.0 revert	441     375  408  409  425  429  437  454  461  487  525

efax (one large compile process, 32 MB system)
		avg
2.4.21		237.5   234  234  235  236  238  238  238  239  240  243
2.4.23		228.8   227  227  228  229  229  229  229  230  230  230
2.4.25-pre6	229.2   227  228  228  228  229  229  229  230  230  234
pre6-rmap15l	362.7   350  360  362  363  364  364  364  364  367  369
2.6.0		842.9   805  816  833  837  842  842  843  864  871  876
2.6.1 patched	508.3   477  501  511  511  512  513  513  513  516  516
2.6.0 revert	587.7   534  542  545  547  551  570  607  645  646  690

qsbench (-p 4 -m 96, 256 MB system)
		avg
2.4.21		222.3   214  217  218  218  219  219  222  229  231  236
2.4.21		221.1   214  216  216  218  219  220  223  224  229  232
2.4.23		223.8   219  220  221  223  223  223  223  225  230  231
2.4.25-pre6	217.2   208  209  210  212  213  213  223  224  226  234
pre6-rmap15l	1261.3 1171 1241 1253 1254 1268 1272 1274 1288 1293 1299
2.6.0		329.3   253  279  281  286  300  355  371  374  388  406
2.6.1 patched	336.8   272  275  277  301  304  375  376  383  383  422
2.6.0 revert	340     302  310  310  315  323  331  352  354  389  414
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
