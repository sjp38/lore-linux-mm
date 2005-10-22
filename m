Message-ID: <435A81ED.4040505@colorfullife.com>
Date: Sat, 22 Oct 2005 20:16:13 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet> <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org> <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>The current worst case is 16k pagesize (IA64) and one cacheline sized 
>objects (128 bytes) (hmm.. could even be smaller if the arch does 
>overrride SLAB_HWCACHE_ALIGN) yielding a maximum of 128 entries per page. 
>
>  
>
What about biovec-1? On i386 and 2.6.13 from Fedora, it contains 226 
entries. And revoke_table contains 290 entries.

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
