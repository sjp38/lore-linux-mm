Date: Tue, 24 Apr 2007 18:26:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
Message-Id: <20070424182609.16f32f50.akpm@linux-foundation.org>
In-Reply-To: <1177459170.1281.5.camel@dyn9047017100.beaverton.ibm.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
	<1177459170.1281.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007 16:59:29 -0700 Badari Pulavarty <pbadari@gmail.com> wrote:

> On Tue, 2007-04-24 at 13:06 -0700, Andrew Morton wrote:
> > An amd64 machine is crashing badly.
> > 
> > http://test.kernel.org/abat/84767/debug/console.log
> > 
> > VFS: Mounted root (ext3 filesystem) readonly.
> > Freeing unused kernel memory: 308k freed
> > INIT: version 2.86 booting
> > Bad page state in process 'init'
> > page:ffff81007e492628 flags:0x0100000000000000 mapping:0000000000000000 mapcount:0 count:1
> > Trying to fix it up, but a reboot is needed
> > Backtrace:
> > 
> > Call Trace:
> >  [<ffffffff80250d3c>] bad_page+0x74/0x10d
> >  [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
> ...
> > 
> > So free_pgd_range() is freeing a refcount=1 page.  Can anyone see what
> > might be causing this?  The quicklist code impacts this area more than
> > anything else..
> > 
> 
> Yep. quicklist patches are causing these.
> 
> making CONFIG_QUICKLIST=n didn't solve the problem. I had
> to back out all quicklist patches to make my machine boot.
> 

Great, thanks for working that out.  If people start reporting this I'll
drop 'em and do an -rc2, but things are awful quiet out there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
