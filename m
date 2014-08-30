Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 554F46B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 20:19:42 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id z10so1489739pdj.10
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 17:19:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bc2si1756393pbb.199.2014.08.29.17.19.41
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 17:19:41 -0700 (PDT)
Date: Sat, 30 Aug 2014 08:16:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 256/287]
 drivers/net/wireless/hostap/hostap_proc.c:184:2: warning: field width
 specifier '*' expects argument of type 'int', but argument 3 has type
 'size_t'
Message-ID: <540117d2.Tym4cZ1OUBEs2vvE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
commit: 5960020fb3589d619a226a3bb66c71f238cfbdff [256/287] wireless: hostap: proc: print properly escaped SSID
config: make ARCH=ia64 allmodconfig

All warnings:

   drivers/net/wireless/hostap/hostap_proc.c: In function 'prism2_bss_list_proc_show':
>> drivers/net/wireless/hostap/hostap_proc.c:184:2: warning: field width specifier '*' expects argument of type 'int', but argument 3 has type 'size_t' [-Wformat=]
     seq_printf(m, "%*pE", bss->ssid_len, bss->ssid);
     ^

vim +184 drivers/net/wireless/hostap/hostap_proc.c

   168		local_info_t *local = m->private;
   169		struct list_head *ptr = v;
   170		struct hostap_bss_info *bss;
   171		int i;
   172	
   173		if (ptr == &local->bss_list) {
   174			seq_printf(m, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
   175				   "SSID(hex)\tWPA IE\n");
   176			return 0;
   177		}
   178	
   179		bss = list_entry(ptr, struct hostap_bss_info, list);
   180		seq_printf(m, "%pM\t%lu\t%u\t0x%x\t",
   181			   bss->bssid, bss->last_update,
   182			   bss->count, bss->capab_info);
   183	
 > 184		seq_printf(m, "%*pE", bss->ssid_len, bss->ssid);
   185	
   186		seq_putc(m, '\t');
   187		for (i = 0; i < bss->ssid_len; i++)
   188			seq_printf(m, "%02x", bss->ssid[i]);
   189		seq_putc(m, '\t');
   190		for (i = 0; i < bss->wpa_ie_len; i++)
   191			seq_printf(m, "%02x", bss->wpa_ie[i]);
   192		seq_putc(m, '\n');

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
