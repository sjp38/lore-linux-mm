Date: Thu, 22 Dec 2005 09:14:03 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Possible cure for memory fragmentation.
In-Reply-To: <43AAC5EA.3090800@superbug.demon.co.uk>
Message-ID: <Pine.LNX.4.62.0512220908120.7717@schroedinger.engr.sgi.com>
References: <43A9409D.1010904@superbug.demon.co.uk>
 <Pine.LNX.4.62.0512211058350.2455@schroedinger.engr.sgi.com>
 <43AAC5EA.3090800@superbug.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Courtier-Dutton <James@superbug.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Dec 2005, James Courtier-Dutton wrote:

> The driver does not call kremalloc with a different size. It calls it with the
> SAME size. Then if the kernel thinks it would benefit from moving the

Umm. When would the kernel do something like that? 
Also give it different name. realloc has pretty well established 
semantics.

> If the kernel does not wish to move it, kremalloc returns without having done
> anything.

What this all comes down to is to guarantee that only a known number of 
references exist to the data element when you move it. For kremalloc these
references must be known and all the pointers to the data element must be 
updated if the data is moved. The basic problem is not solved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
