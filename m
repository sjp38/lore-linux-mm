Date: Fri, 18 May 2001 20:19:24 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Linux 2.4.4-ac10
Message-ID: <20010518201924.M754@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.21.0105181403280.5531-100000@imladris.rielhome.conectiva> <Pine.LNX.4.33.0105181936240.583-100000@mikeg.weiden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0105181936240.583-100000@mikeg.weiden.de>; from mikeg@wen-online.de on Fri, May 18, 2001 at 07:45:15PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2001 at 07:45:15PM +0200, Mike Galbraith wrote:
> Yes, ~exactly!  I chose 30 tasks because they almost do (tool/userland
> dependant.. must recalibrate often) fit.  The bitch is to get the vm
> to automagically detect the rss/cache munch tradeoff point without all
> the manual help.

What about a sysctl for that? Choose decent steps and let 0
(which is an insane value) mean "let's kernel decide" and make
this default.

In the past we could do this by adjusting some watermarks in
/proc/sys/vm but now, we can't do anything but trust the genius
kernel developers.

I doubt that we can test all kinds of workload and even imagine
what pervert stuff some people do with their machines.

Tuning _is_ manual work. Always has been and always will be.

This countinously "I know it better then you" is what I hated
about Windows and now this comes more and more into Linux :-(

Rik: Would you take patches for such a tradeoff sysctl?

Regards

Ingo Oeser
-- 
To the systems programmer,
users and applications serve only to provide a test load.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
