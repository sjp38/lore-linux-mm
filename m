Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56EC96B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:35:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x63so16699584pfx.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:35:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k126si3402626pgc.176.2017.03.02.06.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:35:07 -0800 (PST)
Date: Thu, 2 Mar 2017 22:34:57 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 2/2] XArray: Convert IDR and add test suite
Message-ID: <201703022203.106yZXnX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228181343.16588-3-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hi Matthew,

[auto build test WARNING on linus/master]
[also build test WARNING on next-20170302]
[cannot apply to v4.10]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Matthew-Wilcox/Add-XArray/20170302-092723
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
   drivers/gpu/drm/drm_mode_config.c:369:9: sparse: Expected ; at end of statement
   drivers/gpu/drm/drm_mode_config.c:369:9: sparse: got {
   drivers/gpu/drm/drm_mode_config.c:370:9: sparse: Expected ; at end of statement
   drivers/gpu/drm/drm_mode_config.c:370:9: sparse: got {
>> drivers/gpu/drm/drm_mode_config.c:384:1: sparse: expected 'while' after 'do'
   drivers/gpu/drm/drm_mode_config.c:384:1: sparse: Expected ( after 'do-while'
   drivers/gpu/drm/drm_mode_config.c:384:1: sparse: got extern
   builtin:0:0: sparse: Expected } at end of compound statement
   builtin:0:0: sparse: got end-of-input
   builtin:0:0: sparse: expected 'while' after 'do'
   builtin:0:0: sparse: Expected } at end of function
   builtin:0:0: sparse: got end-of-input
   drivers/gpu/drm/drm_mode_config.c:371:9: sparse: undefined identifier 'ida_init'
   In file included from include/linux/kernfs.h:14:0,
                    from include/linux/sysfs.h:15,
                    from include/linux/kobject.h:21,
                    from include/linux/device.h:17,
                    from include/linux/i2c.h:30,
                    from include/drm/drm_crtc.h:28,
                    from include/drm/drm_encoder.h:28,
                    from drivers/gpu/drm/drm_mode_config.c:23:
   drivers/gpu/drm/drm_mode_config.c: In function 'drm_mode_config_init':
   include/linux/idr.h:25:1: error: expected expression before '{' token
    {       \
    ^
   include/linux/idr.h:30:11: note: in expansion of macro 'IDR_INIT'
     *(idr) = IDR_INIT(#idr)    \
              ^~~~~~~~
   drivers/gpu/drm/drm_mode_config.c:369:2: note: in expansion of macro 'idr_init'
     idr_init(&dev->mode_config.crtc_idr);
     ^~~~~~~~
   include/linux/idr.h:25:1: error: expected expression before '{' token
    {       \
    ^
   include/linux/idr.h:30:11: note: in expansion of macro 'IDR_INIT'
     *(idr) = IDR_INIT(#idr)    \
              ^~~~~~~~
   drivers/gpu/drm/drm_mode_config.c:370:2: note: in expansion of macro 'idr_init'
     idr_init(&dev->mode_config.tile_idr);
     ^~~~~~~~
   drivers/gpu/drm/drm_mode_config.c:371:2: error: implicit declaration of function 'ida_init' [-Werror=implicit-function-declaration]
     ida_init(&dev->mode_config.connector_ida);
     ^~~~~~~~
   cc1: some warnings being treated as errors
--
   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
   drivers/net/wireless/ath/ath10k/htt_tx.c:407:9: sparse: Expected ; at end of statement
   drivers/net/wireless/ath/ath10k/htt_tx.c:407:9: sparse: got {
>> drivers/net/wireless/ath/ath10k/htt_tx.c:426:1: sparse: expected 'while' after 'do'
   drivers/net/wireless/ath/ath10k/htt_tx.c:426:1: sparse: Expected ( after 'do-while'
   drivers/net/wireless/ath/ath10k/htt_tx.c:426:1: sparse: got static
   drivers/net/wireless/ath/ath10k/htt_tx.c:432:71: sparse: undefined identifier 'msdu_id'
   drivers/net/wireless/ath/ath10k/htt_tx.c:434:27: sparse: undefined identifier 'msdu_id'
   drivers/net/wireless/ath/ath10k/htt_tx.c:456:40: sparse: undefined identifier 'ath10k_htt_tx_clean_up_pending'
   In file included from include/linux/cgroup-defs.h:12:0,
                    from include/linux/sched.h:60,
                    from include/linux/kasan.h:4,
                    from include/linux/slab.h:118,
                    from include/linux/textsearch.h:8,
                    from include/linux/skbuff.h:30,
                    from include/linux/if_ether.h:23,
                    from include/linux/etherdevice.h:25,
                    from drivers/net/wireless/ath/ath10k/htt_tx.c:18:
   drivers/net/wireless/ath/ath10k/htt_tx.c: In function 'ath10k_htt_tx_start':
   include/linux/idr.h:25:1: error: expected expression before '{' token
    {       \
    ^
   include/linux/idr.h:30:11: note: in expansion of macro 'IDR_INIT'
     *(idr) = IDR_INIT(#idr)    \
              ^~~~~~~~
   drivers/net/wireless/ath/ath10k/htt_tx.c:407:2: note: in expansion of macro 'idr_init'
     idr_init(&htt->pending_tx);
     ^~~~~~~~
--
   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
   drivers/net/wireless/marvell/mwifiex/init.c:495:17: sparse: Expected ; at end of statement
   drivers/net/wireless/marvell/mwifiex/init.c:495:17: sparse: got {
>> drivers/net/wireless/marvell/mwifiex/init.c:498:9: sparse: expected 'while' after 'do'
   drivers/net/wireless/marvell/mwifiex/init.c:498:9: sparse: Expected ( after 'do-while'
   drivers/net/wireless/marvell/mwifiex/init.c:498:9: sparse: got return
   builtin:0:0: sparse: Expected } at end of function
   builtin:0:0: sparse: got end-of-input
   In file included from include/linux/cgroup-defs.h:12:0,
                    from include/linux/sched.h:60,
                    from include/linux/kasan.h:4,
                    from include/linux/slab.h:118,
                    from include/linux/textsearch.h:8,
                    from include/linux/skbuff.h:30,
                    from include/linux/if_ether.h:23,
                    from include/linux/ieee80211.h:21,
                    from drivers/net/wireless/marvell/mwifiex/decl.h:28,
                    from drivers/net/wireless/marvell/mwifiex/init.c:20:
   drivers/net/wireless/marvell/mwifiex/init.c: In function 'mwifiex_init_lock_list':
   include/linux/idr.h:25:1: error: expected expression before '{' token
    {       \
    ^
   include/linux/idr.h:30:11: note: in expansion of macro 'IDR_INIT'
     *(idr) = IDR_INIT(#idr)    \
              ^~~~~~~~
   drivers/net/wireless/marvell/mwifiex/init.c:495:3: note: in expansion of macro 'idr_init'
      idr_init(&priv->ack_status_frames);
      ^~~~~~~~
--
   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
   drivers/staging/unisys/visorhba/visorhba_main.c:1111:9: sparse: Expected ; at end of statement
   drivers/staging/unisys/visorhba/visorhba_main.c:1111:9: sparse: got {
>> drivers/staging/unisys/visorhba/visorhba_main.c:1142:1: sparse: expected 'while' after 'do'
   drivers/staging/unisys/visorhba/visorhba_main.c:1142:1: sparse: Expected ( after 'do-while'
   drivers/staging/unisys/visorhba/visorhba_main.c:1142:1: sparse: got static
   drivers/staging/unisys/visorhba/visorhba_main.c:1148:17: sparse: return with no return value
   drivers/staging/unisys/visorhba/visorhba_main.c:1171:19: sparse: undefined identifier 'visorhba_remove'
   In file included from include/linux/cgroup-defs.h:12:0,
                    from include/linux/sched.h:60,
                    from include/linux/kasan.h:4,
                    from include/linux/slab.h:118,
                    from include/linux/textsearch.h:8,
                    from include/linux/skbuff.h:30,
                    from drivers/staging/unisys/visorhba/visorhba_main.c:17:
   drivers/staging/unisys/visorhba/visorhba_main.c: In function 'visorhba_probe':
   include/linux/idr.h:25:1: error: expected expression before '{' token
    {       \
    ^
   include/linux/idr.h:30:11: note: in expansion of macro 'IDR_INIT'
     *(idr) = IDR_INIT(#idr)    \
              ^~~~~~~~
   drivers/staging/unisys/visorhba/visorhba_main.c:1111:2: note: in expansion of macro 'idr_init'
     idr_init(&devdata->idr);
     ^~~~~~~~

vim +384 drivers/gpu/drm/drm_mode_config.c

28575f16 Daniel Vetter 2016-11-14  363  	INIT_LIST_HEAD(&dev->mode_config.crtc_list);
28575f16 Daniel Vetter 2016-11-14  364  	INIT_LIST_HEAD(&dev->mode_config.connector_list);
28575f16 Daniel Vetter 2016-11-14  365  	INIT_LIST_HEAD(&dev->mode_config.encoder_list);
28575f16 Daniel Vetter 2016-11-14  366  	INIT_LIST_HEAD(&dev->mode_config.property_list);
28575f16 Daniel Vetter 2016-11-14  367  	INIT_LIST_HEAD(&dev->mode_config.property_blob_list);
28575f16 Daniel Vetter 2016-11-14  368  	INIT_LIST_HEAD(&dev->mode_config.plane_list);
28575f16 Daniel Vetter 2016-11-14 @369  	idr_init(&dev->mode_config.crtc_idr);
28575f16 Daniel Vetter 2016-11-14  370  	idr_init(&dev->mode_config.tile_idr);
28575f16 Daniel Vetter 2016-11-14  371  	ida_init(&dev->mode_config.connector_ida);
613051da Daniel Vetter 2016-12-14  372  	spin_lock_init(&dev->mode_config.connector_list_lock);
28575f16 Daniel Vetter 2016-11-14  373  
28575f16 Daniel Vetter 2016-11-14  374  	drm_mode_create_standard_properties(dev);
28575f16 Daniel Vetter 2016-11-14  375  
28575f16 Daniel Vetter 2016-11-14  376  	/* Just to be sure */
28575f16 Daniel Vetter 2016-11-14  377  	dev->mode_config.num_fb = 0;
28575f16 Daniel Vetter 2016-11-14  378  	dev->mode_config.num_connector = 0;
28575f16 Daniel Vetter 2016-11-14  379  	dev->mode_config.num_crtc = 0;
28575f16 Daniel Vetter 2016-11-14  380  	dev->mode_config.num_encoder = 0;
28575f16 Daniel Vetter 2016-11-14  381  	dev->mode_config.num_overlay_plane = 0;
28575f16 Daniel Vetter 2016-11-14  382  	dev->mode_config.num_total_plane = 0;
28575f16 Daniel Vetter 2016-11-14  383  }
28575f16 Daniel Vetter 2016-11-14 @384  EXPORT_SYMBOL(drm_mode_config_init);
28575f16 Daniel Vetter 2016-11-14  385  
28575f16 Daniel Vetter 2016-11-14  386  /**
28575f16 Daniel Vetter 2016-11-14  387   * drm_mode_config_cleanup - free up DRM mode_config info

:::::: The code at line 384 was first introduced by commit
:::::: 28575f165d36051310d7ea2350e2011f8095b6fb drm: Extract drm_mode_config.[hc]

:::::: TO: Daniel Vetter <daniel.vetter@ffwll.ch>
:::::: CC: Daniel Vetter <daniel.vetter@ffwll.ch>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
