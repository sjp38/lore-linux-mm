Date: Tue, 15 Feb 2005 20:28:42 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215202842.4976b7ff.pj@sgi.com>
In-Reply-To: <4212C63D.2050606@sgi.com>
References: <42128B25.9030206@sgi.com>
	<20050215165106.61fd4954.pj@sgi.com>
	<20050215171709.64b155ec.pj@sgi.com>
	<20050216020138.GC28354@lnx-holt.americas.sgi.com>
	<4212C63D.2050606@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: holt@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Ray wrote:
> Exactly why do we need to support the case where the set of old
> nodes and new nodes overlap? 

Actually, I think they can overlap, just so long as the set of old nodes
is not identical to the set of new nodes.  It's this "perfect shuffle,
in place" that can't be done without the infamous insane temporary node.

But that's likely beside the point, as I have already adequately
demonstrated that there is some requirement here that Robin knows and I
don't.  Yet, anyway.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
