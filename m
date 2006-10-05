From: Andi Kleen <ak@suse.de>
Subject: Re: Free memory level in 2.6.16?
Date: Thu, 5 Oct 2006 22:17:38 +0200
References: <1160034527.23009.7.camel@localhost> <p73k63ezg3y.fsf@verdi.suse.de> <1160079029.29452.19.camel@localhost>
In-Reply-To: <1160079029.29452.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610052217.38345.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Bergman <sbergman@rueb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Thank you for the reply, Andi.  This kernel is compiled with the .config
> from the original FC5 release, which used kernel 2.6.15.  I just ran
> "make oldconfig" on it and accepted the defaults.

I meant in the source. There are no tunables for this in
.config
 
> So it is, I believe, a 4GB/4GB split.  Does that make a difference?

The kernel.org kernel doesn't support 4/4 split.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
