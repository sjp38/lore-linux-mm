Date: Tue, 6 May 2003 16:39:07 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.69-mm1
Message-ID: <20030506110907.GB9875@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20030504231650.75881288.akpm@digeo.com> <20030505210151.GO8978@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030505210151.GO8978@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 05, 2003 at 09:09:34PM +0000, William Lee Irwin III wrote:
> On Sun, May 04, 2003 at 11:16:50PM -0700, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm1/
> > Various random fixups, cleanps and speedups.  Mainly a resync to 2.5.69.
> 
> fs/file_table.c: In function `fget_light':
> fs/file_table.c:209: warning: passing arg 1 of `_raw_read_lock' from incompatible pointer type

I should have merged with 2.5.69 before mailing my fget-speedup patch out. 
->file_lock has been changed to a spin_lock somewhere after 2.5.66. 

That brings me to the point - with the fget-speedup patch, we should
probably change ->file_lock back to an rwlock again. We now take this
lock only when fd table is shared and under such situation the rwlock
should help. Andrew, it that ok ?

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
