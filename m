Subject: Re: 2.6.0-test8-mm1
From: Robert Love <rml@tech9.net>
In-Reply-To: <200310220053.13547.schlicht@uni-mannheim.de>
References: <Pine.LNX.4.44.0310212141290.32738-100000@phoenix.infradead.org>
	 <200310220053.13547.schlicht@uni-mannheim.de>
Content-Type: text/plain
Message-Id: <1066778844.768.348.camel@localhost>
Mime-Version: 1.0
Date: Tue, 21 Oct 2003 19:27:25 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: James Simmons <jsimmons@infradead.org>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-10-21 at 18:53, Thomas Schlichter wrote:

> For me the big question stays why enabling the DEBUG_* options results in a 
> corrupt cursor and the false dots on the top of each row... (with both 
> kernels)

Almost certainly due to CONFIG_DEBUG_SLAB or CONFIG_DEBUG_PAGEALLOC,
which debug memory allocations and frees.

Code that commits the usual memory bugs (use-after-free, etc.) will
quickly die with these set, whereas without them the bug might never
manifest.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
