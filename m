Message-ID: <01dc01c56910$4788ad60$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Date: Sat, 4 Jun 2005 15:18:16 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King:
>
> I'm not sure what happened with this, but there's someone reporting that
> -rc5-mm1 doesn't work.  Unfortunately, there's not a lot to go on:
>
> http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2005-May/029188.html
>
> Could be unrelated for all I know.

I've just tried 2.6.12-rc5-mm2 on the Zaurus (arm pxa) and its "not happy". 
I'm seeing segfaults as it boots, particularly around udev and hotplug 
initilisation but in other places as well. Over three different bootups, I 
saw the segfaults move around to different scripts so something fundamental 
is wrong. On the last attempt, it looked up solid and failed to boot. No 
oops or any interesting debug information.

I'll roll back to 2.6.12-rc5-mm1 and see how that works next. I guess I'll 
just have to start a binary search after that (again :-/) unless anyone has 
any ideas of what changed that might cause this?

(2.6.12-rc4-mm2 and 2.6.12-rc5 are known good)

Richard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
