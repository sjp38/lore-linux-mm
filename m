Date: Tue, 10 Oct 2000 20:09:52 +1100
From: john slee <indigoid@higherplane.net>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010200952.A661@higherplane.net>
References: <Pine.LNX.4.21.0010092336230.9803-100000@elte.hu> <Pine.LNX.4.21.0010091833280.1562-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091833280.1562-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 09, 2000 at 06:34:29PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 06:34:29PM -0300, Rik van Riel wrote:
> On Mon, 9 Oct 2000, Ingo Molnar wrote:
> > On Mon, 9 Oct 2000, Rik van Riel wrote:
> > 
> > > Would this complexity /really/ be worth it for the twice-yearly OOM
> > > situation?
> > 
> > the only reason i suggested this was the init=/bin/bash, 4MB
> > RAM, no swap emergency-bootup case. We must not kill init in
> > that case - if the current code doesnt then great and none of
> > this is needed.

perhaps a boot time option oom=0 ?  since oom is such a rare case, this
wouldn't impact normal usage...

-- 
john slee <indigoid@higherplane.net>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
