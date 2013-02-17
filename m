Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 27CDA6B00BF
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 22:01:12 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id 2so2016590qeb.15
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 19:01:11 -0800 (PST)
Message-ID: <512047F1.7050704@gmail.com>
Date: Sun, 17 Feb 2013 11:01:05 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: behavior of zram stats, and zram allocation limit
References: <CAA25o9Q4gMPeLf3uYJzMNR1EU4D3OPeje24X4PNsUVHGoqyY5g@mail.gmail.com>
In-Reply-To: <CAA25o9Q4gMPeLf3uYJzMNR1EU4D3OPeje24X4PNsUVHGoqyY5g@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

On 11/22/2012 06:58 AM, Luigi Semenzato wrote:
> Hi,
>
> Two questions for zram developers/users.  (Please let me know if it is
> NOT acceptable to use this list for these questions.)
>
> 1. When I run a synthetic load using zram from kernel 3.4.0,
> compr_data_size from /sys/block/zram0 seems to decrease even though
> orig_data_size stays constant (see below).  Is this a bug that was
> fixed in a later release?  (The synthetic load is a bunch of processes
> that allocate memory, fill half of it with data from /dev/urandom, and
> touch the memory randomly.)  I looked at the code and it looks right.
> :-P
>
> 2. Is there a way of setting the max amount of RAM that zram is
> allowed to allocate?  Right now I can set the size of the
> *uncompressed* swap device, but how much memory gets allocated depends
> on the compression ratio, which could vary.
>
> Thanks!

Could you share your zraminfo ?

>
>
> localhost ~ # ./zraminfo
>       compr_data_size:    220570516 (210 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    230383616 (219 MB)
>           notify_free:         1553 (0 MB)
>             num_reads:         6093 (0 MB)
>            num_writes:       150955 (0 MB)
>        orig_data_size:    599126016 (571 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         4040 (0 MB)
>     eff. compr. ratio:  2.50
> localhost ~ #
> localhost ~ # ./zraminfo
>       compr_data_size:    208845619 (199 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    213528576 (203 MB)
>           notify_free:        76808 (0 MB)
>             num_reads:        81918 (0 MB)
>            num_writes:       202924 (0 MB)
>        orig_data_size:    586076160 (558 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7434 (0 MB)
>     eff. compr. ratio:  2.80
> localhost ~ # ./zraminfo
>       compr_data_size:    205964814 (196 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    210976768 (201 MB)
>           notify_free:        91823 (0 MB)
>             num_reads:       105170 (0 MB)
>            num_writes:       218485 (0 MB)
>        orig_data_size:    614526976 (586 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         8666 (0 MB)
>     eff. compr. ratio:  2.98
> localhost ~ # ./zraminfo
>       compr_data_size:    229739564 (219 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    235798528 (224 MB)
>           notify_free:       108381 (0 MB)
>             num_reads:       147372 (0 MB)
>            num_writes:       251829 (0 MB)
>        orig_data_size:    697163776 (664 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         9972 (0 MB)
>     eff. compr. ratio:  3.01
> localhost ~ # ./zraminfo
>       compr_data_size:    229458612 (218 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    234651648 (223 MB)
>           notify_free:       132169 (0 MB)
>             num_reads:       203970 (0 MB)
>            num_writes:       282732 (0 MB)
>        orig_data_size:    751472640 (716 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:        11139 (0 MB)
>     eff. compr. ratio:  3.27
> localhost ~ # ./zraminfo
>       compr_data_size:    217296398 (207 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    222715904 (212 MB)
>           notify_free:       151071 (0 MB)
>             num_reads:       243898 (0 MB)
>            num_writes:       302316 (0 MB)
>        orig_data_size:    778227712 (742 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:        10195 (0 MB)
>     eff. compr. ratio:  3.58
> localhost ~ # ./zraminfo
>       compr_data_size:    221631885 (211 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    227188736 (216 MB)
>           notify_free:       166323 (0 MB)
>             num_reads:       278621 (0 MB)
>            num_writes:       323811 (0 MB)
>        orig_data_size:    821809152 (783 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:        10737 (0 MB)
>     eff. compr. ratio:  3.70
> localhost ~ # ./zraminfo
>       compr_data_size:    216354938 (206 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    221990912 (211 MB)
>           notify_free:       182529 (0 MB)
>             num_reads:       322923 (0 MB)
>            num_writes:       342028 (0 MB)
>        orig_data_size:    849281024 (809 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:        10990 (0 MB)
>     eff. compr. ratio:  3.92
> localhost ~ # ./zraminfo
>       compr_data_size:    163852068 (156 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    170209280 (162 MB)
>           notify_free:       212669 (0 MB)
>             num_reads:       358680 (0 MB)
>            num_writes:       342896 (0 MB)
>        orig_data_size:    777981952 (741 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7466 (0 MB)
>     eff. compr. ratio:  4.77
> localhost ~ # ./zraminfo
>       compr_data_size:    164434814 (156 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    170631168 (162 MB)
>           notify_free:       218105 (0 MB)
>             num_reads:       368430 (0 MB)
>            num_writes:       349043 (0 MB)
>        orig_data_size:    785846272 (749 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7996 (0 MB)
>     eff. compr. ratio:  4.78
> localhost ~ # ./zraminfo
>       compr_data_size:    129945717 (123 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    136237056 (129 MB)
>           notify_free:       241461 (0 MB)
>             num_reads:       404654 (0 MB)
>            num_writes:       360153 (0 MB)
>        orig_data_size:    763969536 (728 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7911 (0 MB)
>     eff. compr. ratio:  5.88
> localhost ~ # ./zraminfo
>       compr_data_size:    134384535 (128 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    140816384 (134 MB)
>           notify_free:       242365 (0 MB)
>             num_reads:       406159 (0 MB)
>            num_writes:       362829 (0 MB)
>        orig_data_size:    773607424 (737 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7975 (0 MB)
>     eff. compr. ratio:  5.69
> localhost ~ # ./zraminfo
>       compr_data_size:    133314196 (127 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    139538432 (133 MB)
>           notify_free:       252447 (0 MB)
>             num_reads:       411617 (0 MB)
>            num_writes:       365459 (0 MB)
>        orig_data_size:    754352128 (719 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7954 (0 MB)
>     eff. compr. ratio:  5.68
> localhost ~ # ./zraminfo
>       compr_data_size:    124826153 (119 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    131440640 (125 MB)
>           notify_free:       263839 (0 MB)
>             num_reads:       427837 (0 MB)
>            num_writes:       375085 (0 MB)
>        orig_data_size:    762548224 (727 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7504 (0 MB)
>     eff. compr. ratio:  6.08
> localhost ~ # ./zraminfo
>       compr_data_size:     94379398 (90 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:    105000960 (100 MB)
>           notify_free:       291596 (0 MB)
>             num_reads:       465420 (0 MB)
>            num_writes:       386267 (0 MB)
>        orig_data_size:    721780736 (688 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7482 (0 MB)
>     eff. compr. ratio:  7.31
> localhost ~ # ./zraminfo
>       compr_data_size:     67124988 (64 MB)
>              disksize:   3101462528 (2957 MB)
>        mem_used_total:     73981952 (70 MB)
>           notify_free:       336548 (0 MB)
>             num_reads:       499935 (0 MB)
>            num_writes:       400298 (0 MB)
>        orig_data_size:    700309504 (667 MB)
>                  size:      6057544 (5 MB)
>            zero_pages:         7495 (0 MB)
>     eff. compr. ratio: 10.41
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
