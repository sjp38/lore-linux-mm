Date: Mon, 9 Oct 2006 18:45:02 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page alloc minor cleanups
Message-Id: <20061009184502.27e515c9.pj@sgi.com>
In-Reply-To: <20061009132404.e6f8522d.pj@sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<452A4A9D.40605@yahoo.com.au>
	<20061009132404.e6f8522d.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, akpm@osdl.org, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

pj wrote:
> The check is not needed right there.  If we have an empty zonelist, then
> that just makes the zonelist scanning go all the faster ;).  Harmless,
> silly, but rare.

I should read the code before spouting off ... ;).

The get_page_from_freelist() code assumes in many places that there
is at least one zone in the zonelist.  It will barf all over the
place if zonelist->zones[0] is not a valid pointer.

Either this check for an empty zonelist at the top of __alloc_pages()
stays, or it becomes some kind of BUG() or someone more confident than
I removes it.

I'll be sending a patch to restore that check for an empty zonelist,
shortly.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
