Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B578E6B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 22:49:46 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so3269073pab.6
        for <linux-mm@kvack.org>; Fri, 16 May 2014 19:49:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id in9si333681pbd.10.2014.05.16.19.49.45
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 19:49:45 -0700 (PDT)
Date: Sat, 17 May 2014 10:48:44 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] sound/core/pcm_native.c:80:8: warning:
 excess elements in struct initializer
Message-ID: <5376ce0c.9MHvuuk5PX41gvKB%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ff35dad6205c66d96feda494502753e5ed1b10f1
commit: 67039d034b422b074af336ebf8101346b6b5d441 [446/499] rwsem: Support optimistic spinning
config: make ARCH=arm tegra_defconfig

All warnings:

>> sound/core/pcm_native.c:80:8: warning: excess elements in struct initializer [enabled by default]
>> sound/core/pcm_native.c:80:8: warning: (near initialization for 'snd_pcm_link_rwsem') [enabled by default]
>> sound/core/pcm_native.c:80:8: warning: excess elements in struct initializer [enabled by default]
>> sound/core/pcm_native.c:80:8: warning: (near initialization for 'snd_pcm_link_rwsem') [enabled by default]
--
>> sound/core/control.c:42:8: warning: excess elements in struct initializer [enabled by default]
>> sound/core/control.c:42:8: warning: (near initialization for 'snd_ioctl_rwsem') [enabled by default]
>> sound/core/control.c:42:8: warning: excess elements in struct initializer [enabled by default]
>> sound/core/control.c:42:8: warning: (near initialization for 'snd_ioctl_rwsem') [enabled by default]
--
>> drivers/cpufreq/cpufreq.c:60:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/cpufreq/cpufreq.c:60:8: warning: (near initialization for 'cpufreq_rwsem') [enabled by default]
>> drivers/cpufreq/cpufreq.c:60:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/cpufreq/cpufreq.c:60:8: warning: (near initialization for 'cpufreq_rwsem') [enabled by default]
>> drivers/cpufreq/cpufreq.c:75:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/cpufreq/cpufreq.c:75:8: warning: (near initialization for 'cpufreq_policy_notifier_list.rwsem') [enabled by default]
>> drivers/cpufreq/cpufreq.c:75:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/cpufreq/cpufreq.c:75:8: warning: (near initialization for 'cpufreq_policy_notifier_list.rwsem') [enabled by default]
--
>> net/bluetooth/bnep/core.c:46:8: warning: excess elements in struct initializer [enabled by default]
>> net/bluetooth/bnep/core.c:46:8: warning: (near initialization for 'bnep_session_sem') [enabled by default]
>> net/bluetooth/bnep/core.c:46:8: warning: excess elements in struct initializer [enabled by default]
>> net/bluetooth/bnep/core.c:46:8: warning: (near initialization for 'bnep_session_sem') [enabled by default]
--
>> net/bluetooth/hidp/core.c:38:8: warning: excess elements in struct initializer [enabled by default]
>> net/bluetooth/hidp/core.c:38:8: warning: (near initialization for 'hidp_session_sem') [enabled by default]
>> net/bluetooth/hidp/core.c:38:8: warning: excess elements in struct initializer [enabled by default]
>> net/bluetooth/hidp/core.c:38:8: warning: (near initialization for 'hidp_session_sem') [enabled by default]

vim +80 sound/core/pcm_native.c

877211f5e Takashi Iwai    2005-11-17  64  #define SNDRV_PCM_IOCTL_HW_PARAMS_OLD _IOWR('A', 0x11, struct snd_pcm_hw_params_old)
^1da177e4 Linus Torvalds  2005-04-16  65  
877211f5e Takashi Iwai    2005-11-17  66  static int snd_pcm_hw_refine_old_user(struct snd_pcm_substream *substream,
877211f5e Takashi Iwai    2005-11-17  67  				      struct snd_pcm_hw_params_old __user * _oparams);
877211f5e Takashi Iwai    2005-11-17  68  static int snd_pcm_hw_params_old_user(struct snd_pcm_substream *substream,
877211f5e Takashi Iwai    2005-11-17  69  				      struct snd_pcm_hw_params_old __user * _oparams);
59d485825 Takashi Iwai    2005-12-01  70  #endif
f87135f56 Clemens Ladisch 2005-11-20  71  static int snd_pcm_open(struct file *file, struct snd_pcm *pcm, int stream);
^1da177e4 Linus Torvalds  2005-04-16  72  
^1da177e4 Linus Torvalds  2005-04-16  73  /*
^1da177e4 Linus Torvalds  2005-04-16  74   *
^1da177e4 Linus Torvalds  2005-04-16  75   */
^1da177e4 Linus Torvalds  2005-04-16  76  
^1da177e4 Linus Torvalds  2005-04-16  77  DEFINE_RWLOCK(snd_pcm_link_rwlock);
e88e8ae63 Takashi Iwai    2006-04-28  78  EXPORT_SYMBOL(snd_pcm_link_rwlock);
^1da177e4 Linus Torvalds  2005-04-16  79  
e88e8ae63 Takashi Iwai    2006-04-28 @80  static DECLARE_RWSEM(snd_pcm_link_rwsem);
^1da177e4 Linus Torvalds  2005-04-16  81  
^1da177e4 Linus Torvalds  2005-04-16  82  static inline mm_segment_t snd_enter_user(void)
^1da177e4 Linus Torvalds  2005-04-16  83  {
^1da177e4 Linus Torvalds  2005-04-16  84  	mm_segment_t fs = get_fs();
^1da177e4 Linus Torvalds  2005-04-16  85  	set_fs(get_ds());
^1da177e4 Linus Torvalds  2005-04-16  86  	return fs;
^1da177e4 Linus Torvalds  2005-04-16  87  }
^1da177e4 Linus Torvalds  2005-04-16  88  

:::::: The code at line 80 was first introduced by commit
:::::: e88e8ae639a4908b903d9406c54e99a729b01a28 [ALSA] Move OSS-specific hw_params helper to snd-pcm-oss module

:::::: TO: Takashi Iwai <tiwai@suse.de>
:::::: CC: Jaroslav Kysela <perex@suse.cz>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
