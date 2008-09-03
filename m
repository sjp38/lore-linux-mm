Date: Wed, 3 Sep 2008 14:01:40 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: Warning message when compiling ioremap.c
Message-ID: <20080903140140.333bc137@doriath.conectiva>
In-Reply-To: <48BCED2A.6030109@evidence.eu.com>
References: <48BCED2A.6030109@evidence.eu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Claudio Scordino <claudio@evidence.eu.com>
Cc: linux-mm@kvack.org, philb@gnu.org
List-ID: <linux-mm.kvack.org>

Em Tue, 02 Sep 2008 09:37:14 +0200
Claudio Scordino <claudio@evidence.eu.com> escreveu:

| Hi,
| 
|        I'm not skilled with MM at all, so sorry if I'm saying something
| stupid.
| 
| When compiling Linux (latest kernel from Linus' git) on ARM, I noticed 
| the following warning:
| 
| CC      arch/arm/mm/ioremap.o
| arch/arm/mm/ioremap.c: In function '__arm_ioremap_pfn':
| arch/arm/mm/ioremap.c:83: warning: control may reach end of non-void
| function 'remap_area_pte' being inlined
| 
| According to the message in the printk, we go to "bad" when the page
| already exists.

 You see that right before the return you have added there is a
BUG() macro? That macro will call panic(), this means that this
function will never return if it reaches that point.

 If all you want is to silent gcc, you should remove the goto and
move the bad label contents there.

 This is minor, but I see no need for the goto.

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
