Date: Wed, 13 Aug 2003 22:18:29 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.0-test3-mm1
Message-ID: <20030813201829.GA15012@mars.ravnborg.org>
References: <20030809203943.3b925a0e.akpm@osdl.org> <200308101941.33530.schlicht@uni-mannheim.de> <3F37DFDC.6080308@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F37DFDC.6080308@mvista.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: George Anzinger <george@mvista.com>
Cc: Thomas Schlichter <schlicht@uni-mannheim.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2003 at 11:26:36AM -0700, George Anzinger wrote:
> >that patch sets DEBUG_INFO to y by default, even if whether DEBUG_KERNEL 
> >nor KGDB is enabled. The attached patch changes this to enable DEBUG_INFO 
> >by default only if KGDB is enabled.
> 
> Looks good to me, but.... just what does this turn on?  Its been a 
> long time and me thinks a wee comment here would help me remember next 
> time.

DEBUG_INFO add "-g" to CFLAGS.
Main reason to introduce this was that many architectures always use
"-g", so a config option seemed more appropriate.
I do not agree that this should be dependent on KGDB.
To my knowledge -g is useful also without using kgdb.

	Sam
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
