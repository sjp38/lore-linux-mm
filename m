Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0CAD6B78D7
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 02:51:54 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so18882016pfc.11
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 23:51:54 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 23si22689334pfz.20.2018.12.05.23.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 23:51:51 -0800 (PST)
Date: Thu, 6 Dec 2018 15:51:12 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [linux-next:master 6857/7074] htmldocs:
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Function parameter or
 member 'range' not described in 'amdgpu_mn_invalidate_range_start_gfx'
Message-ID: <201812061510.3O6pcsYS%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   15814356aac416bea48544b76b761d8687b5a1e9
commit: c3a8616c95df8ced5d1acd838dc7dc384cb5276b [6857/7074] mm/mmu_notifier: use structure for invalidate_range_start/end callback
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   include/net/mac80211.h:477: warning: cannot understand function prototype: 'struct ieee80211_ftm_responder_params '
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'rx_stats_avg' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'rx_stats_avg.signal' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'rx_stats_avg.chain_signal' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.filtered' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.retry_failed' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.retry_count' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.lost_packets' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.last_tdls_pkt_time' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.msdu_retries' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.msdu_failed' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.last_ack' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.last_ack_signal' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.ack_signal_filled' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'status_stats.avg_ack_signal' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'tx_stats.packets' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'tx_stats.bytes' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'tx_stats.last_rate' not described in 'sta_info'
   net/mac80211/sta_info.h:588: warning: Function parameter or member 'tx_stats.msdu' not described in 'sta_info'
   kernel/rcu/tree.c:685: warning: Excess function parameter 'irq' description in 'rcu_nmi_exit'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_excl.cb' not described in 'dma_buf'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_excl.poll' not described in 'dma_buf'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_excl.active' not described in 'dma_buf'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_shared.cb' not described in 'dma_buf'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_shared.poll' not described in 'dma_buf'
   include/linux/dma-buf.h:304: warning: Function parameter or member 'cb_shared.active' not described in 'dma_buf'
   include/linux/dma-fence-array.h:54: warning: Function parameter or member 'work' not described in 'dma_fence_array'
   include/linux/gpio/driver.h:375: warning: Function parameter or member 'init_valid_mask' not described in 'gpio_chip'
   include/linux/iio/hw-consumer.h:1: warning: no structured comments found
   include/linux/input/sparse-keymap.h:46: warning: Function parameter or member 'sw' not described in 'key_entry'
   include/linux/regulator/driver.h:227: warning: Function parameter or member 'resume' not described in 'regulator_ops'
   arch/s390/include/asm/cio.h:245: warning: Function parameter or member 'esw.esw0' not described in 'irb'
   arch/s390/include/asm/cio.h:245: warning: Function parameter or member 'esw.esw1' not described in 'irb'
   arch/s390/include/asm/cio.h:245: warning: Function parameter or member 'esw.esw2' not described in 'irb'
   arch/s390/include/asm/cio.h:245: warning: Function parameter or member 'esw.esw3' not described in 'irb'
   arch/s390/include/asm/cio.h:245: warning: Function parameter or member 'esw.eadm' not described in 'irb'
   drivers/slimbus/stream.c:1: warning: no structured comments found
   include/linux/spi/spi.h:177: warning: Function parameter or member 'driver_override' not described in 'spi_device'
   drivers/target/target_core_device.c:1: warning: no structured comments found
   drivers/usb/typec/bus.c:1: warning: no structured comments found
   drivers/usb/typec/class.c:1: warning: no structured comments found
   include/linux/w1.h:281: warning: Function parameter or member 'of_match_table' not described in 'w1_family'
   fs/direct-io.c:257: warning: Excess function parameter 'offset' description in 'dio_complete'
   fs/file_table.c:1: warning: no structured comments found
   fs/libfs.c:477: warning: Excess function parameter 'available' description in 'simple_write_end'
   fs/posix_acl.c:646: warning: Function parameter or member 'inode' not described in 'posix_acl_update_mode'
   fs/posix_acl.c:646: warning: Function parameter or member 'mode_p' not described in 'posix_acl_update_mode'
   fs/posix_acl.c:646: warning: Function parameter or member 'acl' not described in 'posix_acl_update_mode'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:250: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:250: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:250: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:296: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:296: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:296: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:345: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:345: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:345: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:183: warning: Function parameter or member 'blockable' not described in 'amdgpu_mn_read_lock'
>> drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Function parameter or member 'range' not described in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_start_gfx'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_start_gfx'
>> drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:297: warning: Function parameter or member 'range' not described in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:297: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:297: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_start_hsa'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:297: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_start_hsa'
>> drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:346: warning: Function parameter or member 'range' not described in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:346: warning: Excess function parameter 'mm' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:346: warning: Excess function parameter 'start' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:346: warning: Excess function parameter 'end' description in 'amdgpu_mn_invalidate_range_end'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:382: warning: cannot understand function prototype: 'struct amdgpu_vm_pt_cursor '
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:383: warning: cannot understand function prototype: 'struct amdgpu_vm_pt_cursor '
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:555: warning: Function parameter or member 'adev' not described in 'for_each_amdgpu_vm_pt_leaf'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:555: warning: Function parameter or member 'vm' not described in 'for_each_amdgpu_vm_pt_leaf'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:555: warning: Function parameter or member 'start' not described in 'for_each_amdgpu_vm_pt_leaf'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:555: warning: Function parameter or member 'end' not described in 'for_each_amdgpu_vm_pt_leaf'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:555: warning: Function parameter or member 'cursor' not described in 'for_each_amdgpu_vm_pt_leaf'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:603: warning: Function parameter or member 'adev' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:603: warning: Function parameter or member 'vm' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:603: warning: Function parameter or member 'cursor' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:603: warning: Function parameter or member 'entry' not described in 'for_each_amdgpu_vm_pt_dfs_safe'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:848: warning: Function parameter or member 'level' not described in 'amdgpu_vm_bo_param'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'params' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'bo' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'pe' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'addr' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'count' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'incr' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1356: warning: Function parameter or member 'flags' not described in 'amdgpu_vm_update_func'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'params' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'bo' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'level' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'pe' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'addr' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'count' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'incr' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:1523: warning: Function parameter or member 'flags' not described in 'amdgpu_vm_update_huge'
   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:3100: warning: Function parameter or member 'pasid' not described in 'amdgpu_vm_make_compute'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_pin' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_unpin' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_res_obj' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_get_sg_table' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_import_sg_table' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_vmap' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_vunmap' not described in 'drm_driver'
   include/drm/drm_drv.h:609: warning: Function parameter or member 'gem_prime_mmap' not described in 'drm_driver'
   include/drm/drm_mode_config.h:869: warning: Function parameter or member 'quirk_addfb_prefer_xbgr_30bpp' not described in 'drm_mode_config'
   drivers/gpu/drm/i915/i915_vma.h:49: warning: cannot understand function prototype: 'struct i915_vma '
   drivers/gpu/drm/i915/i915_vma.h:1: warning: no structured comments found
   drivers/gpu/drm/i915/intel_guc_fwif.h:554: warning: cannot understand function prototype: 'struct guc_log_buffer_state '
   drivers/gpu/drm/i915/i915_trace.h:1: warning: no structured comments found
   include/linux/skbuff.h:862: warning: Function parameter or member 'dev_scratch' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'list' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'ip_defrag_offset' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'skb_mstamp_ns' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member '__cloned_offset' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'head_frag' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member '__pkt_type_offset' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'encapsulation' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'encap_hdr_csum' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'csum_valid' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'csum_complete_sw' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'csum_level' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'inner_protocol_type' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'remcsum_offload' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'offload_fwd_mark' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'offload_mr_fwd_mark' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'sender_cpu' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'reserved_tailroom' not described in 'sk_buff'
   include/linux/skbuff.h:862: warning: Function parameter or member 'inner_ipproto' not described in 'sk_buff'
   include/net/sock.h:238: warning: Function parameter or member 'skc_addrpair' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_portpair' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_ipv6only' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_net_refcnt' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_v6_daddr' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_v6_rcv_saddr' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_cookie' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_listener' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_tw_dr' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_rcv_wnd' not described in 'sock_common'
   include/net/sock.h:238: warning: Function parameter or member 'skc_tw_rcv_nxt' not described in 'sock_common'
   include/net/sock.h:509: warning: Function parameter or member 'sk_backlog.rmem_alloc' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_backlog.len' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_backlog.head' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_backlog.tail' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_wq_raw' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'tcp_rtx_queue' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_route_forced_caps' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_txtime_report_errors' not described in 'sock'
   include/net/sock.h:509: warning: Function parameter or member 'sk_validate_xmit_skb' not described in 'sock'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'adj_list.upper' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'adj_list.lower' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'gso_partial_features' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'switchdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'l3mdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'xfrmdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'tlsdev_ops' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'name_assign_type' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'ieee802154_ptr' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'mpls_ptr' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'xdp_prog' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'gro_flush_timeout' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'nf_hooks_ingress' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member '____cacheline_aligned_in_smp' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'qdisc_hash' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'xps_cpus_map' not described in 'net_device'
   include/linux/netdevice.h:2052: warning: Function parameter or member 'xps_rxqs_map' not described in 'net_device'

