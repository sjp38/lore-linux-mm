Message-ID: <20021223012106.10392.qmail@web12301.mail.yahoo.com>
Date: Sun, 22 Dec 2002 17:21:06 -0800 (PST)
From: Ravi <kravi26@yahoo.com>
Subject: Re: copy_from_user
In-Reply-To: <1040513191.2250.79.camel@amol.in.ishoni.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Amol Kumar Lad <amolk@ishoni.com> wrote:

>   Suppose kernel tries to do copy_from_user from a pointer
> that does not have any mapping. i.e. not in any VMA (and not
in
>  stack area too..). 
> Now (for 1386)
> access_ok --> __range_ok
> Suppose the 'from' ptr is within range then how kernel is
> making sure that 'from' is invalid ??
> The page fault handler will see that 'from' has no mapping and
> it will die.. 
 
I believe this is handled using the 'fixup' code in
__copy_user_zeroing().
I don't understand the code well though, but I do know that it
works :)

-Ravi.

__________________________________________________
Do you Yahoo!?
Yahoo! Mail Plus - Powerful. Affordable. Sign up now.
http://mailplus.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
