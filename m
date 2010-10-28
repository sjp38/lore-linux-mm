Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 25D278D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 13:13:05 -0400 (EDT)
Subject: Re: [PATCH] parisc: fix compile failure with kmap_atomic changes
Date: Thu, 28 Oct 2010 13:13:01 -0400 (EDT)
From: "John David Anglin" <dave@hiauly1.hia.nrc.ca>
In-Reply-To: <1288274629.3043.1.camel@mulgrave.site> from "James Bottomley" at Oct 28, 2010 09:03:49 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20101028171302.5D8944CFC@hiauly1.hia.nrc.ca>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-parisc@vger.kernel.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-10-28 at 01:18 -0400, John David Anglin wrote:
> > Signed-off-by: John David Anglin  <dave.anglin@nrc-cnrc.gc.ca>
> > 
> > Sent effectively the same change to parisc-linux list months ago...
> 
> You did?  Why didn't you send it to Peter?  When I grumbled at him on
> IRC for breaking parisc (as well as quite a few other 64 bit
> architectures in mainline) he had no idea there was a problem.

For example, it is in the diff recently posted here:
http://permalink.gmane.org/gmane.linux.ports.parisc/3173
This diff is from last May.

I wasn't aware of the compilation issue or the IRC discussion.  I
had noticed the problem by looking at the generic code.

Dave
-- 
J. David Anglin                                  dave.anglin@nrc-cnrc.gc.ca
National Research Council of Canada              (613) 990-0752 (FAX: 952-6602)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
