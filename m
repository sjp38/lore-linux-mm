Message-ID: <3965371A.6F72A3FF@norran.net>
Date: Fri, 07 Jul 2000 03:49:14 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: new latency report
Content-Type: multipart/mixed;
 boundary="------------8C92AE671CCAD74EA597E84C"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8C92AE671CCAD74EA597E84C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

The attached output shows that when we hit swap - there are
code lines with latency problems :-(
[the actual code tested is test3-pre2 with my latency modifications
 (improvement and profiling) but has one modification relative
test3-pre4
 kswapd in the tested version always sleeps => problems accounted
 to the process causing it]

see the 293ms in generic_make_request...

and the 704ms used to busy loop in modprobe...
(SB16 non PnP)

These are worse then the previously found aux_write_dev :-(

/RogerL             
--
Home page:
  http://www.norran.net/nra02596/
--------------8C92AE671CCAD74EA597E84C
Content-Type: text/plain; charset=us-ascii;
 name="warn-2.4.0-test3-2-vmscan.latency.6-wcrrmr"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="warn-2.4.0-test3-2-vmscan.latency.6-wcrrmr"

Jul  5 23:17:45 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:17:45 dox kernel: Trace:
Jul  5 23:17:46 dox kernel: isapnp: Scanning for Pnp cards...
Jul  5 23:17:46 dox kernel: isapnp: No Plug & Play device found
Jul  5 23:17:46 dox kernel: Latency 704ms PID   230 % modprobe
Jul  5 23:17:46 dox kernel: Trace: [__rdtsc_delay+14/24] [__rdtsc_delay+14/24] [__rdtsc_delay+14/24] [__rdtsc_delay+16/24] [__rdtsc_delay+14/24] [__rdtsc_delay+14/24] [__rdtsc_delay+14/24] [__rdtsc_delay+14/24] [__rdtsc_delay+16/24] [__rdtsc_delay+16/24]
Jul  5 23:17:46 dox insmod: /lib/modules/2.4.0-test3/sound/sb.o: post-install sb failed
Jul  5 23:17:46 dox insmod: /lib/modules/2.4.0-test3/sound/sb.o: insmod char-major-14 failed
Jul  5 23:17:57 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:17:57 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:18:00 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:00 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:18:05 dox kernel: Latency   9ms PID   193 % nscd
Jul  5 23:18:05 dox kernel: Trace: [try_to_free_buffers+44/344]
Jul  5 23:18:05 dox kernel: Latency   8ms PID   233 % head
Jul  5 23:18:05 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:18:05 dox kernel: Latency   5ms PID     2 % kswapd
Jul  5 23:18:05 dox kernel: Trace: [kmem_slab_destroy+246/500]
Jul  5 23:18:06 dox kernel: Latency  10ms PID   233 % head
Jul  5 23:18:06 dox kernel: Trace: [try_to_free_buffers+22/344]
Jul  5 23:18:06 dox kernel: Latency  12ms PID   233 % head
Jul  5 23:18:06 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:18:07 dox kernel: Latency   9ms PID   233 % head
Jul  5 23:18:07 dox kernel: Trace:
Jul  5 23:18:07 dox kernel: Latency   9ms PID     2 % kswapd
Jul  5 23:18:07 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:18:08 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:08 dox kernel: Trace:
Jul  5 23:18:11 dox kernel: Latency  12ms PID   233 % head
Jul  5 23:18:11 dox kernel: Trace: [kmem_slab_destroy+234/500]
Jul  5 23:18:14 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:14 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:18:14 dox kernel: Latency  13ms PID   233 % head
Jul  5 23:18:14 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:18:18 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:18 dox kernel: Trace:
Jul  5 23:18:18 dox kernel: Latency   7ms PID   233 % head
Jul  5 23:18:18 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:18:18 dox kernel: Latency   5ms PID   233 % head
Jul  5 23:18:18 dox kernel: Trace: [shrink_mmap+368/524]
Jul  5 23:18:18 dox kernel: Latency  11ms PID   233 % head
Jul  5 23:18:18 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:18:18 dox kernel: Latency   6ms PID   233 % head
Jul  5 23:18:18 dox kernel: Trace:
Jul  5 23:18:18 dox kernel: Latency   9ms PID     2 % kswapd
Jul  5 23:18:18 dox kernel: Trace: [kmem_slab_destroy+265/500]
Jul  5 23:18:19 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:19 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:18:23 dox kernel: Latency   6ms PID     2 % kswapd
Jul  5 23:18:23 dox kernel: Trace: [generic_make_request+102/1880]
Jul  5 23:18:23 dox kernel: Latency   6ms PID   233 % head
Jul  5 23:18:23 dox kernel: Trace:
Jul  5 23:18:32 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:32 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:18:34 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:34 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:18:38 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:38 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:18:43 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:43 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:18:45 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:45 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:18:47 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:47 dox kernel: Trace:
Jul  5 23:18:48 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:48 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:18:49 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:49 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:18:49 dox kernel: Latency   6ms PID   235 % cp
Jul  5 23:18:49 dox kernel: Trace:
Jul  5 23:18:52 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:18:52 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:18:56 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:18:56 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:00 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:00 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:19:05 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:05 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:06 dox kernel: Latency   6ms PID     2 % kswapd
Jul  5 23:19:06 dox kernel: Trace: [shrink_mmap+75/524]
Jul  5 23:19:06 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:06 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:07 dox kernel: Latency   7ms PID   235 % cp
Jul  5 23:19:07 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:19:13 dox kernel: Latency   6ms PID   235 % cp
Jul  5 23:19:13 dox kernel: Trace:
Jul  5 23:19:13 dox kernel: Latency   7ms PID     2 % kswapd
Jul  5 23:19:13 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:19:17 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:17 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:19:26 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:26 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:19:27 dox kernel: Latency   9ms PID     2 % kswapd
Jul  5 23:19:27 dox kernel: Trace: [shrink_mmap+95/524]
Jul  5 23:19:29 dox kernel: Latency  24ms PID     2 % kswapd
Jul  5 23:19:29 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:19:31 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:31 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:33 dox kernel: Latency   6ms PID   235 % cp
Jul  5 23:19:33 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:19:39 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:39 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:19:42 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:42 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:19:45 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:45 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:19:46 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:46 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:49 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:49 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:50 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:50 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:19:52 dox kernel: Latency   5ms PID   235 % cp
Jul  5 23:19:52 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:19:54 dox kernel: Latency   5ms PID   235 % cp
Jul  5 23:19:54 dox kernel: Trace:
Jul  5 23:19:55 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:19:55 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:19:58 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:58 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:19:59 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:19:59 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:01 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:01 dox kernel: Trace:
Jul  5 23:20:03 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:03 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:09 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:09 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:13 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:13 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:20:14 dox kernel: Latency   5ms PID   235 % cp
Jul  5 23:20:14 dox kernel: Trace:
Jul  5 23:20:16 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:16 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:20:17 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:17 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:20:19 dox kernel: Latency   9ms PID   235 % cp
Jul  5 23:20:19 dox kernel: Trace: [try_to_free_buffers+22/344]
Jul  5 23:20:20 dox kernel: Latency   6ms PID   235 % cp
Jul  5 23:20:20 dox kernel: Trace:
Jul  5 23:20:21 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:21 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:31 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:31 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:20:33 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:33 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:20:36 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:36 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:38 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:38 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:20:41 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:41 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:43 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:43 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:45 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:45 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:20:48 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:20:48 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:20:51 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:51 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:20:54 dox kernel: Latency   5ms PID     2 % kswapd
Jul  5 23:20:54 dox kernel: Trace:
Jul  5 23:20:56 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:20:56 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:02 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:21:02 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:21:06 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:06 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:12 dox kernel: Latency   8ms PID   237 % cat
Jul  5 23:21:12 dox kernel: Trace:
Jul  5 23:21:19 dox kernel: Latency   9ms PID   237 % cat
Jul  5 23:21:19 dox kernel: Trace: [try_to_free_buffers+52/344]
Jul  5 23:21:21 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:21 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:22 dox kernel: Latency   5ms PID   237 % cat
Jul  5 23:21:22 dox kernel: Trace: [__alloc_pages+27/400]
Jul  5 23:21:23 dox kernel: Latency   5ms PID   237 % cat
Jul  5 23:21:23 dox kernel: Trace:
Jul  5 23:21:26 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:21:26 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:27 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:27 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:21:28 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:28 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:21:30 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:30 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:21:31 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:31 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:34 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:21:34 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:42 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:42 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:45 dox kernel: Latency  12ms PID   227 % vmstat
Jul  5 23:21:45 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:21:47 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:47 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:21:48 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:48 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:21:51 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:51 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:21:52 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:52 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:52 dox kernel: Latency   6ms PID   237 % cat
Jul  5 23:21:52 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:21:53 dox kernel: Latency  13ms PID     2 % kswapd
Jul  5 23:21:53 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:21:55 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:55 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:21:58 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:21:58 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:21:59 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:21:59 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:22:03 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:03 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:22:05 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:05 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:22:06 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:06 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:22:08 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:08 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:22:10 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:10 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:22:16 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:16 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:22:17 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:17 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:22:25 dox kernel: Latency   5ms PID   239 % cat
Jul  5 23:22:25 dox kernel: Trace:
Jul  5 23:22:28 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:28 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:22:29 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:29 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:22:30 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:30 dox kernel: Trace:
Jul  5 23:22:35 dox kernel: Latency   5ms PID   239 % cat
Jul  5 23:22:35 dox kernel: Trace: [shrink_mmap+75/524]
Jul  5 23:22:35 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:35 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:22:39 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:39 dox kernel: Trace: [try_to_free_buffers+49/344]
Jul  5 23:22:39 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:39 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:22:43 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:43 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:22:52 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:22:52 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:22:54 dox kernel: Latency   5ms PID   239 % cat
Jul  5 23:22:54 dox kernel: Trace:
Jul  5 23:22:57 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:22:57 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:00 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:00 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:01 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:01 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:04 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:04 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:05 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:05 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:23:08 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:08 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:23:11 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:11 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:23:12 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:12 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:23:16 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:16 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:23:16 dox kernel: Latency   5ms PID   239 % cat
Jul  5 23:23:16 dox kernel: Trace:
Jul  5 23:23:22 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:22 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:25 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:25 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:28 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:28 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:23:30 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:30 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:23:32 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:32 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:23:33 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:33 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:35 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:35 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:37 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:37 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:23:38 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:38 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:40 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:40 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:42 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:42 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:43 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:43 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:45 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:45 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:48 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:48 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:49 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:49 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:23:51 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:51 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:52 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:52 dox kernel: Trace:
Jul  5 23:23:55 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:23:55 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:23:55 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:23:55 dox kernel: Trace:
Jul  5 23:23:55 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:23:55 dox kernel: Trace: [ext2_get_block+978/1196]
Jul  5 23:23:57 dox kernel: Latency   6ms PID   240 % mmap002
Jul  5 23:23:57 dox kernel: Trace: [__wake_up+497/512]
Jul  5 23:23:57 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:23:57 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:23:58 dox kernel: Latency  15ms PID     2 % kswapd
Jul  5 23:23:58 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:23:59 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:23:59 dox kernel: Trace:
Jul  5 23:24:00 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:24:00 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:24:00 dox kernel: Latency  22ms PID   240 % mmap002
Jul  5 23:24:00 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+187/500] [kmem_slab_destroy+177/500]
Jul  5 23:24:01 dox kernel: Latency   9ms PID   240 % mmap002
Jul  5 23:24:01 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:24:02 dox kernel: Latency   6ms PID   240 % mmap002
Jul  5 23:24:02 dox kernel: Trace: [kmem_cache_alloc+121/452]
Jul  5 23:24:02 dox kernel: Latency  12ms PID   240 % mmap002
Jul  5 23:24:02 dox kernel: Trace: [__wake_up+23/512]
Jul  5 23:24:04 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:24:04 dox kernel: Trace:
Jul  5 23:24:04 dox kernel: Latency   8ms PID     2 % kswapd
Jul  5 23:24:04 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:24:06 dox kernel: Latency  30ms PID   240 % mmap002
Jul  5 23:24:06 dox kernel: Trace: [nr_free_buffer_pages+1/52] [block_getblk+799/844] [ext2_get_block+1071/1196]
Jul  5 23:24:06 dox kernel: Latency  72ms PID   240 % mmap002
Jul  5 23:24:06 dox kernel: Trace: [__mark_buffer_dirty+11/56] [block_getblk+113/844] [kmem_cache_alloc+121/452] [ext2_new_block+214/2056] [block_getblk+676/844] [kmem_cache_alloc+121/452] [get_unused_buffer_head+63/192]
Jul  5 23:24:06 dox kernel: Latency  24ms PID   240 % mmap002
Jul  5 23:24:06 dox kernel: Trace: [get_unused_buffer_head+61/192] [filemap_sync+500/904]
Jul  5 23:24:06 dox kernel: Latency   8ms PID   240 % mmap002
Jul  5 23:24:06 dox kernel: Trace: [kmem_cache_alloc+121/452]
Jul  5 23:24:06 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:24:06 dox kernel: Trace:
Jul  5 23:24:07 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [__insert_into_lru_list+68/96]
Jul  5 23:24:07 dox kernel: Latency  18ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [kmem_cache_grow+725/1136]
Jul  5 23:24:07 dox kernel: Latency  25ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [kmem_cache_grow+898/1136] [__wake_up+497/512]
Jul  5 23:24:07 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [generic_make_request+1848/1880] [__wake_up+497/512]
Jul  5 23:24:07 dox kernel: Latency  31ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [__wake_up+497/512] [__wake_up+497/512] [try_to_swap_out+76/636]
Jul  5 23:24:07 dox kernel: Latency  23ms PID   240 % mmap002
Jul  5 23:24:07 dox kernel: Trace: [__wake_up+23/512] [try_to_swap_out+76/636]
Jul  5 23:24:08 dox kernel: Latency  13ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [__refile_buffer+52/84]
Jul  5 23:24:08 dox kernel: Latency  19ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [kmem_cache_alloc+131/452] [kmem_cache_alloc+153/452]
Jul  5 23:24:08 dox kernel: Latency  19ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [try_to_swap_out+6/636] [__wake_up+497/512]
Jul  5 23:24:08 dox kernel: Latency  18ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  27ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [__wake_up+497/512] [try_to_swap_out+604/636]
Jul  5 23:24:08 dox kernel: Latency  12ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [ide_build_sglist+115/208] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  18ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [<c6868873>]
Jul  5 23:24:08 dox kernel: Latency  26ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [blk_get_queue+60/64] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency   8ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace:
Jul  5 23:24:08 dox kernel: Latency  17ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [__wake_up+23/512] [try_to_swap_out+7/636]
Jul  5 23:24:08 dox kernel: Latency  54ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  13ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  21ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1871/1880] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  20ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880] [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [generic_make_request+1848/1880]
Jul  5 23:24:08 dox kernel: Latency  14ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [try_to_swap_out+76/636]
Jul  5 23:24:08 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:24:08 dox kernel: Trace: [inode_getblk+4/884]
Jul  5 23:24:12 dox kernel: Latency  75ms PID   240 % mmap002
Jul  5 23:24:12 dox kernel: Trace: [kmem_cache_alloc+121/452] [ext2_get_block+26/1196] [<c6868873>] [__brelse+8/32] [set_bh_page+7/100] [kmem_cache_grow+725/1136] [<c68780b6>] [set_bh_page+18/100]
Jul  5 23:24:12 dox kernel: Latency  13ms PID   240 % mmap002
Jul  5 23:24:12 dox kernel: Trace: [kmem_cache_alloc+121/452]
Jul  5 23:24:12 dox kernel: Latency  23ms PID   240 % mmap002
Jul  5 23:24:12 dox kernel: Trace: [get_hash_table+109/148] [__mark_buffer_dirty+54/56] [__insert_into_lru_list+50/96]
Jul  5 23:24:12 dox kernel: Latency  12ms PID   240 % mmap002
Jul  5 23:24:12 dox kernel: Trace: [set_bh_page+2/100]
Jul  5 23:24:13 dox kernel: Latency  75ms PID   240 % mmap002
Jul  5 23:24:13 dox kernel: Trace: [__refile_buffer+1/84] [ext2_new_block+292/2056] [get_hash_table+98/148] [block_getblk+650/844] [get_unused_buffer_head+63/192] [ext2_alloc_block+142/144] [get_unused_buffer_head+65/192] [kmem_cache_alloc+121/452]
Jul  5 23:24:15 dox kernel: Latency  29ms PID   240 % mmap002
Jul  5 23:24:15 dox kernel: Trace: [ext2_get_block+1150/1196] [kmem_cache_grow+486/1136] [<c6868873>]
Jul  5 23:24:15 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:24:15 dox kernel: Trace: [wake_up_process+213/220]
Jul  5 23:24:16 dox kernel: Latency   6ms PID   240 % mmap002
Jul  5 23:24:16 dox kernel: Trace: [wakeup_bdflush+76/516]
Jul  5 23:24:16 dox kernel: Latency  13ms PID   240 % mmap002
Jul  5 23:24:16 dox kernel: Trace: [kmem_cache_grow+898/1136]
Jul  5 23:24:16 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:24:16 dox kernel: Trace: [get_unused_buffer_head+65/192]
Jul  5 23:24:16 dox kernel: Latency  13ms PID   240 % mmap002
Jul  5 23:24:16 dox kernel: Trace: [ext2_new_block+1756/2056] [get_hash_table+68/148]
Jul  5 23:24:17 dox kernel: Latency  12ms PID   240 % mmap002
Jul  5 23:24:17 dox kernel: Trace: [<c68780b6>]
Jul  5 23:24:17 dox kernel: Latency  23ms PID   240 % mmap002
Jul  5 23:24:17 dox kernel: Trace: [__mark_buffer_dirty+11/56] [wakeup_bdflush+76/516] [__refile_buffer+72/84]
Jul  5 23:24:17 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:24:17 dox kernel: Trace: [filemap_sync+500/904]
Jul  5 23:24:18 dox kernel: Latency  15ms PID   240 % mmap002
Jul  5 23:24:18 dox kernel: Trace: [ext2_get_block+912/1196]
Jul  5 23:24:19 dox kernel: Latency  11ms PID   240 % mmap002
Jul  5 23:24:19 dox kernel: Trace: [get_hash_table+95/148]
Jul  5 23:24:19 dox kernel: Latency  28ms PID   240 % mmap002
Jul  5 23:24:19 dox kernel: Trace: [__wake_up+497/512] [try_to_swap_out+231/636]
Jul  5 23:24:19 dox kernel: Latency  17ms PID   240 % mmap002
Jul  5 23:24:19 dox kernel: Trace: [generic_make_request+1848/1880]
Jul  5 23:24:19 dox kernel: Latency  30ms PID   240 % mmap002
Jul  5 23:24:19 dox kernel: Trace: [kmem_cache_alloc+121/452] [__insert_into_lru_list+83/96] [ext2_new_block+1323/2056]
Jul  5 23:24:21 dox kernel: Latency 154ms PID   240 % mmap002
Jul  5 23:24:21 dox kernel: Trace: [do_buffer_fdatasync+31/132] [writeout_one_page+23/76] [writeout_one_page+23/76] [__refile_buffer+1/84] [writeout_one_page+16/76] [__remove_from_lru_list+9/108] [__insert_into_lru_list+74/96] [generic_make_request+1848/1880] [__ll_rw_block+110/440] [generic_make_request+1848/1880]
Jul  5 23:24:23 dox kernel: Latency  43ms PID   240 % mmap002
Jul  5 23:24:23 dox kernel: Trace: [__wake_up+0/512] [waitfor_one_page+23/64] [__wake_up+497/512] [waitfor_one_page+23/64]
Jul  5 23:24:27 dox kernel: Latency  11ms PID   240 % mmap002
Jul  5 23:24:27 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:24:28 dox kernel: Latency  11ms PID   240 % mmap002
Jul  5 23:24:28 dox kernel: Trace: [try_to_swap_out+18/636]
Jul  5 23:24:28 dox kernel: Latency   8ms PID   240 % mmap002
Jul  5 23:24:28 dox kernel: Trace: [__wake_up+497/512]
Jul  5 23:24:28 dox kernel: Latency  38ms PID   240 % mmap002
Jul  5 23:24:28 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+246/500] [kmem_slab_destroy+179/500]
Jul  5 23:24:28 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:24:28 dox kernel: Trace:
Jul  5 23:24:29 dox kernel: Latency  27ms PID   240 % mmap002
Jul  5 23:24:29 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:24:29 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:29 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:24:30 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:30 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:24:31 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:24:31 dox kernel: Trace: [try_to_swap_out+76/636]
Jul  5 23:24:31 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:24:31 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:24:32 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:32 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:24:33 dox kernel: Latency  12ms PID   240 % mmap002
Jul  5 23:24:33 dox kernel: Trace: [swap_out_vma+319/464]
Jul  5 23:24:36 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:36 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:24:40 dox kernel: Latency   9ms PID   240 % mmap002
Jul  5 23:24:40 dox kernel: Trace: [swap_out_vma+343/464]
Jul  5 23:24:41 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:41 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:24:45 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:45 dox kernel: Trace:
Jul  5 23:24:46 dox kernel: Latency  14ms PID   240 % mmap002
Jul  5 23:24:46 dox kernel: Trace: [try_to_swap_out+206/636] [try_to_swap_out+76/636]
Jul  5 23:24:47 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:47 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:24:51 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:24:51 dox kernel: Trace: [try_to_swap_out+227/636]
Jul  5 23:24:51 dox kernel: Latency   6ms PID   240 % mmap002
Jul  5 23:24:51 dox kernel: Trace: [try_to_swap_out+604/636]
Jul  5 23:24:51 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:51 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:24:57 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:24:57 dox kernel: Trace:
Jul  5 23:24:59 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:25:00 dox kernel: Trace: [ide_do_request+660/736]
Jul  5 23:25:00 dox kernel: Latency   6ms PID   242 % cron
Jul  5 23:25:00 dox kernel: Trace: [swap_out+95/272]
Jul  5 23:25:03 dox kernel: Latency  11ms PID   240 % mmap002
Jul  5 23:25:03 dox kernel: Trace: [__wake_up+26/512]
Jul  5 23:25:04 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:25:04 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:25:05 dox kernel: Latency  17ms PID   240 % mmap002
Jul  5 23:25:05 dox kernel: Trace: [swap_out_vma+319/464] [__wake_up+497/512]
Jul  5 23:25:07 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:25:07 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:25:10 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:25:10 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:25:13 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:25:13 dox kernel: Trace:
Jul  5 23:25:15 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:25:15 dox kernel: Trace: [__wake_up+7/512]
Jul  5 23:25:16 dox kernel: Latency  27ms PID   228 % tee
Jul  5 23:25:16 dox kernel: Trace: [swap_out_vma+365/464] [<c6868873>]
Jul  5 23:25:16 dox kernel: Latency   7ms PID   227 % vmstat
Jul  5 23:25:16 dox kernel: Trace: [try_to_swap_out+0/636]
Jul  5 23:25:18 dox kernel: Latency   9ms PID   227 % vmstat
Jul  5 23:25:18 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:25:23 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:25:23 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:25:40 dox kernel: Latency  10ms PID   240 % mmap002
Jul  5 23:25:40 dox kernel: Trace: [try_to_swap_out+0/636]
Jul  5 23:25:40 dox kernel: Latency   7ms PID   240 % mmap002
Jul  5 23:25:40 dox kernel: Trace: [try_to_swap_out+18/636]
Jul  5 23:25:41 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:25:41 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:25:46 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:25:46 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:25:47 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:25:47 dox kernel: Trace:
Jul  5 23:25:50 dox kernel: Latency   8ms PID   240 % mmap002
Jul  5 23:25:50 dox kernel: Trace: [try_to_swap_out+76/636]
Jul  5 23:25:50 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:25:50 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:25:50 dox kernel: Latency   6ms PID   240 % mmap002
Jul  5 23:25:50 dox kernel: Trace: [swap_out_vma+319/464]
Jul  5 23:25:57 dox kernel: Latency  23ms PID   240 % mmap002
Jul  5 23:25:57 dox kernel: Trace: [try_to_swap_out+227/636] [try_to_swap_out+206/636]
Jul  5 23:25:58 dox kernel: Latency   5ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [filemap_sync+440/904]
Jul  5 23:25:58 dox kernel: Latency   9ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [set_bh_page+96/100]
Jul  5 23:25:58 dox kernel: Latency  21ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [kmem_cache_grow+898/1136] [kmem_cache_grow+725/1136]
Jul  5 23:25:58 dox kernel: Latency  55ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [kmem_cache_grow+725/1136] [kmem_cache_grow+725/1136] [block_getblk+103/844] [kmem_cache_grow+959/1136] [__brelse+0/32] [block_getblk+121/844]
Jul  5 23:25:58 dox kernel: Latency  41ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [balance_dirty_state+15/72] [block_getblk+666/844] [block_getblk+148/844] [kmem_cache_alloc+20/452] [mark_buffer_dirty+0/24]
Jul  5 23:25:58 dox kernel: Latency  35ms PID   240 % mmap002
Jul  5 23:25:58 dox kernel: Trace: [kmem_cache_alloc+121/452] [filemap_sync+503/904] [getblk+4/152]
Jul  5 23:26:01 dox kernel: Latency  59ms PID   240 % mmap002
Jul  5 23:26:01 dox kernel: Trace: [ext2_get_block+1027/1196] [block_getblk+419/844] [wakeup_bdflush+91/516] [__brelse+8/32] [get_hash_table+98/148] [wake_up_process+206/220]
Jul  5 23:26:01 dox kernel: Latency 293ms PID   240 % mmap002
Jul  5 23:26:01 dox kernel: Trace: [<c68780b6>] [generic_make_request+95/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880] [lock_page+25/36] [generic_make_request+1871/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880] [generic_make_request+1848/1880]
Jul  5 23:26:05 dox kernel: Latency  18ms PID   240 % mmap002
Jul  5 23:26:05 dox kernel: Trace: [waitfor_one_page+51/64]
Jul  5 23:26:05 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:05 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:26:05 dox kernel: Latency 100ms PID   240 % mmap002
Jul  5 23:26:05 dox kernel: Trace: [zap_page_range+308/500] [try_to_free_buffers+87/344] [truncate_inode_pages+270/612] [kmem_cache_free+212/644] [block_flushpage+64/144] [truncate_inode_pages+173/612] [kmem_cache_free+55/644] [__wake_up+7/512] [kmem_cache_free+637/644] [kmem_cache_free+212/644]
Jul  5 23:26:06 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:06 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:07 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:07 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:26:07 dox kernel: Latency  77ms PID     2 % kswapd
Jul  5 23:26:07 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:26:11 dox kernel: Latency  48ms PID   240 % mmap002
Jul  5 23:26:11 dox kernel: Trace: [trunc_indirect+384/568] [zap_page_range+380/500] [free_page_and_swap_cache+123/128] [__free_pages_ok+675/700]
Jul  5 23:26:12 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:12 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:13 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:13 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:15 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:15 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:17 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:17 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:26:18 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:18 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:20 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:20 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:22 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:22 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:23 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:23 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:26:25 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:25 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:26:27 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:27 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:28 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:28 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:30 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:30 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:26:32 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:32 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:33 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:33 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:26:36 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:36 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:26:39 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:39 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:26:41 dox kernel: Latency   6ms PID     0 % swapper
Jul  5 23:26:41 dox kernel: Trace:
Jul  5 23:26:43 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:43 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:26:46 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:46 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:26:48 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:26:48 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:54 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:26:54 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:26:56 dox kernel: Latency   7ms PID   244 % cat
Jul  5 23:26:56 dox kernel: Trace:
Jul  5 23:26:58 dox kernel: Latency   7ms PID     2 % kswapd
Jul  5 23:26:58 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:00 dox kernel: Latency  11ms PID   244 % cat
Jul  5 23:27:00 dox kernel: Trace: [kmem_cache_free+212/644]
Jul  5 23:27:00 dox kernel: Latency   9ms PID   244 % cat
Jul  5 23:27:00 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:00 dox kernel: Latency  20ms PID   227 % vmstat
Jul  5 23:27:00 dox kernel: Trace: [kmem_cache_free+212/644] [kmem_cache_free+4/644]
Jul  5 23:27:01 dox kernel: Latency  19ms PID   244 % cat
Jul  5 23:27:01 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:27:01 dox kernel: Latency   6ms PID   244 % cat
Jul  5 23:27:01 dox kernel: Trace:
Jul  5 23:27:01 dox kernel: Latency   9ms PID   244 % cat
Jul  5 23:27:01 dox kernel: Trace: [kmem_cache_free+59/644]
Jul  5 23:27:01 dox kernel: Latency  14ms PID   244 % cat
Jul  5 23:27:01 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:27:01 dox kernel: Latency  19ms PID   244 % cat
Jul  5 23:27:01 dox kernel: Trace: [kmem_cache_free+212/644] [kmem_cache_free+212/644]
Jul  5 23:27:01 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:01 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:27:01 dox kernel: Latency  20ms PID     2 % kswapd
Jul  5 23:27:01 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:27:02 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:02 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:27:05 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:05 dox kernel: Trace:
Jul  5 23:27:06 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:06 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:27:07 dox kernel: Latency   6ms PID   244 % cat
Jul  5 23:27:07 dox kernel: Trace: [try_to_free_buffers+52/344]
Jul  5 23:27:07 dox kernel: Latency  26ms PID   244 % cat
Jul  5 23:27:07 dox kernel: Trace: [kmem_slab_destroy+177/500] [kmem_slab_destroy+177/500]
Jul  5 23:27:08 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:08 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:27:11 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:11 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:27:12 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:12 dox kernel: Trace:
Jul  5 23:27:17 dox kernel: Latency   5ms PID   244 % cat
Jul  5 23:27:17 dox kernel: Trace:
Jul  5 23:27:17 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:17 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:27:18 dox kernel: Latency   6ms PID   244 % cat
Jul  5 23:27:18 dox kernel: Trace:
Jul  5 23:27:18 dox kernel: Latency   9ms PID   244 % cat
Jul  5 23:27:18 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:21 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:21 dox kernel: Trace:
Jul  5 23:27:23 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:23 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:27:23 dox kernel: Latency   7ms PID   244 % cat
Jul  5 23:27:23 dox kernel: Trace:
Jul  5 23:27:24 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:24 dox kernel: Trace: [si_swapinfo+72/136]
Jul  5 23:27:26 dox kernel: Latency   9ms PID   244 % cat
Jul  5 23:27:26 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:28 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:28 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:27:31 dox kernel: Latency   7ms PID     2 % kswapd
Jul  5 23:27:31 dox kernel: Trace:
Jul  5 23:27:33 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:33 dox kernel: Trace:
Jul  5 23:27:33 dox kernel: Latency  10ms PID   244 % cat
Jul  5 23:27:33 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:35 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:35 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:27:38 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:38 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:27:42 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:42 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:27:43 dox kernel: Latency   8ms PID   244 % cat
Jul  5 23:27:43 dox kernel: Trace: [shrink_mmap+374/524]
Jul  5 23:27:43 dox kernel: Latency   8ms PID   244 % cat
Jul  5 23:27:43 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:45 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:45 dox kernel: Trace: [si_swapinfo+88/136]
Jul  5 23:27:46 dox kernel: Latency   9ms PID     2 % kswapd
Jul  5 23:27:46 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:27:47 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:47 dox kernel: Trace: [si_swapinfo+93/136]
Jul  5 23:27:49 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:27:49 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:27:51 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:51 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:27:57 dox kernel: Latency   5ms PID   227 % vmstat
Jul  5 23:27:57 dox kernel: Trace: [si_swapinfo+75/136]
Jul  5 23:28:00 dox kernel: Latency   6ms PID   227 % vmstat
Jul  5 23:28:00 dox kernel: Trace: [si_swapinfo+98/136]
Jul  5 23:28:18 dox kernel: Latency   5ms PID     2 % kswapd
Jul  5 23:28:18 dox kernel: Trace:
Jul  5 23:28:19 dox kernel: Latency  17ms PID     2 % kswapd
Jul  5 23:28:19 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:28:43 dox kernel: Latency  11ms PID     2 % kswapd
Jul  5 23:28:43 dox kernel: Trace: [kmem_slab_destroy+177/500]
Jul  5 23:30:32 dox kernel: Latency   5ms PID   268 % cat
Jul  5 23:30:32 dox kernel: Trace:

--------------8C92AE671CCAD74EA597E84C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
