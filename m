Date: Wed, 8 Sep 2004 19:22:11 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
In-Reply-To: <50520000.1094682042@flay>
Message-ID: <Pine.LNX.4.44.0409081920500.5466-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Diego Calleja <diegocg@teleline.es>, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2004, Martin J. Bligh wrote:

> Oh, I see what you mean. I think we're much better off sticking the
> mechanism for autotuning stuff in the kernel -

Agreed.  Autotuning like this appears to work best by having
a self adjusting algorithm, often negative feedback loops so
things get balanced out automagically.

Works way better than anything looking at indirect data and
then tweaking some magic knobs...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
