Date: Mon, 3 Jul 2000 12:06:36 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: a joint letter on low latency and Linux
Message-ID: <20000703120636.B2931@redhat.com>
References: <200006301310.JAA06222@tsx-prime.MIT.EDU> <200006301506.LAA12457@renoir.op.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200006301506.LAA12457@renoir.op.net>; from pbd@Op.Net on Fri, Jun 30, 2000 at 11:03:08AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Barton-Davis <pbd@Op.Net>
Cc: "Theodore Y. Ts'o" <tytso@MIT.EDU>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 30, 2000 at 11:03:08AM -0400, Paul Barton-Davis wrote:

> Well, I'm sympathetic to this. But just yesterday, I saw Stephen
> Tweedie saying that the VM system needed another fairly significant
> redesign begore it could be considered ready for 2.4.0.

It needs some really careful thinking, and a small (though still
significant) amount of reworking of *highly* localised functions
before 2.4.  It also needs a complete overhaul, but that's a 2.5
issue.  For 2.4 the objective has to be minimum necessary change.  The
trouble is that 2.4 VM performance has sufficiently bad worst case
behaviour right now that some change is necessary --- the existing
behaviour is a serious bug needing fixed.

It is too late to change the VM mechanisms for 2.4, but the policy
code still needs a good, hard think, since we currently perform much
much worse than 2.2 at some jobs.

It IS too late to add features over and above what we already have in
the source tree.  That's why we've got a substantial wish-list of
experimental stuff to explore for the 2.5 VM in addition to the fixes
needed for 2.4.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
