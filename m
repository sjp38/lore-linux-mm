Message-ID: <40C5D43F.4060601@ammasso.com>
Date: Tue, 08 Jun 2004 09:59:11 -0500
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: What happened to try_to_swap_out()?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Sorry for the newbie-like question, but I didn't know where else I 
should ask this question.

I'm porting our driver from 2.4 to 2.6, and during the development for 
2.4, one of the other software engineers discovered a possible bug in 
try_to_swap_out() in mm/vmscan.c.  I don't have all the details, but 
it's something about that function swapping out reserved pages, which I 
presume it shouldn't do.  Because of this bug, we had to implement a 
work-around in our driver.

Anyway, I'm trying to determine if that bug still exists in 2.6.  We'll 
run tests, of course, but I wanted to look at the code to see if the 
problem is still there.  Unfortunately, that function doesn't exist in 
2.6, and I can't figure out what it's replacement is.  Obviously, there 
is no single replacement function, but I was hoping someone could give 
me a quick rundown as to where that code went.

Also, I noticed that RedHat 9.0 doesn't have try_to_swap_out() either. 
I guess they ported some 2.6 code to 2.4.  Can anyone corroborate that?

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
