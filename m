Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	<14619.16278.813629.967654@charged.uio.no>
	<ytt1z38acqg.fsf@vexeta.dc.fi.udc.es> <391BEAED.C9313263@sympatico.ca>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: John Cavan's message of "Fri, 12 May 2000 07:28:45 -0400"
Date: 12 May 2000 13:37:55 +0200
Message-ID: <yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Cavan <john.cavan@sympatico.ca>
Cc: trond.myklebust@fys.uio.no, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "john" == John Cavan <john.cavan@sympatico.ca> writes:

Hi

john> I'm by no means an expert in this, I just follow the list to learn, but
john> would it not be possible to make ITERATIONS count a runtime configurable
john> parameter in the /proc filesystem that defaults to 100? That would allow
john> for the best tuning scenario for a given system.

This was a first approach patch, if people like the thing configurable,
I can try to do that the weekend.

Notice: that will be my first trip to /proc land....

The rest of the people think that that value would need to be tunable
(I am not strong about that, but I think that I would not need to be
tunable,  perhaps 100 is not the correct value, but I think that one
value that didn't put a lot of latency would be enough).

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
