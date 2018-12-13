Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0FA78E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 04:06:43 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y88so1156780pfi.9
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 01:06:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t19si1172407pgk.163.2018.12.13.01.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 01:06:42 -0800 (PST)
Date: Thu, 13 Dec 2018 17:05:43 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Message-ID: <201812131750.pPiUx918%fengguang.wu@intel.com>
References: <20181211010310.8551-2-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
In-Reply-To: <20181211010310.8551-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith,

I love your patch! Yet something to improve:

[auto build test ERROR on pm/linux-next]
[also build test ERROR on v4.20-rc6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Keith-Busch/acpi-Create-subtable-parsing-infrastructure/20181211-154110
base:   https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git linux-next
config: ia64-allnoconfig (attached as .config)
compiler: ia64-linux-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=ia64 

All errors (new ones prefixed by >>):

   arch/ia64/kernel/acpi.c: In function 'early_acpi_boot_init':
>> arch/ia64/kernel/acpi.c:675:3: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
      acpi_parse_lsapic, NR_CPUS);
      ^~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c: In function 'acpi_boot_init':
   arch/ia64/kernel/acpi.c:718:43: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
         (ACPI_MADT_TYPE_LOCAL_APIC_OVERRIDE, acpi_parse_lapic_addr_ovr, 0) < 0)
                                              ^~~~~~~~~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c:722:59: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
     if (acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_APIC_NMI, acpi_parse_lapic_nmi, 0)
                                                              ^~~~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c:729:32: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
         (ACPI_MADT_TYPE_IO_SAPIC, acpi_parse_iosapic, NR_IOSAPICS) < 1) {
                                   ^~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c:738:40: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
         (ACPI_MADT_TYPE_INTERRUPT_SOURCE, acpi_parse_plat_int_src,
                                           ^~~~~~~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c:744:42: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
         (ACPI_MADT_TYPE_INTERRUPT_OVERRIDE, acpi_parse_int_src_ovr, 0) < 0)
                                             ^~~~~~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   arch/ia64/kernel/acpi.c:748:55: error: passing argument 2 of 'acpi_table_parse_madt' from incompatible pointer type [-Werror=incompatible-pointer-types]
     if (acpi_table_parse_madt(ACPI_MADT_TYPE_NMI_SOURCE, acpi_parse_nmi_src, 0) < 0)
                                                          ^~~~~~~~~~~~~~~~~~
   In file included from arch/ia64/kernel/acpi.c:43:
   include/linux/acpi.h:250:29: note: expected 'acpi_tbl_entry_handler' {aka 'int (*)(union acpi_subtable_headers *, const long unsigned int)'} but argument is of type 'int (*)(struct acpi_subtable_header *, const long unsigned int)'
         acpi_tbl_entry_handler handler,
         ~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
   cc1: some warnings being treated as errors

vim +/acpi_table_parse_madt +675 arch/ia64/kernel/acpi.c

^1da177e4 Linus Torvalds 2005-04-16  660  
62ee0540f Doug Chapman   2008-11-05  661  int __init early_acpi_boot_init(void)
62ee0540f Doug Chapman   2008-11-05  662  {
62ee0540f Doug Chapman   2008-11-05  663  	int ret;
62ee0540f Doug Chapman   2008-11-05  664  
62ee0540f Doug Chapman   2008-11-05  665  	/*
62ee0540f Doug Chapman   2008-11-05  666  	 * do a partial walk of MADT to determine how many CPUs
62ee0540f Doug Chapman   2008-11-05  667  	 * we have including offline CPUs
62ee0540f Doug Chapman   2008-11-05  668  	 */
62ee0540f Doug Chapman   2008-11-05  669  	if (acpi_table_parse(ACPI_SIG_MADT, acpi_parse_madt)) {
62ee0540f Doug Chapman   2008-11-05  670  		printk(KERN_ERR PREFIX "Can't find MADT\n");
62ee0540f Doug Chapman   2008-11-05  671  		return 0;
62ee0540f Doug Chapman   2008-11-05  672  	}
62ee0540f Doug Chapman   2008-11-05  673  
62ee0540f Doug Chapman   2008-11-05  674  	ret = acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_SAPIC,
62ee0540f Doug Chapman   2008-11-05 @675  		acpi_parse_lsapic, NR_CPUS);
62ee0540f Doug Chapman   2008-11-05  676  	if (ret < 1)
62ee0540f Doug Chapman   2008-11-05  677  		printk(KERN_ERR PREFIX
62ee0540f Doug Chapman   2008-11-05  678  		       "Error parsing MADT - no LAPIC entries\n");
247dba58a Baoquan He     2014-05-05  679  	else
247dba58a Baoquan He     2014-05-05  680  		acpi_lapic = 1;
62ee0540f Doug Chapman   2008-11-05  681  

:::::: The code at line 675 was first introduced by commit
:::::: 62ee0540f5e5a804b79cae8b3c0185a85f02436b [IA64] fix boot panic caused by offline CPUs

:::::: TO: Doug Chapman <doug.chapman@hp.com>
:::::: CC: Tony Luck <tony.luck@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--bg08WKrSYDhXBjb5
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--bg08WKrSYDhXBjb5--
