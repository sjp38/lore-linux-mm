Date: Tue, 9 Sep 2008 07:59:27 -0700 (PDT)
From: David Anders <dave123_aml@yahoo.com>
Reply-To: dave123_aml@yahoo.com
Subject: Re: Remove warning in compilation of ioremap
In-Reply-To: <20080909135532.GE8894@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <157617.9043.qm@web54404.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.arm.linux.org.uk, Claudio Scordino <claudio@evidence.eu.com>, linux-mm@kvack.org, Phil Blundell <philb@gnu.org>, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
List-ID: <linux-mm.kvack.org>

Russell,

> > i hope you have a better time getting this fixed than
> i have,
> > i've been submitting patches as far back as
> 2.6.16:
> > 
> >
> http://lists.arm.linux.org.uk/lurker/message/20070906.135142.6c5e4d6f.en.html
> >
> http://lists.arm.linux.org.uk/lurker/message/20070906.140649.79f143a0.en.html
> > 
> > 2.6.23 was when i gave up.
> 
> It's not like you were ignored, both of those messages
> contain replies
> from Erik Mouw, both of which were positive.
> 
> Unfortunately, I didn't see it as a high priority so it
> got left a little
> too long and I never got around to commenting about it (I
> thought it was
> a complex way of fixing what was a trivial problem.)
> 

water under the bridge, just happy it got fixed.

> Take a look at the difference between yours:
> 
> 
> http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=4563/1
> 
> Comapred with the one which has been merged:
> 
> 
> http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=5211/2
> 
> Sorry.

agreed there are differences between what got accepted and what i submited. however, i did not randomly choose the code used in that define. i went back to the mailing lists for x86,powerpc, parisc, mips and sh. the code format of BUG() had been discussed on each of these lists, with x86, powerpc, and parisc using the exact same code format as i submitted, with mips and sh using one almost identical.

from include/asm-x86/bug.h

#define BUG()				\
	do {				\
		asm volatile("ud2");	\
		for(;;) ;		\
	} while(0)

what i submited:

+#define BUG()				\
+	do {				\
+		(*(int *)0 = 0);	\
+		for(;;) ;		\
+	} while(0)

i apologize if this is a rant, no disrespect for your work or the pressure you are under to maintain LAK, but shall we always wait until there is a 100% elegant solution to a known issue before fixing it?

Dave Anders






      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
