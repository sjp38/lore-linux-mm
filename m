Subject: 2.6.0-test1-mm1 Couldn't "lock screen" after 2 days uptime.
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Message-Id: <1058562142.17692.13.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 18 Jul 2003 15:02:22 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's an odd one.

After running 2.6.0-test1-mm1 for two days, I tried to password protect
my KDE session with the "Lock Screen" command from the K button.  This
is something I do every time I walk away from my desk, security and all
that.  It always works, until now.  Selecting "Lock Screen", nothing
happened.  With several attempts, and waiting for several minutes, still
no locked screen.  The system was still very responsive otherwise.  

I logged off, logged back in again, and now "Lock Screen" works as
expected.  I've never seen this before.  I've run many different kernels
on this workstation and locked and unlocked the session many times per
day for the several months I've had Mandrake 9.1 installed here.  My
other workstation is Red Hat 9, but it's been busy doing other things
than testing kernels recently.

This may of course have nothing to do with 2.6.0-test1-mm1, but I
thought I'd mention it.  One more thing for folks to look out for.


Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
