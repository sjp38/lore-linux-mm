Date: Mon, 8 Nov 2004 11:35:13 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <226170000.1099843883@[10.10.2.4]>
Message-ID: <Pine.LNX.4.44.0411081134310.8589-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Nov 2004, Martin J. Bligh wrote:

> Doing ps or top is not unusual at all, and the sysadmins should be able
> to monitor their system in a reasonable way without crippling it, or
> even effecting it significantly.

I don't think there is a single system out there where
people throw performance monitoring out the window, in
the name of performance.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
