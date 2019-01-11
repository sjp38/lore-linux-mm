Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E31B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:19:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so11419114pfk.12
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:19:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t63si32719695pgd.78.2019.01.11.15.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 15:19:22 -0800 (PST)
Date: Fri, 11 Jan 2019 15:19:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [mmotm:master 157/168] arch/ia64/Kconfig:128:error: recursive
 dependency detected!
Message-ID: <20190111231918.GO6310@bombadil.infradead.org>
References: <201901120611.UoBzEqL5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201901120611.UoBzEqL5%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>


I'm having a hard time imagining anyone's still interested in running
on the HP ia64 simulator these days.  All in favour of deleting support
for that configuration?

On Sat, Jan 12, 2019 at 06:26:58AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   b82f1ccbef6e8b7feb60f8204eb69e6ce50d3f92
> commit: d7c02c12fb6f2572b34eecdc6055814b7bb07b25 [157/168] linux-next
> config: ia64-allyesconfig
> compiler: ia64-linux-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout d7c02c12fb6f2572b34eecdc6055814b7bb07b25
>         GCC_VERSION=8.1.0 make.cross ARCH=ia64  allyesconfig
>         GCC_VERSION=8.1.0 make.cross ARCH=ia64 
> 
> All errors (new ones prefixed by >>):
> 
> >> arch/ia64/Kconfig:128:error: recursive dependency detected!
> >> arch/ia64/Kconfig:128: choice <choice> contains symbol IA64_HP_SIM
> >> arch/ia64/Kconfig:202: symbol IA64_HP_SIM is part of choice PM
> >> kernel/power/Kconfig:144: symbol PM is selected by PM_SLEEP
> >> kernel/power/Kconfig:104: symbol PM_SLEEP depends on HIBERNATE_CALLBACKS
> >> kernel/power/Kconfig:31: symbol HIBERNATE_CALLBACKS is selected by HIBERNATION
> >> kernel/power/Kconfig:34: symbol HIBERNATION depends on SWAP
> >> init/Kconfig:253: symbol SWAP depends on BLOCK
> >> block/Kconfig:5: symbol BLOCK is selected by UBIFS_FS
> >> fs/ubifs/Kconfig:1: symbol UBIFS_FS depends on MISC_FILESYSTEMS
> >> fs/Kconfig:227: symbol MISC_FILESYSTEMS is selected by ACPI_APEI
> >> drivers/acpi/apei/Kconfig:8: symbol ACPI_APEI depends on ACPI
> >> drivers/acpi/Kconfig:9: symbol ACPI depends on ARCH_SUPPORTS_ACPI
> >> drivers/acpi/Kconfig:6: symbol ARCH_SUPPORTS_ACPI is selected by IA64_HP_SIM
> >> arch/ia64/Kconfig:202: symbol IA64_HP_SIM is part of choice <choice>
>    For a resolution refer to Documentation/kbuild/kconfig-language.txt
>    subsection "Kconfig recursive dependency limitations"
> 
> vim +128 arch/ia64/Kconfig
> 
> ^1da177e4 Linus Torvalds             2005-04-16    8  
> ^1da177e4 Linus Torvalds             2005-04-16    9  config IA64
> ^1da177e4 Linus Torvalds             2005-04-16   10  	bool
> 468bcf08f Mark Salter                2013-10-07   11  	select ARCH_MIGHT_HAVE_PC_PARPORT
> bbc4e5969 Mark Salter                2014-01-01   12  	select ARCH_MIGHT_HAVE_PC_SERIO
> 06f87adff Len Brown                  2007-01-26   13  	select ACPI if (!IA64_HP_SIM)
> 2c870e611 Arnd Bergmann              2018-07-24   14  	select ARCH_SUPPORTS_ACPI if (!IA64_HP_SIM)
> 6e0a0ea12 Graeme Gregory             2015-03-24   15  	select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
> 46ba51ea8 Hanjun Guo                 2014-07-18   16  	select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
> eb01d42a7 Christoph Hellwig          2018-11-15   17  	select FORCE_PCI if (!IA64_HP_SIM)
> 2eac9c2df Christoph Hellwig          2018-11-15   18  	select PCI_DOMAINS if PCI
> 20f1b79d3 Christoph Hellwig          2018-11-15   19  	select PCI_SYSCALL if PCI
> 0773a6cf6 Tony Luck                  2009-01-15   20  	select HAVE_UNSTABLE_SCHED_CLOCK
> 5f56a5dfd Jiri Slaby                 2016-05-20   21  	select HAVE_EXIT_THREAD
> ec7748b59 Sam Ravnborg               2008-02-09   22  	select HAVE_IDE
> 42d4b839c Mathieu Desnoyers          2008-02-02   23  	select HAVE_OPROFILE
> 3f550096d Mathieu Desnoyers          2008-02-02   24  	select HAVE_KPROBES
> 9edddaa20 Ananth N Mavinakayanahalli 2008-03-04   25  	select HAVE_KRETPROBES
> a14a07b80 Shaohua Li                 2009-01-09   26  	select HAVE_FTRACE_MCOUNT_RECORD
> a14a07b80 Shaohua Li                 2009-01-09   27  	select HAVE_DYNAMIC_FTRACE if (!ITANIUM)
> d3e75ff14 Shaohua Li                 2009-01-09   28  	select HAVE_FUNCTION_TRACER
> 6035d9db3 Josh Triplett              2014-04-07   29  	select TTY
> 9690ad031 Shaohua Li                 2008-10-01   30  	select HAVE_ARCH_TRACEHOOK
> 98e4ae8af Tejun Heo                  2011-12-08   31  	select HAVE_MEMBLOCK_NODE_MAP
> b952741c8 Frederic Weisbecker        2012-06-16   32  	select HAVE_VIRT_CPU_ACCOUNTING
> 8ee94e3fc Christoph Hellwig          2018-12-15   33  	select ARCH_HAS_DMA_COHERENT_TO_PFN if SWIOTLB
> 3fed6ae4b Christoph Hellwig          2019-01-04   34  	select ARCH_HAS_SYNC_DMA_FOR_CPU if SWIOTLB
> 4febd95a8 Stephen Rothwell           2013-03-07   35  	select VIRT_TO_BUS
> 98e4ae8af Tejun Heo                  2011-12-08   36  	select ARCH_DISCARD_MEMBLOCK
> c5e66129c Thomas Gleixner            2011-01-19   37  	select GENERIC_IRQ_PROBE
> c5e66129c Thomas Gleixner            2011-01-19   38  	select GENERIC_PENDING_IRQ if SMP
> e3d781227 Thomas Gleixner            2011-03-25   39  	select GENERIC_IRQ_SHOW
> 4debd723f Thomas Gleixner            2014-05-07   40  	select GENERIC_IRQ_LEGACY
> df013ffb8 Huang Ying                 2011-07-13   41  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
> 4673ca8eb Michael S. Tsirkin         2011-11-24   42  	select GENERIC_IOMAP
> 13583bf15 Thomas Gleixner            2012-04-20   43  	select GENERIC_SMP_IDLE_THREAD
> 0500871f2 David Howells              2018-01-02   44  	select ARCH_TASK_STRUCT_ON_STACK
> f5e102873 Thomas Gleixner            2012-05-05   45  	select ARCH_TASK_STRUCT_ALLOCATOR
> b235beea9 Linus Torvalds             2016-06-24   46  	select ARCH_THREAD_STACK_ALLOCATOR
> 21b19710a Anna-Maria Gleixner        2012-05-18   47  	select ARCH_CLOCKSOURCE_DATA
> d4d1fc61e Tony Luck                  2017-10-31   48  	select GENERIC_TIME_VSYSCALL
> b6fca7253 Vineet Gupta               2013-01-09   49  	select SYSCTL_ARCH_UNALIGN_NO_WARN
> 786d35d45 David Howells              2012-09-28   50  	select HAVE_MOD_ARCH_SPECIFIC
> 786d35d45 David Howells              2012-09-28   51  	select MODULES_USE_ELF_RELA
> 71c7356f8 Tony Luck                  2013-09-03   52  	select ARCH_USE_CMPXCHG_LOCKREF
> 7a0177212 AKASHI Takahiro            2014-02-25   53  	select HAVE_ARCH_AUDITSYSCALL
> f616ab59c Christoph Hellwig          2018-05-09   54  	select NEED_DMA_MAP_STATE
> 86596f0a2 Christoph Hellwig          2018-04-05   55  	select NEED_SG_DMA_LENGTH
> ^1da177e4 Linus Torvalds             2005-04-16   56  	default y
> ^1da177e4 Linus Torvalds             2005-04-16   57  	help
> ^1da177e4 Linus Torvalds             2005-04-16   58  	  The Itanium Processor Family is Intel's 64-bit successor to
> ^1da177e4 Linus Torvalds             2005-04-16   59  	  the 32-bit X86 line.  The IA-64 Linux project has a home
> ^1da177e4 Linus Torvalds             2005-04-16   60  	  page at <http://www.linuxia64.org/> and a mailing list at
> ^1da177e4 Linus Torvalds             2005-04-16   61  	  <linux-ia64@vger.kernel.org>.
> ^1da177e4 Linus Torvalds             2005-04-16   62  
> ^1da177e4 Linus Torvalds             2005-04-16   63  config 64BIT
> ^1da177e4 Linus Torvalds             2005-04-16   64  	bool
> 9f271d576 Zhang, Yanmin              2007-02-09   65  	select ATA_NONSTANDARD if ATA
> ^1da177e4 Linus Torvalds             2005-04-16   66  	default y
> ^1da177e4 Linus Torvalds             2005-04-16   67  
> d5c23ebf1 Christoph Hellwig          2017-12-24   68  config ZONE_DMA32
> 09ae1f585 Christoph Lameter          2007-02-10   69  	def_bool y
> 09ae1f585 Christoph Lameter          2007-02-10   70  	depends on !IA64_SGI_SN2
> 66701b149 Christoph Lameter          2007-02-10   71  
> 2bd62a40f Christoph Lameter          2007-05-10   72  config QUICKLIST
> 2bd62a40f Christoph Lameter          2007-05-10   73  	bool
> 2bd62a40f Christoph Lameter          2007-05-10   74  	default y
> 2bd62a40f Christoph Lameter          2007-05-10   75  
> ^1da177e4 Linus Torvalds             2005-04-16   76  config MMU
> ^1da177e4 Linus Torvalds             2005-04-16   77  	bool
> ^1da177e4 Linus Torvalds             2005-04-16   78  	default y
> ^1da177e4 Linus Torvalds             2005-04-16   79  
> 85718fae2 Tony Luck                  2010-09-23   80  config STACKTRACE_SUPPORT
> 85718fae2 Tony Luck                  2010-09-23   81  	def_bool y
> 85718fae2 Tony Luck                  2010-09-23   82  
> 95c354fe9 Nick Piggin                2008-01-30   83  config GENERIC_LOCKBREAK
> 2c86963b0 Tony Luck                  2009-09-25   84  	def_bool n
> 95c354fe9 Nick Piggin                2008-01-30   85  
> ^1da177e4 Linus Torvalds             2005-04-16   86  config RWSEM_XCHGADD_ALGORITHM
> ^1da177e4 Linus Torvalds             2005-04-16   87  	bool
> ^1da177e4 Linus Torvalds             2005-04-16   88  	default y
> ^1da177e4 Linus Torvalds             2005-04-16   89  
> d9c234005 Mel Gorman                 2007-10-16   90  config HUGETLB_PAGE_SIZE_VARIABLE
> d9c234005 Mel Gorman                 2007-10-16   91  	bool
> d9c234005 Mel Gorman                 2007-10-16   92  	depends on HUGETLB_PAGE
> d9c234005 Mel Gorman                 2007-10-16   93  	default y
> d9c234005 Mel Gorman                 2007-10-16   94  
> ^1da177e4 Linus Torvalds             2005-04-16   95  config GENERIC_CALIBRATE_DELAY
> ^1da177e4 Linus Torvalds             2005-04-16   96  	bool
> ^1da177e4 Linus Torvalds             2005-04-16   97  	default y
> ^1da177e4 Linus Torvalds             2005-04-16   98  
> 988c388ad travis@sgi.com             2008-01-30   99  config HAVE_SETUP_PER_CPU_AREA
> b32ef636a travis@sgi.com             2008-01-30  100  	def_bool y
> b32ef636a travis@sgi.com             2008-01-30  101  
> 3ed3bce84 Matt Domsch                2006-03-26  102  config DMI
> 3ed3bce84 Matt Domsch                2006-03-26  103  	bool
> 3ed3bce84 Matt Domsch                2006-03-26  104  	default y
> cf0744021 Ard Biesheuvel             2014-01-23  105  	select DMI_SCAN_MACHINE_NON_EFI_FALLBACK
> 3ed3bce84 Matt Domsch                2006-03-26  106  
> ^1da177e4 Linus Torvalds             2005-04-16  107  config EFI
> ^1da177e4 Linus Torvalds             2005-04-16  108  	bool
> a614e1923 Matt Fleming               2013-04-30  109  	select UCS2_STRING
> ^1da177e4 Linus Torvalds             2005-04-16  110  	default y
> ^1da177e4 Linus Torvalds             2005-04-16  111  
> ae1e9130b Ingo Molnar                2008-11-11  112  config SCHED_OMIT_FRAME_POINTER
> 7d12e522b Anton Blanchard            2005-05-05  113  	bool
> 7d12e522b Anton Blanchard            2005-05-05  114  	default y
> 7d12e522b Anton Blanchard            2005-05-05  115  
> f14f75b81 Jes Sorensen               2005-06-21  116  config IA64_UNCACHED_ALLOCATOR
> f14f75b81 Jes Sorensen               2005-06-21  117  	bool
> f14f75b81 Jes Sorensen               2005-06-21  118  	select GENERIC_ALLOCATOR
> f14f75b81 Jes Sorensen               2005-06-21  119  
> 46cf98cda Venkatesh Pallipadi        2009-07-10  120  config ARCH_USES_PG_UNCACHED
> 46cf98cda Venkatesh Pallipadi        2009-07-10  121  	def_bool y
> 46cf98cda Venkatesh Pallipadi        2009-07-10  122  	depends on IA64_UNCACHED_ALLOCATOR
> 46cf98cda Venkatesh Pallipadi        2009-07-10  123  
> e65e1fc2d Al Viro                    2006-09-12  124  config AUDIT_ARCH
> e65e1fc2d Al Viro                    2006-09-12  125  	bool
> e65e1fc2d Al Viro                    2006-09-12  126  	default y
> e65e1fc2d Al Viro                    2006-09-12  127  
> ^1da177e4 Linus Torvalds             2005-04-16 @128  choice
> ^1da177e4 Linus Torvalds             2005-04-16  129  	prompt "System type"
> ^1da177e4 Linus Torvalds             2005-04-16  130  	default IA64_GENERIC
> ^1da177e4 Linus Torvalds             2005-04-16  131  
> ^1da177e4 Linus Torvalds             2005-04-16  132  config IA64_GENERIC
> ^1da177e4 Linus Torvalds             2005-04-16  133  	bool "generic"
> ^1da177e4 Linus Torvalds             2005-04-16  134  	select NUMA
> ^1da177e4 Linus Torvalds             2005-04-16  135  	select ACPI_NUMA
> d1598e05f Jan Beulich                2007-01-03  136  	select SWIOTLB
> 62fdd7678 Fenghua Yu                 2008-10-17  137  	select PCI_MSI
> ^1da177e4 Linus Torvalds             2005-04-16  138  	help
> ^1da177e4 Linus Torvalds             2005-04-16  139  	  This selects the system type of your hardware.  A "generic" kernel
> ^1da177e4 Linus Torvalds             2005-04-16  140  	  will run on any supported IA-64 system.  However, if you configure
> ^1da177e4 Linus Torvalds             2005-04-16  141  	  a kernel for your specific system, it will be faster and smaller.
> ^1da177e4 Linus Torvalds             2005-04-16  142  
> ^1da177e4 Linus Torvalds             2005-04-16  143  	  generic		For any supported IA-64 system
> ^1da177e4 Linus Torvalds             2005-04-16  144  	  DIG-compliant		For DIG ("Developer's Interface Guide") compliant systems
> 62fdd7678 Fenghua Yu                 2008-10-17  145  	  DIG+Intel+IOMMU	For DIG systems with Intel IOMMU
> ^1da177e4 Linus Torvalds             2005-04-16  146  	  HP-zx1/sx1000		For HP systems
> ^1da177e4 Linus Torvalds             2005-04-16  147  	  HP-zx1/sx1000+swiotlb	For HP systems with (broken) DMA-constrained devices.
> ^1da177e4 Linus Torvalds             2005-04-16  148  	  SGI-SN2		For SGI Altix systems
> 222466149 Jack Steiner               2008-05-06  149  	  SGI-UV		For SGI UV systems
> ^1da177e4 Linus Torvalds             2005-04-16  150  	  Ski-simulator		For the HP simulator <http://www.hpl.hp.com/research/linux/ski/>
> ^1da177e4 Linus Torvalds             2005-04-16  151  
> ^1da177e4 Linus Torvalds             2005-04-16  152  	  If you don't know what to do, choose "generic".
> ^1da177e4 Linus Torvalds             2005-04-16  153  
> ^1da177e4 Linus Torvalds             2005-04-16  154  config IA64_DIG
> ^1da177e4 Linus Torvalds             2005-04-16  155  	bool "DIG-compliant"
> d1598e05f Jan Beulich                2007-01-03  156  	select SWIOTLB
> ^1da177e4 Linus Torvalds             2005-04-16  157  
> 62fdd7678 Fenghua Yu                 2008-10-17  158  config IA64_DIG_VTD
> 62fdd7678 Fenghua Yu                 2008-10-17  159  	bool "DIG+Intel+IOMMU"
> 96edc754a Paul Bolle                 2013-03-05  160  	select INTEL_IOMMU
> 62fdd7678 Fenghua Yu                 2008-10-17  161  	select PCI_MSI
> 62fdd7678 Fenghua Yu                 2008-10-17  162  
> ^1da177e4 Linus Torvalds             2005-04-16  163  config IA64_HP_ZX1
> ^1da177e4 Linus Torvalds             2005-04-16  164  	bool "HP-zx1/sx1000"
> ^1da177e4 Linus Torvalds             2005-04-16  165  	help
> ^1da177e4 Linus Torvalds             2005-04-16  166  	  Build a kernel that runs on HP zx1 and sx1000 systems.  This adds
> ^1da177e4 Linus Torvalds             2005-04-16  167  	  support for the HP I/O MMU.
> ^1da177e4 Linus Torvalds             2005-04-16  168  
> ^1da177e4 Linus Torvalds             2005-04-16  169  config IA64_HP_ZX1_SWIOTLB
> ^1da177e4 Linus Torvalds             2005-04-16  170  	bool "HP-zx1/sx1000 with software I/O TLB"
> d1598e05f Jan Beulich                2007-01-03  171  	select SWIOTLB
> ^1da177e4 Linus Torvalds             2005-04-16  172  	help
> ^1da177e4 Linus Torvalds             2005-04-16  173  	  Build a kernel that runs on HP zx1 and sx1000 systems even when they
> ^1da177e4 Linus Torvalds             2005-04-16  174  	  have broken PCI devices which cannot DMA to full 32 bits.  Apart
> ^1da177e4 Linus Torvalds             2005-04-16  175  	  from support for the HP I/O MMU, this includes support for the software
> ^1da177e4 Linus Torvalds             2005-04-16  176  	  I/O TLB, which allows supporting the broken devices at the expense of
> ^1da177e4 Linus Torvalds             2005-04-16  177  	  wasting some kernel memory (about 2MB by default).
> ^1da177e4 Linus Torvalds             2005-04-16  178  
> ^1da177e4 Linus Torvalds             2005-04-16  179  config IA64_SGI_SN2
> ^1da177e4 Linus Torvalds             2005-04-16  180  	bool "SGI-SN2"
> bd3be240c Jes Sorensen               2008-02-11  181  	select NUMA
> bd3be240c Jes Sorensen               2008-02-11  182  	select ACPI_NUMA
> ^1da177e4 Linus Torvalds             2005-04-16  183  	help
> ^1da177e4 Linus Torvalds             2005-04-16  184  	  Selecting this option will optimize the kernel for use on sn2 based
> ^1da177e4 Linus Torvalds             2005-04-16  185  	  systems, but the resulting kernel binary will not run on other
> ^1da177e4 Linus Torvalds             2005-04-16  186  	  types of ia64 systems.  If you have an SGI Altix system, it's safe
> ^1da177e4 Linus Torvalds             2005-04-16  187  	  to select this option.  If in doubt, select ia64 generic support
> ^1da177e4 Linus Torvalds             2005-04-16  188  	  instead.
> ^1da177e4 Linus Torvalds             2005-04-16  189  
> 3351ab9b3 Jack Steiner               2008-07-31  190  config IA64_SGI_UV
> 3351ab9b3 Jack Steiner               2008-07-31  191  	bool "SGI-UV"
> 222466149 Jack Steiner               2008-05-06  192  	select NUMA
> 222466149 Jack Steiner               2008-05-06  193  	select ACPI_NUMA
> 222466149 Jack Steiner               2008-05-06  194  	select SWIOTLB
> 222466149 Jack Steiner               2008-05-06  195  	help
> 222466149 Jack Steiner               2008-05-06  196  	  Selecting this option will optimize the kernel for use on UV based
> 222466149 Jack Steiner               2008-05-06  197  	  systems, but the resulting kernel binary will not run on other
> 222466149 Jack Steiner               2008-05-06  198  	  types of ia64 systems.  If you have an SGI UV system, it's safe
> 222466149 Jack Steiner               2008-05-06  199  	  to select this option.  If in doubt, select ia64 generic support
> 222466149 Jack Steiner               2008-05-06  200  	  instead.
> 222466149 Jack Steiner               2008-05-06  201  
> ^1da177e4 Linus Torvalds             2005-04-16 @202  config IA64_HP_SIM
> ^1da177e4 Linus Torvalds             2005-04-16  203  	bool "Ski-simulator"
> d1598e05f Jan Beulich                2007-01-03  204  	select SWIOTLB
> 1b3e3aa6c Rafael J. Wysocki          2014-12-13  205  	depends on !PM
> ^1da177e4 Linus Torvalds             2005-04-16  206  
> 
> :::::: The code at line 128 was first introduced by commit
> :::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
> 
> :::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
> :::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
