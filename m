Date: Mon, 24 Sep 2007 16:35:49 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
Message-ID: <20070924213549.GJ19691@waste.org>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org> <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1190668988.26982.254.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 24, 2007 at 02:23:08PM -0700, Dave Hansen wrote:
> On Mon, 2007-09-24 at 15:59 -0500, Matt Mackall wrote:
> > 
> > If we really must do this, it'd be better to have a parallel file with
> > the offsets.
> 
> Yeah, I'd much rather have a couple of files with really, really simple
> and _stable_ formats than one with a more complex and variable one.  
> 
> Although you can't answer the "which parts are mapped" question without
> the page_index() information, you can answer the "what percentage of
> this file is actively mapped" question.
> 
> Could someone elaborate a little bit more on exactly why you'd want to
> know which parts of the file are mapped? 

Google codesearch finds one actual user of remap_file_pages (and
-lots- of false positives) in an obscure webserver, so I think the
answer somehow involves Oracle.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
