Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id A865B6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:46:20 -0500 (EST)
Received: by ioir85 with SMTP id r85so80239858ioi.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:46:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 83si40448508pfl.23.2015.11.26.00.46.19
        for <linux-mm@kvack.org>;
        Thu, 26 Nov 2015 00:46:19 -0800 (PST)
Date: Thu, 26 Nov 2015 16:45:21 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 3174/3442] fs/ocfs2/file.c:2297:3: note: in
 expansion of macro 'xchg'
Message-ID: <201511261619.Q4kX5Hst%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryan Ding <ryan.ding@oracle.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   7dd2ecb6facfd1ac1a1cccc908e88e20e65e5801
commit: 5d974dfe80b2322a6b0afc85beb15fe9bc233804 [3174/3442] ocfs2: fix ip_unaligned_aio deadlock with dio work queue
config: m68k-sun3_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5d974dfe80b2322a6b0afc85beb15fe9bc233804
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All warnings (new ones prefixed by >>):

   In file included from arch/m68k/include/asm/atomic.h:6:0,
                    from include/linux/atomic.h:4,
                    from include/linux/spinlock.h:406,
                    from include/linux/wait.h:8,
                    from include/linux/fs.h:5,
                    from fs/ocfs2/file.c:27:
   fs/ocfs2/file.c: In function 'ocfs2_file_write_iter':
   arch/m68k/include/asm/cmpxchg.h:78:22: warning: value computed is not used [-Wunused-value]
    #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
                         ^
>> fs/ocfs2/file.c:2297:3: note: in expansion of macro 'xchg'
      xchg(&iocb->ki_complete, saved_ki_complete);
      ^

vim +/xchg +2297 fs/ocfs2/file.c

  2281				written = ret;
  2282	
  2283			if (!ret) {
  2284				ret = jbd2_journal_force_commit(osb->journal->j_journal);
  2285				if (ret < 0)
  2286					written = ret;
  2287			}
  2288	
  2289			if (!ret)
  2290				ret = filemap_fdatawait_range(file->f_mapping,
  2291							      iocb->ki_pos - written,
  2292							      iocb->ki_pos - 1);
  2293		}
  2294	
  2295	out:
  2296		if (saved_ki_complete)
> 2297			xchg(&iocb->ki_complete, saved_ki_complete);
  2298	
  2299		if (rw_level != -1)
  2300			ocfs2_rw_unlock(inode, rw_level);
  2301	
  2302	out_mutex:
  2303		mutex_unlock(&inode->i_mutex);
  2304	
  2305		if (written)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--0F1p//8PRICkK4MW
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--0F1p//8PRICkK4MW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
