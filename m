Date: Tue, 21 Oct 2003 21:42:25 +0100 (BST)
From: James Simmons <jsimmons@infradead.org>
Subject: Re: 2.6.0-test8-mm1
In-Reply-To: <200310212236.41476.schlicht@uni-mannheim.de>
Message-ID: <Pine.LNX.4.44.0310212141290.32738-100000@phoenix.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > This patch was fine.  2.6.0-test8 with this patch booted and
> > looked no different from plain 2.6.0-test8.  I am using it for
> > writing this.  The problems must be in mm1 somehow.
> >
> > Helge Hafting

Yeah!!!
 
> Well here I've got same problems for -test8 + fbdev-patch as with -test8-mm1. 
> I've compiled the kernel with most DEBUG_* options enabled (all but 
> DEBUG_INFO and KGDB) and see the same cursor and image corruption as with 
> -mm1 and the same options enabled.
> 
> Should I try compiling this kernel without the DEBUG_* options and watch if I 
> get the invalidate_list Oops again?

Yes. I'm using vesafb and I have no problems. I liek to see what the 
problem really is.
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
