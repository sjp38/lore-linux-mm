Date: Fri, 17 Oct 2003 14:42:34 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: 2.6.0-test7-mm1 4G/4G hanging at boot
In-Reply-To: <20031017111955.439d01c8.rddunlap@osdl.org>
Message-ID: <Pine.LNX.4.44.0310171441530.3108-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, mingo@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2003, Randy.Dunlap wrote:

> then I wait for 1-2 minutes and hit the power button.
> This is on an IBM dual-proc P4 (non-HT) with 1 GB of RAM.
> 
> Has anyone else seen this?  Suggestions or fixes?

Chances are the 8kB stack window isn't 8kB aligned in the
fixmap area, because of other patches interfering.  Try
adding a dummy fixmap page to even things out.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
