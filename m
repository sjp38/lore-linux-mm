Date: Tue, 25 Sep 2001 11:59:14 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Process not given >890MB on a 4MB machine ?????????
Message-ID: <20010925115914.F3437@redhat.com>
References: <5D2F375D116BD111844C00609763076E050D1680@exch-staff1.ul.ie> <3BAFA2CA.FAA0D9CB@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BAFA2CA.FAA0D9CB@earthlink.net>; from jknapka@earthlink.net on Mon, Sep 24, 2001 at 09:16:58PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joseph A Knapka <jknapka@earthlink.net>
Cc: "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 24, 2001 at 09:16:58PM +0000, Joseph A Knapka wrote:

> No. You still only get a maximum of 4GB of -virtual- space per
> process. The machine can address up to 64GB of -physical- RAM,
> but a single process (actually a single page directory) can
> see only 4GB at a time. Sorry :-(

There are hacks to work around this --- for example, you can set up
large amounts of shared memory and map that on demand when you are
looking up your dataset.  However, it's simply not possible for user
space to refer to more than 3GB at once on Linux/Intel.  You *must* go
to a 64-bit architecture if you want more than that.

Cheers,
 Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
