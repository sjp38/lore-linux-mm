Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA16416
	for <linux-mm@kvack.org>; Fri, 18 Sep 1998 18:01:28 -0400
Subject: Re: [Q] MMU & VM
References: <XFMail.980918150525.estafford@ixl.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 19 Sep 1998 00:00:05 +0200
In-Reply-To: estafford@ixl.com's message of "Fri, 18 Sep 1998 15:05:25 -0500 (CDT)"
Message-ID: <87lnnhulne.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: estafford@ixl.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

estafford@ixl.com writes:

> I was compiling the 2.1.122 kernel on an Alpha box (LX164) and had this error
> pop up.  Sounds like something you guys might recognize:
> 
> page_alloc.c: In function `__free_page':
> page_alloc.c:169: internal error--unrecognizable insn:
> (jump_insn 274 270 275 (return) -1 (nil)
>     (nil))
> gcc: Internal compiler error: program cc1 got fatal signal 6
> make[2]: *** [page_alloc.o] Error 1
> make[1]: *** [first_rule] Error 2
> make: *** [_dir_mm] Error 2
> {standard input}: Assembler messages:
> {standard input}:178: Warning: Missing .end or .bend at end of file
> cpp: output pipe has been closed
> 
> If you need more info, please just say the word.  Thanks!
> 

Something like that has already been reported and it looks like older
egcs compilers have trouble with __builtin_return_address construct.

Either update your egcs, or #define __builtin_return_address(x) (0)

Hope it helps.
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
Unix Wizard: Someone who can type `cat > /vmunix` and get away with it!
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
