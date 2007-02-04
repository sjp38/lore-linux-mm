Date: Sun, 4 Feb 2007 04:55:49 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/9] fs: libfs buffered write leak fix
Message-ID: <20070204035549.GA3502@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070129081914.23584.23886.sendpatchset@linux.site> <20070202155236.dae54aa2.akpm@linux-foundation.org> <20070203013316.GB27300@wotan.suse.de> <20070203174947.GA2656@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070203174947.GA2656@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@lazybastard.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 03, 2007 at 05:49:47PM +0000, Jorn Engel wrote:
> On Sat, 3 February 2007 02:33:16 +0100, Nick Piggin wrote:
> > 
> > If doing a partial-write, simply clear the whole page and set it uptodate
> > (don't need to get too tricky).
> 
> That sounds just like a bug I recently fixed in logfs.  prepare_write()
> would clear the page, commit_write() would write the whole page.  Bug
> can be reproduced with a simple testcate:
> 
> echo -n foo > foo
> echo -n bar >> foo
> cat foo
> 
> With the bug, the second write will replace "foo" with "\0\0\0" and
> cat will return "bar".  Doing a read instead of clearing the page will
> return "foobar", as would be expected.
> 
> Can you hit the same bug with your patch or did I miss something?

Yes, the page is only cleared if it is not uptodate. This is fine
for the simple filesystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
