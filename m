Received: from mail1.socomm.net (root@mail1.socomm.net [207.15.160.25])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA15844
	for <linux-mm@kvack.org>; Fri, 18 Sep 1998 16:00:52 -0400
From: estafford@ixl.com
Received: from laugermill.ixlmemphis.net (root@ws-89.ixlmemphis.net [208.24.189.89])
	by mail1.socomm.net (8.8.8/8.8.8) with ESMTP id OAA27090
	for <linux-mm@kvack.org>; Fri, 18 Sep 1998 14:59:42 -0500
Message-ID: <XFMail.980918150525.estafford@ixl.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <19980904002057.A5268@ds23-ca-us.dialup>
Date: Fri, 18 Sep 1998 15:05:25 -0500 (CDT)
Subject: RE: [Q] MMU & VM
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I was compiling the 2.1.122 kernel on an Alpha box (LX164) and had this error
pop up.  Sounds like something you guys might recognize:

page_alloc.c: In function `__free_page':
page_alloc.c:169: internal error--unrecognizable insn:
(jump_insn 274 270 275 (return) -1 (nil)
    (nil))
gcc: Internal compiler error: program cc1 got fatal signal 6
make[2]: *** [page_alloc.o] Error 1
make[1]: *** [first_rule] Error 2
make: *** [_dir_mm] Error 2
{standard input}: Assembler messages:
{standard input}:178: Warning: Missing .end or .bend at end of file
cpp: output pipe has been closed

If you need more info, please just say the word.  Thanks!

----------------------------------
Ed Stafford
iXL Hosting Programming Engineer
E-Mail: estafford@ixl.com
----------------------------------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
