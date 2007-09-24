Date: Mon, 24 Sep 2007 17:02:02 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
Message-ID: <20070924220202.GK19691@waste.org>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org> <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost> <20070924213549.GJ19691@waste.org> <1190670636.26982.258.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1190670636.26982.258.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 24, 2007 at 02:50:36PM -0700, Dave Hansen wrote:
> On Mon, 2007-09-24 at 16:35 -0500, Matt Mackall wrote:
> > On Mon, Sep 24, 2007 at 02:23:08PM -0700, Dave Hansen wrote:
> > > Could someone elaborate a little bit more on exactly why you'd want to
> > > know which parts of the file are mapped? 
> > 
> > Google codesearch finds one actual user of remap_file_pages (and
> > -lots- of false positives) in an obscure webserver, so I think the
> > answer somehow involves Oracle.
> 
> If you're asking yourself wtf Oracle is doing, I can see how this is
> helpful.  But, since Oracle has to maintain its own internal mappings of
> what it remapped, this shouldn't help Oracle itself.
> 
> In any case, even if you realize that Oracle is misusing
> (under-utilizing?) its remapped areas, what do you do?  You have to go
> dig into Oracle to find out what it was doing.  That is precisely what
> you would have had to do in the first place without this patch.  I don't
> quite get what this buys us. 

Indeed. In theory, you can do lots of interesting things with
remap_file_pages, but most of them translate into "kludge to get
around limited address space".

I think Fengguang is just thinking forward to the next logical step
here which is "expose what's in the page cache". Which means being
able to go from page back to device:inode:offset or (better, but
trickier) path:offset.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
