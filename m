Date: Mon, 27 Aug 2001 16:05:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: can i call copy_to_user with interrupts masked
Message-ID: <20010827160532.H5970@redhat.com>
References: <20010827145640.79597.qmail@web14201.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010827145640.79597.qmail@web14201.mail.yahoo.com>; from pras_chakra@yahoo.com on Mon, Aug 27, 2001 at 07:56:40AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>
Cc: linux-mm@kvack.org, arund@bellatlantic.net
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Aug 27, 2001 at 07:56:40AM -0700, PRASENJIT CHAKRABORTY wrote:

>      This is in continuation with my previous mail.
> While debugging I've noticed that __copy_to_user()
> fails when I stop the Bottom Half before the call to
> __copy_to_user(), so if the page in not currently
> mapped then it forbids do_page_fault() to get invoked
> and hence the failure.

You're doing copy_to_user from a bottom half??????  You cannot do
that.  *Ever*.  It's illegal to take page faults from an interrupt of
any sort.

Cheers,
 STephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