vim +251 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c

3fe89771cb Christian K�nig 2017-09-12  175  
d38ceaf99e Alex Deucher    2015-04-20  176  /**
ad7f0b6334 Christian K�nig 2018-06-05  177   * amdgpu_mn_read_lock - take the read side lock for this notifier
1ed3d2567c Christian K�nig 2017-09-05  178   *
528e083d85 Christian K�nig 2018-06-13  179   * @amn: our notifier
1ed3d2567c Christian K�nig 2017-09-05  180   */
93065ac753 Michal Hocko    2018-08-21  181  static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
1ed3d2567c Christian K�nig 2017-09-05  182  {
93065ac753 Michal Hocko    2018-08-21 @183  	if (blockable)
528e083d85 Christian K�nig 2018-06-13  184  		mutex_lock(&amn->read_lock);
93065ac753 Michal Hocko    2018-08-21  185  	else if (!mutex_trylock(&amn->read_lock))
93065ac753 Michal Hocko    2018-08-21  186  		return -EAGAIN;
93065ac753 Michal Hocko    2018-08-21  187  
528e083d85 Christian K�nig 2018-06-13  188  	if (atomic_inc_return(&amn->recursion) == 1)
528e083d85 Christian K�nig 2018-06-13  189  		down_read_non_owner(&amn->lock);
528e083d85 Christian K�nig 2018-06-13  190  	mutex_unlock(&amn->read_lock);
93065ac753 Michal Hocko    2018-08-21  191  
93065ac753 Michal Hocko    2018-08-21  192  	return 0;
1ed3d2567c Christian K�nig 2017-09-05  193  }
1ed3d2567c Christian K�nig 2017-09-05  194  
1ed3d2567c Christian K�nig 2017-09-05  195  /**
ad7f0b6334 Christian K�nig 2018-06-05  196   * amdgpu_mn_read_unlock - drop the read side lock for this notifier
1ed3d2567c Christian K�nig 2017-09-05  197   *
528e083d85 Christian K�nig 2018-06-13  198   * @amn: our notifier
1ed3d2567c Christian K�nig 2017-09-05  199   */
528e083d85 Christian K�nig 2018-06-13  200  static void amdgpu_mn_read_unlock(struct amdgpu_mn *amn)
1ed3d2567c Christian K�nig 2017-09-05  201  {
528e083d85 Christian K�nig 2018-06-13  202  	if (atomic_dec_return(&amn->recursion) == 0)
528e083d85 Christian K�nig 2018-06-13  203  		up_read_non_owner(&amn->lock);
1ed3d2567c Christian K�nig 2017-09-05  204  }
1ed3d2567c Christian K�nig 2017-09-05  205  
d38ceaf99e Alex Deucher    2015-04-20  206  /**
ae20f12d2d Christian K�nig 2016-03-18  207   * amdgpu_mn_invalidate_node - unmap all BOs of a node
d38ceaf99e Alex Deucher    2015-04-20  208   *
ae20f12d2d Christian K�nig 2016-03-18  209   * @node: the node with the BOs to unmap
ad7f0b6334 Christian K�nig 2018-06-05  210   * @start: start of address range affected
ad7f0b6334 Christian K�nig 2018-06-05  211   * @end: end of address range affected
d38ceaf99e Alex Deucher    2015-04-20  212   *
ad7f0b6334 Christian K�nig 2018-06-05  213   * Block for operations on BOs to finish and mark pages as accessed and
ad7f0b6334 Christian K�nig 2018-06-05  214   * potentially dirty.
d38ceaf99e Alex Deucher    2015-04-20  215   */
ae20f12d2d Christian K�nig 2016-03-18  216  static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
d38ceaf99e Alex Deucher    2015-04-20  217  				      unsigned long start,
d38ceaf99e Alex Deucher    2015-04-20  218  				      unsigned long end)
d38ceaf99e Alex Deucher    2015-04-20  219  {
d38ceaf99e Alex Deucher    2015-04-20  220  	struct amdgpu_bo *bo;
7ab7e8a409 Jack Xiao       2015-04-27  221  	long r;
d38ceaf99e Alex Deucher    2015-04-20  222  
d38ceaf99e Alex Deucher    2015-04-20  223  	list_for_each_entry(bo, &node->bos, mn_list) {
d38ceaf99e Alex Deucher    2015-04-20  224  
ae20f12d2d Christian K�nig 2016-03-18  225  		if (!amdgpu_ttm_tt_affect_userptr(bo->tbo.ttm, start, end))
a961ea7349 Christian K�nig 2015-05-04  226  			continue;
a961ea7349 Christian K�nig 2015-05-04  227  
d38ceaf99e Alex Deucher    2015-04-20  228  		r = reservation_object_wait_timeout_rcu(bo->tbo.resv,
d38ceaf99e Alex Deucher    2015-04-20  229  			true, false, MAX_SCHEDULE_TIMEOUT);
7ab7e8a409 Jack Xiao       2015-04-27  230  		if (r <= 0)
7ab7e8a409 Jack Xiao       2015-04-27  231  			DRM_ERROR("(%ld) failed to wait for user bo\n", r);
d38ceaf99e Alex Deucher    2015-04-20  232  
1b0c0f9dc5 Christian K�nig 2017-09-05  233  		amdgpu_ttm_tt_mark_user_pages(bo->tbo.ttm);
d38ceaf99e Alex Deucher    2015-04-20  234  	}
d38ceaf99e Alex Deucher    2015-04-20  235  }
0d2b42b0bd Christian K�nig 2016-03-18  236  
ae20f12d2d Christian K�nig 2016-03-18  237  /**
e52482dec8 Felix Kuehling  2018-03-23  238   * amdgpu_mn_invalidate_range_start_gfx - callback to notify about mm change
ae20f12d2d Christian K�nig 2016-03-18  239   *
ae20f12d2d Christian K�nig 2016-03-18  240   * @mn: our notifier
ad7f0b6334 Christian K�nig 2018-06-05  241   * @mm: the mm this callback is about
ae20f12d2d Christian K�nig 2016-03-18  242   * @start: start of updated range
ae20f12d2d Christian K�nig 2016-03-18  243   * @end: end of updated range
ae20f12d2d Christian K�nig 2016-03-18  244   *
ad7f0b6334 Christian K�nig 2018-06-05  245   * Block for operations on BOs to finish and mark pages as accessed and
ad7f0b6334 Christian K�nig 2018-06-05  246   * potentially dirty.
ae20f12d2d Christian K�nig 2016-03-18  247   */
93065ac753 Michal Hocko    2018-08-21  248  static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
c3a8616c95 Jerome Glisse   2018-12-05  249  			const struct mmu_notifier_range *range)
ae20f12d2d Christian K�nig 2016-03-18 @250  {
528e083d85 Christian K�nig 2018-06-13 @251  	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
ae20f12d2d Christian K�nig 2016-03-18  252  	struct interval_tree_node *it;
c3a8616c95 Jerome Glisse   2018-12-05  253  	unsigned long end;
ae20f12d2d Christian K�nig 2016-03-18  254  
ae20f12d2d Christian K�nig 2016-03-18  255  	/* notification is exclusive, but interval is inclusive */
c3a8616c95 Jerome Glisse   2018-12-05  256  	end = range->end - 1;
ae20f12d2d Christian K�nig 2016-03-18  257  
93065ac753 Michal Hocko    2018-08-21  258  	/* TODO we should be able to split locking for interval tree and
93065ac753 Michal Hocko    2018-08-21  259  	 * amdgpu_mn_invalidate_node
93065ac753 Michal Hocko    2018-08-21  260  	 */
c3a8616c95 Jerome Glisse   2018-12-05  261  	if (amdgpu_mn_read_lock(amn, range->blockable))
93065ac753 Michal Hocko    2018-08-21  262  		return -EAGAIN;
ae20f12d2d Christian K�nig 2016-03-18  263  
c3a8616c95 Jerome Glisse   2018-12-05  264  	it = interval_tree_iter_first(&amn->objects, range->start, end);
ae20f12d2d Christian K�nig 2016-03-18  265  	while (it) {
ae20f12d2d Christian K�nig 2016-03-18  266  		struct amdgpu_mn_node *node;
ae20f12d2d Christian K�nig 2016-03-18  267  
c3a8616c95 Jerome Glisse   2018-12-05  268  		if (!range->blockable) {
93065ac753 Michal Hocko    2018-08-21  269  			amdgpu_mn_read_unlock(amn);
93065ac753 Michal Hocko    2018-08-21  270  			return -EAGAIN;
93065ac753 Michal Hocko    2018-08-21  271  		}
93065ac753 Michal Hocko    2018-08-21  272  
ae20f12d2d Christian K�nig 2016-03-18  273  		node = container_of(it, struct amdgpu_mn_node, it);
c3a8616c95 Jerome Glisse   2018-12-05  274  		it = interval_tree_iter_next(it, range->start, end);
ae20f12d2d Christian K�nig 2016-03-18  275  
c3a8616c95 Jerome Glisse   2018-12-05  276  		amdgpu_mn_invalidate_node(node, range->start, end);
ae20f12d2d Christian K�nig 2016-03-18  277  	}
93065ac753 Michal Hocko    2018-08-21  278  
93065ac753 Michal Hocko    2018-08-21  279  	return 0;
1ed3d2567c Christian K�nig 2017-09-05  280  }
ae20f12d2d Christian K�nig 2016-03-18  281  
1ed3d2567c Christian K�nig 2017-09-05  282  /**
e52482dec8 Felix Kuehling  2018-03-23  283   * amdgpu_mn_invalidate_range_start_hsa - callback to notify about mm change
e52482dec8 Felix Kuehling  2018-03-23  284   *
e52482dec8 Felix Kuehling  2018-03-23  285   * @mn: our notifier
87e3f1366e Darren Powell   2018-06-25  286   * @mm: the mm this callback is about
e52482dec8 Felix Kuehling  2018-03-23  287   * @start: start of updated range
e52482dec8 Felix Kuehling  2018-03-23  288   * @end: end of updated range
e52482dec8 Felix Kuehling  2018-03-23  289   *
e52482dec8 Felix Kuehling  2018-03-23  290   * We temporarily evict all BOs between start and end. This
e52482dec8 Felix Kuehling  2018-03-23  291   * necessitates evicting all user-mode queues of the process. The BOs
e52482dec8 Felix Kuehling  2018-03-23  292   * are restorted in amdgpu_mn_invalidate_range_end_hsa.
e52482dec8 Felix Kuehling  2018-03-23  293   */
93065ac753 Michal Hocko    2018-08-21  294  static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
c3a8616c95 Jerome Glisse   2018-12-05  295  			const struct mmu_notifier_range *range)
e52482dec8 Felix Kuehling  2018-03-23 @296  {
528e083d85 Christian K�nig 2018-06-13 @297  	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
e52482dec8 Felix Kuehling  2018-03-23  298  	struct interval_tree_node *it;
c3a8616c95 Jerome Glisse   2018-12-05  299  	unsigned long end;
e52482dec8 Felix Kuehling  2018-03-23  300  
e52482dec8 Felix Kuehling  2018-03-23  301  	/* notification is exclusive, but interval is inclusive */
c3a8616c95 Jerome Glisse   2018-12-05  302  	end = range->end - 1;
e52482dec8 Felix Kuehling  2018-03-23  303  
c3a8616c95 Jerome Glisse   2018-12-05  304  	if (amdgpu_mn_read_lock(amn, range->blockable))
93065ac753 Michal Hocko    2018-08-21  305  		return -EAGAIN;
e52482dec8 Felix Kuehling  2018-03-23  306  
c3a8616c95 Jerome Glisse   2018-12-05  307  	it = interval_tree_iter_first(&amn->objects, range->start, end);
e52482dec8 Felix Kuehling  2018-03-23  308  	while (it) {
e52482dec8 Felix Kuehling  2018-03-23  309  		struct amdgpu_mn_node *node;
e52482dec8 Felix Kuehling  2018-03-23  310  		struct amdgpu_bo *bo;
e52482dec8 Felix Kuehling  2018-03-23  311  
c3a8616c95 Jerome Glisse   2018-12-05  312  		if (!range->blockable) {
93065ac753 Michal Hocko    2018-08-21  313  			amdgpu_mn_read_unlock(amn);
93065ac753 Michal Hocko    2018-08-21  314  			return -EAGAIN;
93065ac753 Michal Hocko    2018-08-21  315  		}
93065ac753 Michal Hocko    2018-08-21  316  
e52482dec8 Felix Kuehling  2018-03-23  317  		node = container_of(it, struct amdgpu_mn_node, it);
c3a8616c95 Jerome Glisse   2018-12-05  318  		it = interval_tree_iter_next(it, range->start, end);
e52482dec8 Felix Kuehling  2018-03-23  319  
e52482dec8 Felix Kuehling  2018-03-23  320  		list_for_each_entry(bo, &node->bos, mn_list) {
e52482dec8 Felix Kuehling  2018-03-23  321  			struct kgd_mem *mem = bo->kfd_bo;
e52482dec8 Felix Kuehling  2018-03-23  322  
e52482dec8 Felix Kuehling  2018-03-23  323  			if (amdgpu_ttm_tt_affect_userptr(bo->tbo.ttm,
c3a8616c95 Jerome Glisse   2018-12-05  324  							 range->start,
c3a8616c95 Jerome Glisse   2018-12-05  325  							 end))
c3a8616c95 Jerome Glisse   2018-12-05  326  				amdgpu_amdkfd_evict_userptr(mem, range->mm);
e52482dec8 Felix Kuehling  2018-03-23  327  		}
e52482dec8 Felix Kuehling  2018-03-23  328  	}
93065ac753 Michal Hocko    2018-08-21  329  
93065ac753 Michal Hocko    2018-08-21  330  	return 0;
e52482dec8 Felix Kuehling  2018-03-23  331  }
e52482dec8 Felix Kuehling  2018-03-23  332  
e52482dec8 Felix Kuehling  2018-03-23  333  /**
1ed3d2567c Christian K�nig 2017-09-05  334   * amdgpu_mn_invalidate_range_end - callback to notify about mm change
1ed3d2567c Christian K�nig 2017-09-05  335   *
1ed3d2567c Christian K�nig 2017-09-05  336   * @mn: our notifier
ad7f0b6334 Christian K�nig 2018-06-05  337   * @mm: the mm this callback is about
1ed3d2567c Christian K�nig 2017-09-05  338   * @start: start of updated range
1ed3d2567c Christian K�nig 2017-09-05  339   * @end: end of updated range
1ed3d2567c Christian K�nig 2017-09-05  340   *
1ed3d2567c Christian K�nig 2017-09-05  341   * Release the lock again to allow new command submissions.
1ed3d2567c Christian K�nig 2017-09-05  342   */
1ed3d2567c Christian K�nig 2017-09-05  343  static void amdgpu_mn_invalidate_range_end(struct mmu_notifier *mn,
c3a8616c95 Jerome Glisse   2018-12-05  344  			const struct mmu_notifier_range *range)
1ed3d2567c Christian K�nig 2017-09-05  345  {
528e083d85 Christian K�nig 2018-06-13 @346  	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
ae20f12d2d Christian K�nig 2016-03-18  347  
528e083d85 Christian K�nig 2018-06-13  348  	amdgpu_mn_read_unlock(amn);
d38ceaf99e Alex Deucher    2015-04-20  349  }
d38ceaf99e Alex Deucher    2015-04-20  350  

:::::: The code at line 251 was first introduced by commit
:::::: 528e083d85bd0306e056fe1bdfd05493ebbff9cc drm/amdgpu: rename rmn to amn in the MMU notifier code (v2)

:::::: TO: Christian K�nig <christian.koenig@amd.com>
:::::: CC: Alex Deucher <alexander.deucher@amd.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--G4iJoqBmSsgzjUCe
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
7AoLWzt9wxUsUKkoWnP/AUqzHXndWwAA

--G4iJoqBmSsgzjUCe--
