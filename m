Message-ID: <478E4972.5050705@sgi.com>
Date: Wed, 16 Jan 2008 10:14:10 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
 large count NR_CPUs V3
References: <20080116170902.006151000@sgi.com> <E1JFCZo-000618-8r@faramir.fjphome.nl>
In-Reply-To: <E1JFCZo-000618-8r@faramir.fjphome.nl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Frans Pop <elendil@planet.nl>
Cc: ak@suse.de, akpm@linux-foundation.org, clameter@sgi.com, dada1@cosmosbay.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Frans Pop wrote:
> travis@sgi.com wrote:
>>    8472457 Total          30486950 +259%          30342823 +258%
> 
> Hmmm. The table for previous versions looked a lot more impressive.
> 
> now:    8472457 Total	 +22014493 +259%	 +21870366 +258%
> V2 :    7172678 Total    +23314404 +325%           -147590   -2%
> (recalculated for comparison)
> 
> Did something go wrong with the "after" data?

The previous version had each column's difference from the
previous.  The new one had eacho column's difference from the
first column.  (Also, there are differences in what "after"
means. ;-)

Here's the "each-relative" version.  It sort of depends on if
you want to see each incremental change or the net overall change.

Thanks,
Mike
--- 

128cpus                 1kcpus-before           1kcpus-after
       228 .altinstr_re         +0 +0%                  +0 +0%
      1219 .altinstruct         +0 +0%                  +0 +0%
    866632 .bss           +1393664 +160%           -147328 -6%
     61374 .comment             +0 +0%                  +0 +0%
        16 .con_initcal         +0 +0%                  +0 +0%
    427560 .data            +17920 +4%               -1280 +0%
   1165824 .data.cachel  +11911168 +1021%               +0 +0%
      8192 .data.init_t         +0 +0%                  +0 +0%
      4096 .data.page_a         +0 +0%                  +0 +0%
     39296 .data.percpu    +116480 +296%              +128 +0%
    188992 .data.read_m   +8562784 +4530%            -4096 +0%
         4 .data_nosave         +0 +0%                  +0 +0%
      5141 .exit.text           +9 +0%                  -1 +0%
    138576 .init.data         +896 +0%               +5952 +4%
       134 .init.ramfs          +0 +0%                  +0 +0%
      3192 .init.setup          +0 +0%                  +0 +0%
    160143 .init.text         +500 +0%                +271 +0%
      2288 .initcall.in         +0 +0%                  +0 +0%
         8 .jiffies             +0 +0%                  +0 +0%
      4512 .pci_fixup           +0 +0%                  +0 +0%
   1314318 .rodata           +1312 +0%                -325 +0%
     36856 .smp_locks          -48 +0%                  -8 +0%
   3975021 .text             +9808 +0%               +2560 +0%
      3368 .vdso                +0 +0%                  +0 +0%
         4 .vgetcpu_mod         +0 +0%                  +0 +0%
       218 .vsyscall_0          +0 +0%                  +0 +0%
        52 .vsyscall_1          +0 +0%                  +0 +0%
        91 .vsyscall_2          +0 +0%                  +0 +0%
         8 .vsyscall_3          +0 +0%                  +0 +0%
        54 .vsyscall_fn         +0 +0%                  +0 +0%
        80 .vsyscall_gt         +0 +0%                  +0 +0%
     39480 __bug_table          +0 +0%                  +0 +0%
     16320 __ex_table           +0 +0%                  +0 +0%
      9160 __param              +0 +0%                  +0 +0%

   1818299 Text             +16304 +0%                +256 +0%
   3975021 Data              +9808 +0%               +2560 +0%
    866632 Bss            +1393664 +160%           -147328 -6%
    360448 InitData        +122880 +34%              +4096 +0%
   1415640 OtherData     +20470272 +1446%            -2816 +0%
     39296 PerCpu          +116480 +0%                +128 +0%
   8472457 Total         +22014493 +259%           -144127 +0%

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
