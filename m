Received: by zproxy.gmail.com with SMTP id 13so404820nzn
        for <linux-mm@kvack.org>; Thu, 12 May 2005 02:39:43 -0700 (PDT)
Message-ID: <b82a8917050512023938ce1f4d@mail.gmail.com>
Date: Thu, 12 May 2005 15:09:43 +0530
From: Niraj kumar <niraj17@gmail.com>
Reply-To: Niraj kumar <niraj17@gmail.com>
Subject: Re: NUMA aware slab allocator V2
In-Reply-To: <20050512000444.641f44a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <20050512000444.641f44a9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On 5/12/05, Andrew Morton <akpm@osdl.org> wrote:
> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > This patch allows kmalloc_node to be as fast as kmalloc by introducing
> >  node specific page lists for partial, free and full slabs.
> 
> This patch causes the ppc64 G5 to lock up fairly early in boot.  It's
> pretty much a default config:
> http://www.zip.com.au/~akpm/linux/patches/stuff/config-pmac
> 
> No serial port, no debug environment, but no useful-looking error messages
> either.  See http://www.zip.com.au/~akpm/linux/patches/stuff/dsc02516.jpg

The image shows that kernel comand line option "quiet" was used .
We can probably get some more info if  booted without "quiet" .

Niraj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
