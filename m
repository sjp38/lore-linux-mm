Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C38466B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 21:25:57 -0500 (EST)
Date: Thu, 24 Jan 2013 11:25:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/3 v2]mm: don't inline page_mapping()
Message-ID: <20130124022555.GC22654@blaptop>
References: <20130122022919.GA12293@kernel.org>
 <20130123054631.GE2723@blaptop>
 <1358990120.3351.6.camel@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358990120.3351.6.camel@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Wed, Jan 23, 2013 at 07:15:20PM -0600, Simon Jeons wrote:
> On Wed, 2013-01-23 at 14:46 +0900, Minchan Kim wrote:
> > On Tue, Jan 22, 2013 at 10:29:19AM +0800, Shaohua Li wrote:
> > > 
> > > According to akpm, this saves 1/2k text and makes things simple of next patch.
> > > 
> > > Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> > > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > 
> > FYI,
> > 
> > Feel free to add in changelog if you have evidence. :)
> > 
> 
> Hi Minchan,

Hello again,

> 
> Could you tell me how can you get these test result? Which tool
> or ...? :)

./script/bloat-o-meter :)

> 
> > add/remove: 1/0 grow/shrink: 6/22 up/down: 92/-516 (-424)
> > function                                     old     new   delta
> > page_mapping                                   -      48     +48
> > do_task_stat                                2292    2308     +16
> > page_remove_rmap                             240     248      +8
> > load_elf_binary                             4500    4508      +8
> > update_queue                                 532     536      +4
> > scsi_probe_and_add_lun                      2892    2896      +4
> > lookup_fast                                  644     648      +4
> > vcs_read                                    1040    1036      -4
> > __ip_route_output_key                       1904    1900      -4
> > ip_route_input_noref                        2508    2500      -8
> > shmem_file_aio_read                          784     772     -12
> > __isolate_lru_page                           272     256     -16
> > shmem_replace_page                           708     688     -20
> > mark_buffer_dirty                            228     208     -20
> > __set_page_dirty_buffers                     240     220     -20
> > __remove_mapping                             276     256     -20
> > update_mmu_cache                             500     476     -24
> > set_page_dirty_balance                        92      68     -24
> > set_page_dirty                               172     148     -24
> > page_evictable                                88      64     -24
> > page_cache_pipe_buf_steal                    248     224     -24
> > clear_page_dirty_for_io                      340     316     -24
> > test_set_page_writeback                      400     372     -28
> > test_clear_page_writeback                    516     488     -28
> > invalidate_inode_page                        156     128     -28
> > page_mkclean                                 432     400     -32
> > flush_dcache_page                            360     328     -32
> > __set_page_dirty_nobuffers                   324     280     -44
> > shrink_page_list                            2412    2356     -56
> > 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
