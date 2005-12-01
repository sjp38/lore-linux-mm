Date: Thu, 1 Dec 2005 14:00:44 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Better pagecache statistics ?
Message-ID: <20051201160044.GB14499@dmt.cnet>
References: <1133377029.27824.90.camel@localhost.localdomain> <20051201152029.GA14499@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051201152029.GA14499@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 01, 2005 at 01:20:29PM -0200, Marcelo Tosatti wrote:
> 
> Hi Badari,
> 
> On Wed, Nov 30, 2005 at 10:57:09AM -0800, Badari Pulavarty wrote:
> > Hi,
> > 
> > Is there a effort/patches underway to provide better pagecache
> > statistics ? 
> > 
> > Basically, I am interested in finding detailed break out of
> > cached pages. ("Cached" in /proc/meminfo) 
> > 
> > Out of this "cached pages"
> > 
> > - How much is just file system cache (regular file data) ?
> > - How much is shared memory pages ?
> 
> You could do that from userspace probably, by doing some math 
> on all processes statistics versus global stats, but does not 
> seem very practical.

Actually, SysRQ-M reports "N pages shared".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
