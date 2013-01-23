Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 8B4376B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 00:46:33 -0500 (EST)
Date: Wed, 23 Jan 2013 14:46:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/3 v2]mm: don't inline page_mapping()
Message-ID: <20130123054631.GE2723@blaptop>
References: <20130122022919.GA12293@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130122022919.GA12293@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Tue, Jan 22, 2013 at 10:29:19AM +0800, Shaohua Li wrote:
> 
> According to akpm, this saves 1/2k text and makes things simple of next patch.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
Acked-by: Minchan Kim <minchan@kernel.org>

FYI,

Feel free to add in changelog if you have evidence. :)

add/remove: 1/0 grow/shrink: 6/22 up/down: 92/-516 (-424)
function                                     old     new   delta
page_mapping                                   -      48     +48
do_task_stat                                2292    2308     +16
page_remove_rmap                             240     248      +8
load_elf_binary                             4500    4508      +8
update_queue                                 532     536      +4
scsi_probe_and_add_lun                      2892    2896      +4
lookup_fast                                  644     648      +4
vcs_read                                    1040    1036      -4
__ip_route_output_key                       1904    1900      -4
ip_route_input_noref                        2508    2500      -8
shmem_file_aio_read                          784     772     -12
__isolate_lru_page                           272     256     -16
shmem_replace_page                           708     688     -20
mark_buffer_dirty                            228     208     -20
__set_page_dirty_buffers                     240     220     -20
__remove_mapping                             276     256     -20
update_mmu_cache                             500     476     -24
set_page_dirty_balance                        92      68     -24
set_page_dirty                               172     148     -24
page_evictable                                88      64     -24
page_cache_pipe_buf_steal                    248     224     -24
clear_page_dirty_for_io                      340     316     -24
test_set_page_writeback                      400     372     -28
test_clear_page_writeback                    516     488     -28
invalidate_inode_page                        156     128     -28
page_mkclean                                 432     400     -32
flush_dcache_page                            360     328     -32
__set_page_dirty_nobuffers                   324     280     -44
shrink_page_list                            2412    2356     -56

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
