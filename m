Message-ID: <39E29B4D.C365FD12@kalifornia.com>
Date: Mon, 09 Oct 2000 21:30:05 -0700
From: David Ford <david@kalifornia.com>
Reply-To: david+validemail@kalifornia.com
MIME-Version: 1.0
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
References: <200010100422.e9A4Mg722840@webber.adilger.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@turbolinux.com>
Cc: Rik van Riel <riel@conectiva.com.br>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, jg@pa.dec.com, Gerrit.Huizenga@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andreas Dilger wrote:

> Albert D. Cahalan wrote:
> > X, and any other big friendly processes, could participate in
> > memory balancing operations. X could be made to clean out a
>
> Gerrit Huizenga wrote:
> > Anyway, there is/was an API in PTX to say (either from in-kernel or through
> > some user machinations) "I Am a System Process".  Turns on a bit in the
>
> On AIX there is a signal called SIGDANGER, which is basically what you
> are looking for.  By default it is ignored, but for processes that care
> (e.g. init, X, whatever) they can register a SIGDANGER handler.  At an
> "urgent" (as oposed to "critical") OOM situation, all processes get a
> SIGDANGER sent to them.  Most will ignore it, but ones with handlers
> can free caches, try to do a clean shutdown, whatever.  Any process with
> a SIGDANGER handler get a reduction of "badness" (as the OOM killer calls
> it) when looking for processes to kill.
>
> Having a SIGDANGER handler is good for 2 reasons:
> 1) Lets processes know when memory is short so they can free needless cache.
> 2) Mark process with a SIGDANGER handler as "more important" than those
>    without.  Most people won't care about this, but init, and X, and
>    long-running simulations might.

Is there any reason why we can't do something like this for 2.5?

-d

--
      "There is a natural aristocracy among men. The grounds of this are
      virtue and talents", Thomas Jefferson [1742-1826], 3rd US President



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
