Subject: Re: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D627740.E8C0FDC3@zip.com.au>
References: <1029794688.14756.353.camel@spc9.esa.lanl.gov>
	<1029850784.2045.363.camel@spc9.esa.lanl.gov>
	<3D627740.E8C0FDC3@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Aug 2002 11:17:48 -0600
Message-Id: <1029863868.14756.376.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 2002-08-20 at 11:07, Andrew Morton wrote:

> > ...
> > >>EIP; c0132733 <__free_pages_ok+93/310>   <=====
> > Trace; c013315a <__pagevec_free+1a/20>
> > Trace; c0131059 <__pagevec_release+f9/110>
> > Trace; c0173df6 <journal_unmap_buffer+106/190>
> > Trace; c013e3db <wake_up_buffer+b/30>
> > Trace; c012a32f <remove_from_page_cache+2f/40>
> > Trace; c012a783 <truncate_list_pages+2b3/350>
> > Trace; c016c6a9 <ext3_do_update_inode+2c9/350>
> > Trace; c016c701 <ext3_do_update_inode+321/350>
> > Trace; c012a90d <truncate_inode_pages+8d/d0>
> > Trace; c015242d <generic_delete_inode+5d/140>
> > Trace; c015268d <iput+5d/60>
> > Trace; c0150f46 <d_delete+66/c0>
> > Trace; c014719d <permission+3d/50>
> > Trace; c0149723 <vfs_unlink+1b3/1d0>
> > Trace; c01482e2 <lookup_hash+42/90>
> > Trace; c01497c9 <sys_unlink+89/f0>
> > Trace; c013c89d <sys_close+5d/70>
> 
> Odd.  Was this just running dbench?  If so, odd.  dbench
> doesn't mmap files, yet here we seem to have a truncated,
> mapped page.
> 
> I wonder where that came from?

Don't know.  httpd, smb, and nfs are all off.
Only dbench as far as I can tell.

The clock was off by 8 hours (I just fixed that), but
it happened last night when the system thought it was 0530 this morning,
which was 2130 last night, so nothing else was happening.

[root@spc5 log]# grep BUG messages
Aug 20 01:24:15 spc5 kernel: kernel BUG at page_alloc.c:98!
Aug 20 05:30:13 spc5 kernel:  kernel BUG at page_alloc.c:98!
Aug 20 05:30:16 spc5 kernel:  kernel BUG at page_alloc.c:98!

crontab is standard RH 7.3:

[root@spc5 etc]# cat crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# run-parts
01 * * * * root run-parts /etc/cron.hourly
02 4 * * * root run-parts /etc/cron.daily
22 4 * * 0 root run-parts /etc/cron.weekly
42 4 1 * * root run-parts /etc/cron.monthly

0-59/5 * * * * root /usr/bin/mrtg /etc/mrtg/mrtg.cfg

Steven




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
