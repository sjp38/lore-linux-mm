Message-ID: <390704784.02057@ustc.edu.cn>
Date: Tue, 25 Sep 2007 15:19:41 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
Message-ID: <20070925071941.GC7862@mail.ustc.edu.cn>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org> <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost> <20070924213549.GJ19691@waste.org> <1190670636.26982.258.camel@localhost> <20070924220202.GK19691@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070924220202.GK19691@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 24, 2007 at 05:02:02PM -0500, Matt Mackall wrote:
> I think Fengguang is just thinking forward to the next logical step
> here which is "expose what's in the page cache". Which means being

I have been doing it for a long time - that's the filecache patch I
sent you. However it's not quite ready for a public review.

> able to go from page back to device:inode:offset or (better, but
> trickier) path:offset.

It's doing the other way around - a top-down way.

First, you get a table of all cached inodes with the following fields:
  device-number  inode-number  file-path  cached-page-count  status

Then, one can query any file he's interested in, and list all its
cached pages in the following format:
  index  length  page-flags  reference-count
(Sorry, it's the same format I have proposed in the pmaps interface.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
