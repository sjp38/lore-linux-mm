From: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Message-Id: <200001070125.UAA06650@jupiter.cs.uml.edu>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3? (resendingbecause my
Date: Thu, 6 Jan 2000 20:25:38 -0500 (EST)
In-Reply-To: <3874538A.67D675D6@idiom.com> from "Hans Reiser" at Jan 06, 2000 11:34:18 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <reiser@idiom.com>
Cc: "Peter J. Braam" <braam@cs.cmu.edu>, Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>

Hans Reiser writes:

> Yes, but not before 2.5.  Chris and I have already discussed that
> it would be nice to make the transaction API available to user space,
> but we haven't done any work on it, or even specified the user API.

AIX has such an API already. It is good to clone if you can.

This ought to contain the API, but might require some digging:
http://www.rs6000.ibm.com/support/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
