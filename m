Date: Wed, 22 Mar 2000 18:33:07 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322183307.B7271@pcep-jamie.cern.ch>
References: <20000321022937.B4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org> <20000322171045.D2850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322171045.D2850@redhat.com>; from Stephen C. Tweedie on Wed, Mar 22, 2000 at 05:10:45PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > function 3 (could be MADV_ZERO):
> >   discard pages.  if they are referenced again, the process sees C-O-W 
> >   zeroed pages.

Fwiw, I don't think MADV_ZERO is particularly useful.
You can just read /dev/zero over that memory range.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
