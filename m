Date: Thu, 22 May 2003 23:18:15 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.69-mm8
Message-ID: <17990000.1053670694@[10.10.2.4]>
In-Reply-To: <20030522021652.6601ed2b.akpm@digeo.com>
References: <20030522021652.6601ed2b.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm8/
> 
> . One anticipatory scheduler patch, but it's a big one.  I have not stress
>   tested it a lot.  If it explodes please report it and then boot with
>   elevator=deadline.
> 
> . The slab magazine layer code is in its hopefully-final state.
> 
> . Some VFS locking scalability work - stress testing of this would be
>   useful.

Well, unsure about the problems I reported earlier - seems to be related
to modem disconnects during SDET runs ... the hung session seems to lock
up the system somehow. But that could have been around for ages - I'll
try to be more scientific about reproducing it at some point.

SDET results are about the same, kernel compile is down a bit on systime
(16-way NUMA-Q)

Kernbench: (make -j vmlinux, maximal tasks)
                              Elapsed      System        User         CPU
               2.5.69-mm7       46.58      117.00      578.47     1492.00
               2.5.69-mm8       46.09      115.11      570.74     1487.25

      1004     2.0% default_idle
       272     8.3% __copy_from_user_ll
       129     1.7% __d_lookup
        79     7.5% link_path_walk
...
       -50    -1.3% find_get_page
       -55    -1.5% zap_pte_range
       -66    -6.5% file_move
       -74    -1.2% page_add_rmap
       -80    -0.6% do_anonymous_page
      -110    -6.9% schedule
      -139    -7.0% atomic_dec_and_lock
      -698    -0.4% total
     -1139    -4.6% page_remove_rmap

Not sure quite what that's all about, but there it is ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
