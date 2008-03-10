Date: Mon, 10 Mar 2008 15:03:16 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080310150316.752e4489@mandriva.com.br>
In-Reply-To: <20080308004654.GQ7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
	<20080307175148.3a49d8d3@mandriva.com.br>
	<20080308004654.GQ7365@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Em Sat, 8 Mar 2008 01:46:54 +0100
Andi Kleen <andi@firstfloor.org> escreveu:

| >  I've tried to give them a try but got some problems. First, the
| > simple test case seems to fail miserably:
| 
| Hmm I guess you got a pretty filled up 16MB area already.
| Do you have a full log? It just couldn't allocate some memory
| for the 24bit mask, but that is likely because it just ran out of 
| memory.

 You'll find the full log here:

http://users.mandriva.com.br/~lcapitulino/tmp/minicom.cap

| I suppose it will work if you cut down the allocations in the 
| test case a bit, e.g. decrease NUMALLOC to 10 and perhaps MAX_LEN to
| 5*PAGE_SIZE. Did that in my copy.

[...]

| I put up an updated patchkit on ftp://firstfloor.org/pub/ak/mask/patches/
| It also has some other fixes.
| 
| Can you retest with that please?

 Yes, will do. But I have something to suggest.

 I saw that the patches you've posted here are only a subset of
the patches you have in your FTP. Should I test all the patches
you have or only the subset you posted?

 If you want to get only the subset tested, would be nice to
create a new directory in the FTP for them, that would make
my life easier a bit.

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
