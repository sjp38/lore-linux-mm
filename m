Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1C36B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:24:16 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so8304142pad.16
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:24:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tx4si28051775pbc.24.2014.09.16.01.24.09
        for <linux-mm@kvack.org>;
        Tue, 16 Sep 2014 01:24:10 -0700 (PDT)
Date: Tue, 16 Sep 2014 16:23:19 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 5942/5973]
 drivers/net/wireless/hostap/hostap_proc.c:171:6: warning: unused variable
 'i'
Message-ID: <5417f377.QBIorNJRsAKXIipj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   cac2183332bf304f5abf54e5dc715a4b5c18da06
commit: 8410495acbb7a56d7060adeb5af1a1e616ecb916 [5942/5973] wireless: hostap: proc: print properly escaped SSID
config: i386-allyesconfig
reproduce:
  git checkout 8410495acbb7a56d7060adeb5af1a1e616ecb916
  make ARCH=i386  allyesconfig
  make ARCH=i386 

All warnings:

   drivers/net/wireless/hostap/hostap_proc.c: In function 'prism2_bss_list_proc_show':
>> drivers/net/wireless/hostap/hostap_proc.c:171:6: warning: unused variable 'i' [-Wunused-variable]
     int i;
         ^

vim +/i +171 drivers/net/wireless/hostap/hostap_proc.c

6bbefe86 David Howells 2013-04-10  155  	return ret;
ff1d2767 Jouni Malinen 2005-05-12  156  }
ff1d2767 Jouni Malinen 2005-05-12  157  
6bbefe86 David Howells 2013-04-10  158  static const struct file_operations prism2_wds_proc_fops = {
6bbefe86 David Howells 2013-04-10  159  	.open		= prism2_wds_proc_open,
6bbefe86 David Howells 2013-04-10  160  	.read		= seq_read,
6bbefe86 David Howells 2013-04-10  161  	.llseek		= seq_lseek,
6bbefe86 David Howells 2013-04-10  162  	.release	= seq_release,
6bbefe86 David Howells 2013-04-10  163  };
ff1d2767 Jouni Malinen 2005-05-12  164  
6bbefe86 David Howells 2013-04-10  165  
6bbefe86 David Howells 2013-04-10  166  static int prism2_bss_list_proc_show(struct seq_file *m, void *v)
ff1d2767 Jouni Malinen 2005-05-12  167  {
6bbefe86 David Howells 2013-04-10  168  	local_info_t *local = m->private;
6bbefe86 David Howells 2013-04-10  169  	struct list_head *ptr = v;
ff1d2767 Jouni Malinen 2005-05-12  170  	struct hostap_bss_info *bss;
ff1d2767 Jouni Malinen 2005-05-12 @171  	int i;
ff1d2767 Jouni Malinen 2005-05-12  172  
6bbefe86 David Howells 2013-04-10  173  	if (ptr == &local->bss_list) {
6bbefe86 David Howells 2013-04-10  174  		seq_printf(m, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
6bbefe86 David Howells 2013-04-10  175  			   "SSID(hex)\tWPA IE\n");
ff1d2767 Jouni Malinen 2005-05-12  176  		return 0;
ff1d2767 Jouni Malinen 2005-05-12  177  	}
ff1d2767 Jouni Malinen 2005-05-12  178  
ff1d2767 Jouni Malinen 2005-05-12  179  	bss = list_entry(ptr, struct hostap_bss_info, list);

:::::: The code at line 171 was first introduced by commit
:::::: ff1d2767d5a43c85f944e86a45284b721f66196c Add HostAP wireless driver.

:::::: TO: Jouni Malinen <jkmaline@cc.hut.fi>
:::::: CC: Jeff Garzik <jgarzik@pobox.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
