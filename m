Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA12101
	for <linux-mm@kvack.org>; Sun, 8 Sep 2002 09:31:28 -0700 (PDT)
Message-ID: <3D7B7EC6.EFD38352@digeo.com>
Date: Sun, 08 Sep 2002 09:45:58 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm5
References: <3D7AF270.BE4AFBEB@digeo.com> <20020908151159.GA5260@prester.freenet.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Axel Siebenwirth <axel@hh59.org>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Axel Siebenwirth wrote:
> 
> Hi Andrew!
> 
> On Sat, 07 Sep 2002, Andrew Morton wrote:
> 
> > I'd appreciate it if people could grab this one, be nasty to it
> > and send a report.
> 
> What are your favorite tests to run? I'd like to send you some useful test
> results. But which do you like to see?

I've already run my favourite tests ;)  The value of external testing is
in the extra coverage which it gives - different hardware, different
tests.  And also different requirements: there may be things which I
think are cool, but which you think suck.

So... The real test is of course "daily use".  If it works OK in daily
use for you, and for everyone else then we ship 2.6.  By definition.

Of course, on top of daily use it is best to run additional stress
tests to find problems more quickly.  Large desktop applications, web
and file servers, databases, etc would be interesting.  CD burning,
funny old PIO-mode IDE drives, stress testing with gigabt NICs,
you name it.  Coverage.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
