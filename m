Date: Thu, 6 Mar 2008 13:50:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803062207.37654.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803061349220.15083@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <Pine.LNX.4.64.0803061151590.14140@schroedinger.engr.sgi.com>
 <200803062207.37654.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Jens Osterkamp wrote:

> I had earlier biesected this to the following commit, should have mentioned that,
> sorry !
> 
> commit f0630fff54a239efbbd89faf6a62da071ef1ff78
> Author: Christoph Lameter <clameter@sgi.com>
> Date:   Sun Jul 15 23:38:14 2007 -0700
> 
>     SLUB: support slub_debug on by default
> 
>     [...]

hehehe. So slub debug is off if you do not specify slub_debug on the 
commandline. No surprise there.

> I just tried the patch, but the problem is still there...

Duh. So this is also in 2.6.23 and 2.6.24?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
