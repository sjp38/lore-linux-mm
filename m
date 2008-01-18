Date: Fri, 18 Jan 2008 10:28:39 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/6] mm: introduce pte_special pte bit
In-Reply-To: <20080118180431.GA19591@uranus.ravnborg.org>
Message-ID: <alpine.LFD.1.00.0801181026530.2957@woody.linux-foundation.org>
References: <20080118045649.334391000@suse.de> <20080118045755.516986000@suse.de> <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org> <20080118180431.GA19591@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 18 Jan 2008, Sam Ravnborg wrote:
> 
> One fundamental difference is that with the above syntax we always
> compile both versions of the code - so we do not end up with one
> version that builds and another version that dont.

Yes, in that sense it tends to be better to use C language constructs over 
preprocessor constructs, since error diagnostics and syntax checking is 
improved.

So yeah, I'll give you that it can be an improvement. It's just not what I 
was really hoping for.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
