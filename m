Message-ID: <20010825082047.67992.qmail@web14203.mail.yahoo.com>
Date: Sat, 25 Aug 2001 01:20:47 -0700 (PDT)
From: PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>
Subject: Re: copy_to_user problem
In-Reply-To: <20010824163807.94927.qmail@web14311.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>, PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>, linux-mm@kvack.org
Cc: arund@bellatlantic.net
List-ID: <linux-mm.kvack.org>

Yes I tried copy_to_user as well, but to no avail as
copy_to_user is basically a call to verify_area
followed by __copy_to_user.

--- Kanoj Sarcar <kanojsarcar@yahoo.com> wrote:
> Can you try copy_to_user(), and not
> __copy_to_user().
> 
> Kanoj
> 
> --- PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>
> wrote:
> > Hello All,
> > 
> >    I posted this problem some days back but still
> > have
> > not received any solution.
> > 
> > So sorry for the resend again.
> > 
> > I am developing a driver. Though the driver is
> > functioning well but I am stuck up at the point of
> > transferring something from kernel to user space.
> > 
> > I am using __copy_to_user() and before calling
> this
> > I
> > am checking the validity of user address with
> > verify_area().
> > 
> > Now the problem is that __copy_to_user() sometimes
> > return value > 0 which indicates a failure. This
> > happens everytime the user address is not
> currently
> > present in the Physical Page i.e the when
> > __copy_to_user tries to copy to a page which is
> not
> > currently paged in then it fails.
> > 
> > Moreover if I access the user buffer from my user
> > program before passing it to the kernel for
> transfer
> > then __copy_to_user performs it happily or if I
> lock
> > that page through mlock() system call. I read the
> > documentation but nowhere I found that I need to
> do
> > something before __copy_to_user().
> > 
> > The problem for the time being has been
> workarounded
> > by putting __verify_write() before __copy_to_user.
> > 
> > So I would like to know what is wrong with my
> > approach
> > or is it due to some other issue which is unknown
> to
> > me (e.g corruption etc).
> > 
> > I shall be grateful to you all if you kindly help
> me
> > out of this.
> > 
> > Thanks n Regards,
> > 
> > Prasenjit
> > 
> > 
> > 
> > 
> > 
> > __________________________________________________
> > Do You Yahoo!?
> > Make international calls for as low as $.04/minute
> > with Yahoo! Messenger
> > http://phonecard.yahoo.com/
> > --
> > To unsubscribe, send a message with 'unsubscribe
> > linux-mm' in
> > the body to majordomo@kvack.org.  For more info on
> > Linux MM,
> > see: http://www.linux-mm.org/
> 
> 
> __________________________________________________
> Do You Yahoo!?
> Make international calls for as low as $.04/minute
> with Yahoo! Messenger
> http://phonecard.yahoo.com/
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/


__________________________________________________
Do You Yahoo!?
Make international calls for as low as $.04/minute with Yahoo! Messenger
http://phonecard.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
