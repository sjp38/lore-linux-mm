Subject: Re: copy_from_user
From: Amol Kumar Lad <amolk@ishoni.com>
In-Reply-To: <20021223012106.10392.qmail@web12301.mail.yahoo.com>
References: <20021223012106.10392.qmail@web12301.mail.yahoo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Dec 2002 10:02:18 -0500
Message-Id: <1040655739.4986.86.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi <kravi26@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

yeah..u are right... how stupid of me... I should have read whole
function... I thought..aceess_ok should make such check...

thanks
Amol


On Sun, 2002-12-22 at 20:21, Ravi wrote:
> 
> --- Amol Kumar Lad <amolk@ishoni.com> wrote:
> 
> >   Suppose kernel tries to do copy_from_user from a pointer
> > that does not have any mapping. i.e. not in any VMA (and not
> in
> >  stack area too..). 
> > Now (for 1386)
> > access_ok --> __range_ok
> > Suppose the 'from' ptr is within range then how kernel is
> > making sure that 'from' is invalid ??
> > The page fault handler will see that 'from' has no mapping and
> > it will die.. 
>  
> I believe this is handled using the 'fixup' code in
> __copy_user_zeroing().
> I don't understand the code well though, but I do know that it
> works :)
> 
> -Ravi.
> 
> __________________________________________________
> Do you Yahoo!?
> Yahoo! Mail Plus - Powerful. Affordable. Sign up now.
> http://mailplus.yahoo.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
