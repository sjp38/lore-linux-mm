Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 29FA56B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 12:10:55 -0500 (EST)
Received: by faaa26 with SMTP id a26so940445faa.14
        for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:10:52 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 30 Nov 2011 11:10:51 -0600
Message-ID: <CAB7xdi=HuEXRZfj3wP-Nk-paFfH4EVQju8G-g_FZSsMGR=Mi2g@mail.gmail.com>
Subject: memory zone_stat_item all stats 0
From: sheng qiu <herbert1984106@gmail.com>
Content-Type: multipart/alternative; boundary=f46d040fa000691eea04b2f6d17b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

--f46d040fa000691eea04b2f6d17b
Content-Type: text/plain; charset=ISO-8859-1

hi all,

i have a question, i looked at my zone information through
/proc/zoneinfor,  i see that one zone has all the zone_stat_item equal 0.
i just do not understand why? and where inside the kernel, it did this
stats for each zone?
here's the output of that zone:
Node 0, zone Non-volatile
  pages free     209598
        min      1097
        low      1371
        high     1645
        scanned  0
        spanned  1310720
        present  1292800
    nr_free_pages 209598
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
        protection: (0, 0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 64
              high:  186
              batch: 31
  vm stats threshold: 42
    cpu: 1
              count: 23
              high:  186
              batch: 31
  vm stats threshold: 42
    cpu: 2
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 42
    cpu: 3
              count: 30
              high:  186
              batch: 31
  vm stats threshold: 42
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         1048576
  inactive_ratio:    6

Thanks,
Sheng

-- 
Sheng Qiu
Texas A & M University
Room 302 Wisenbaker
email: herbert1984106@gmail.com
College Station, TX 77843-3259

--f46d040fa000691eea04b2f6d17b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

hi all,<br><br>i have a question, i looked at my zone information through /=
proc/zoneinfor,=A0 i see that one zone has all the zone_stat_item equal 0.=
=A0 i just do not understand why? and where inside the kernel, it did this =
stats for each zone? <br>
here&#39;s the output of that zone:<br>Node 0, zone Non-volatile<br>=A0 pag=
es free=A0=A0=A0=A0 209598<br>=A0=A0=A0=A0=A0=A0=A0 min=A0=A0=A0=A0=A0 1097=
<br>=A0=A0=A0=A0=A0=A0=A0 low=A0=A0=A0=A0=A0 1371<br>=A0=A0=A0=A0=A0=A0=A0 =
high=A0=A0=A0=A0 1645<br>=A0=A0=A0=A0=A0=A0=A0 scanned=A0 0<br>=A0=A0=A0=A0=
=A0=A0=A0 spanned=A0 1310720<br>=A0=A0=A0=A0=A0=A0=A0 present=A0 1292800<br=
>
=A0=A0=A0 nr_free_pages 209598<br>=A0=A0=A0 nr_inactive_anon 0<br>=A0=A0=A0=
 nr_active_anon 0<br>=A0=A0=A0 nr_inactive_file 0<br>=A0=A0=A0 nr_active_fi=
le 0<br>=A0=A0=A0 nr_unevictable 0<br>=A0=A0=A0 nr_mlock=A0=A0=A0=A0 0<br>=
=A0=A0=A0 nr_anon_pages 0<br>=A0=A0=A0 nr_mapped=A0=A0=A0 0<br>=A0=A0=A0 nr=
_file_pages 0<br>
=A0=A0=A0 nr_dirty=A0=A0=A0=A0 0<br>=A0=A0=A0 nr_writeback 0<br>=A0=A0=A0 n=
r_slab_reclaimable 0<br>=A0=A0=A0 nr_slab_unreclaimable 0<br>=A0=A0=A0 nr_p=
age_table_pages 0<br>=A0=A0=A0 nr_kernel_stack 0<br>=A0=A0=A0 nr_unstable=
=A0 0<br>=A0=A0=A0 nr_bounce=A0=A0=A0 0<br>=A0=A0=A0 nr_vmscan_write 0<br>
=A0=A0=A0 nr_writeback_temp 0<br>=A0=A0=A0 nr_isolated_anon 0<br>=A0=A0=A0 =
nr_isolated_file 0<br>=A0=A0=A0 nr_shmem=A0=A0=A0=A0 0<br>=A0=A0=A0=A0=A0=
=A0=A0 protection: (0, 0, 0, 0, 0)<br>=A0 pagesets<br>=A0=A0=A0 cpu: 0<br>=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 count: 64<br>=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 high:=A0 186<br>
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 batch: 31<br>=A0 vm stats threshold=
: 42<br>=A0=A0=A0 cpu: 1<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 count: =
23<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 high:=A0 186<br>=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 batch: 31<br>=A0 vm stats threshold: 42<br>=A0=
=A0=A0 cpu: 2<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 count: 0<br>=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 high:=A0 186<br>
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 batch: 31<br>=A0 vm stats threshold=
: 42<br>=A0=A0=A0 cpu: 3<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 count: =
30<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 high:=A0 186<br>=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 batch: 31<br>=A0 vm stats threshold: 42<br>=A0 =
all_unreclaimable: 0<br>=A0 prev_priority:=A0=A0=A0=A0 12<br>
=A0 start_pfn:=A0=A0=A0=A0=A0=A0=A0=A0 1048576<br>=A0 inactive_ratio:=A0=A0=
=A0 6<br><br clear=3D"all">Thanks,<br>Sheng<br><br>-- <br>Sheng Qiu<br>Texa=
s A &amp; M University<br>Room 302 Wisenbaker=A0 =A0 <br>email: <a href=3D"=
mailto:herbert1984106@gmail.com">herbert1984106@gmail.com</a><br>
College Station, TX 77843-3259<br>

--f46d040fa000691eea04b2f6d17b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
