From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14453.53221.477571.996579@dukat.scot.redhat.com>
Date: Fri, 7 Jan 2000 11:37:09 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3? (resendingbecause my
In-Reply-To: <200001070125.UAA06650@jupiter.cs.uml.edu>
References: <3874538A.67D675D6@idiom.com>
	<200001070125.UAA06650@jupiter.cs.uml.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Cc: Hans Reiser <reiser@idiom.com>, "Peter J. Braam" <braam@cs.cmu.edu>, Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 6 Jan 2000 20:25:38 -0500 (EST), "Albert D. Cahalan"
<acahalan@cs.uml.edu> said:

> AIX has such an API already. It is good to clone if you can.

The AIX API is much more than a simple small-operation atomic
transaction API, isn't it?  The filesystem transactions have many
properties --- no abort, predictable size, short duration --- which make
a journaling engine inappropriate for use in a general purpose
user-visible transaction API.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
