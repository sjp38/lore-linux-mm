Date: Mon, 27 Aug 2007 13:00:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: uncached page allocator
In-Reply-To: <1187708165.6114.256.camel@twins>
Message-ID: <Pine.LNX.4.64.0708271258420.5457@schroedinger.engr.sgi.com>
References: <21d7e9970708191745h3b579f3bp72f138e089c624da@mail.gmail.com>
 <20070820094125.209e0811@the-village.bc.nu>
 <21d7e9970708202305h5128aa5cy847dafe033b00742@mail.gmail.com>
 <1187708165.6114.256.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, dri-devel <dri-devel@lists.sourceforge.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, jes@sgi.com
List-ID: <linux-mm.kvack.org>

There is an uncached allocator in IA64 arch code 
(linux/arch/ia64/kernel/uncached.c). Maybe having a look at 
that will help? Jes wrote it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
