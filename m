Received: from castle.nmd.msu.ru (castle.nmd.msu.ru [193.232.112.53])
	by kvack.org (8.8.7/8.8.7) with SMTP id CAA30657
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 02:41:56 -0400
Message-ID: <19980818103326.A9815@castle.nmd.msu.ru>
Date: Tue, 18 Aug 1998 10:33:26 +0400
From: Savochkin Andrey Vladimirovich <saw@msu.ru>
Subject: Re: [PATCH] OOM killer
References: <Pine.LNX.3.96.980816182759.697A-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.980816182759.697A-100000@mirkwood.dummy.home>; from "Rik van Riel" on Sun, Aug 16, 1998 at 06:34:32PM
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Claus Fischer <cfischer@td2cad.intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 16, 1998 at 06:34:32PM +0200, Rik van Riel wrote:
> Hi,
> 
> here is the first patch that provides kernel-based out-of-memory
> killing.
> 
> It is only here to try if it works, I know it compiles but
> I haven't even booted it yet :)
> 
> Basically, when kswapd fails to free up pages, we're out of
> memory and the system would otherwise die, the added functions
> select a process to kill.
> 
> I don't know if it will always select the right process, nor
> if it even works correctly. All I do know is that the code
> is currently _VERY_ dirty and that it needs some major cleanups
> and sysctl tunables; right now I don't even dare sending Linus
> a cc: of this message :-)  [Linus, if you read this, don't
> read on unless you don't mind ROFLing]

Rik,

Don't you think that it would be much easier if we just implement
"kill priorities" which applications will set themselves?
Certainly, only a limited range of the priorities will be available
for non privileged applications. If people think that this application
is something special (like X or long standing computation programs
or anything else) they set a non default killing priority for the process.
Among other applications it isn't matter which one will be killed first.

Best wishes
					Andrey V.
					Savochkin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
