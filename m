Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7128FC4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB3421479
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sbh56VYo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB3421479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A988B6B0269; Sun, 15 Sep 2019 13:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22406B026A; Sun, 15 Sep 2019 13:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9616B026B; Sun, 15 Sep 2019 13:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 69DC06B0269
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:08:26 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F3783824CA36
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:25 +0000 (UTC)
X-FDA: 75937788570.11.thing66_2c76812cf4601
X-HE-Tag: thing66_2c76812cf4601
X-Filterd-Recvd-Size: 10302
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:25 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id 4so18022178pgm.12
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:08:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ADTfcPArVp8KQvFy/15pzSOdYF1sjsxn9QcodcYLZMM=;
        b=sbh56VYoYCPgVgo+tM4ATL4gTlAJ6SKDQ6pdL7h/Te02+SWThammuEz1zKtbLmNerg
         CBrJzV0GFMxc/g/s2woSryM0pJNyD26u7JJLjC5epi712zNWE2MJMryL1DqH12fuR6kw
         D7Xx2rQHE70/hgxVev534Ci6jSQDNLcWbghf5x4+8WYABCMvhxHZDECYuhInSeyEYACp
         vGs+3ux8wD7xEH5JXoCn770IJ/el1ixlwjaYL6VMW99SLjPU5gwDVLshhxfDw6+2lDQR
         88dfvJbQ/Dr0stgovlZTea2cEdt/RM1Zldr7Lx4gTG8kSarQ6M/cvvngj17OakJmGLo5
         XC/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ADTfcPArVp8KQvFy/15pzSOdYF1sjsxn9QcodcYLZMM=;
        b=WjQNKtywc/aPFn6FZXrSInWhoq6ubXnCDADJGz0lnTo3HkxO0VyJwZ5K4vrgTUxVZY
         DIG/2HVCH8F/o5bNMpkmCnYnZ9yAGpUC3mX2gspHntgNAphT5kC/bb70YkFyECBHeYlm
         hUi2clZPAGId1nwzf8s6PSDsycmI1J4GpgtusE2aFLm/EkMqDpDWcuu1fELTKw+rYm6M
         2VMgyEHlQ6aBs24IXCksN1NbtoFVn/NDe7H+iUwenGDmWqWih8iFYmesFgRK3CjQENTU
         LYIf2Cn2MRfnmUfeSz+HX6pgKCDa4LSS3EYOOgsBJy+9JMAnLORLpAiH7b0pRvow6MUU
         hsVA==
X-Gm-Message-State: APjAAAWJNWXsm5QMcrMmk9IcmlnnOC9L3QpbdGmXgKCUh/qC8jRZLTW+
	2/EbZZhP7oKZU7y8D6517+U=
X-Google-Smtp-Source: APXvYqx9kovc+b+m054f+ug30POGDV7YO/zxPJKVkQA1rgkbMLaveUfUnZ2UsMHjQ43aEs8+XrLIpQ==
X-Received: by 2002:a17:90a:d354:: with SMTP id i20mr16485031pjx.49.1568567304439;
        Sun, 15 Sep 2019 10:08:24 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.08.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:08:23 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [RESEND v4 0/7] mm, slab: Make kmalloc_info[] contain all types of names
Date: Mon, 16 Sep 2019 01:08:02 +0800
Message-Id: <20190915170809.10702-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001401, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes in v4
--
1. [old] abandon patch 4/4
2. [new] patch 4/7:
    - return ZERO_SIZE_ALLOC instead 0 for zero sized requests
3. [new] patch 5/7:
    - reorder kmalloc_info[], kmalloc_caches[] (in order of size)
    - hard to split, so slightly larger
4. [new] patch 6/7:
    - initialize kmalloc_cache[] with the same size but different
      types
5. [new] patch 7/7:
    - modify kmalloc_caches[type][idx] to kmalloc_caches[idx][type]

Patch 4-7 are newly added, more information can be obtained from
commit messages.

Changes in v3
--
1. restore __initconst (patch 1/4)
2. rename patch 3/4
3. add more clarification for patch 4/4

Changes in v2
--
1. remove __initconst (patch 1/5)
2. squash patch 2/5
3. add ack tag from Vlastimil Babka


There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
and KMALLOC_DMA.

The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
generated by kmalloc_cache_name().

Patch1 predefines the names of all types of kmalloc to save
the time spent dynamically generating names.

These changes make sense, and the time spent by new_kmalloc_cache()
has been reduced by approximately 36.3%.

                         Time spent by new_kmalloc_cache()
                                  (CPU cycles)
5.3-rc7                              66264
5.3-rc7+patch_1-3                    42188


bloat-o-meter
--
$ ./scripts/bloat-o-meter vmlinux.5.3-rc8 vmlinux.5.3-rc8+patch_1-7
add/remove: 1/2 grow/shrink: 6/65 up/down: 872/-1621 (-749)
Function                                     old     new   delta
all_kmalloc_info                               -     832    +832
crypto_create_tfm                            211     225     +14
ieee80211_key_alloc                         1159    1169     +10
nl80211_parse_sched_scan                    2787    2795      +8
tg3_self_test                               4255    4259      +4
find_get_context.isra                        634     637      +3
sd_probe                                     947     948      +1
nf_queue                                     671     670      -1
trace_parser_get_init                         71      69      -2
pkcs7_verify.cold                            318     316      -2
units                                        323     320      -3
nl80211_set_reg                              642     639      -3
pkcs7_verify                                1503    1495      -8
i915_sw_fence_await_dma_fence                445     437      -8
nla_strdup                                   143     134      -9
kmalloc_slab                                 102      93      -9
xhci_alloc_tt_info                           349     338     -11
xhci_segment_alloc                           303     289     -14
xhci_alloc_container_ctx                     221     207     -14
xfrm_policy_alloc                            277     263     -14
selinux_sk_alloc_security                    119     105     -14
sdev_evt_send_simple                         124     110     -14
sdev_evt_alloc                                85      71     -14
sbitmap_queue_init_node                      424     410     -14
regulatory_hint_found_beacon                 400     386     -14
nf_ct_tmpl_alloc                              91      77     -14
gss_create_cred                              146     132     -14
drm_flip_work_allocate_task                   76      62     -14
cfg80211_stop_iface                          266     252     -14
cfg80211_sinfo_alloc_tid_stats                83      69     -14
cfg80211_port_authorized                     218     204     -14
cfg80211_ibss_joined                         341     327     -14
call_usermodehelper_setup                    155     141     -14
bpf_prog_alloc_no_stats                      188     174     -14
blk_alloc_flush_queue                        197     183     -14
bdi_alloc_node                               201     187     -14
_netlbl_catmap_getnode                       253     239     -14
__igmp_group_dropped                         629     615     -14
____ip_mc_inc_group                          481     467     -14
xhci_alloc_command                           221     205     -16
audit_log_d_path                             204     188     -16
xprt_switch_alloc                            145     128     -17
xhci_ring_alloc                              378     361     -17
xhci_mem_init                               3673    3656     -17
xhci_alloc_virt_device                       505     488     -17
xhci_alloc_stream_info                       727     710     -17
tcp_sendmsg_locked                          3129    3112     -17
tcp_md5_do_add                               783     766     -17
tcp_fastopen_defer_connect                   279     262     -17
sr_read_tochdr.isra                          260     243     -17
sr_read_tocentry.isra                        337     320     -17
sr_is_xa                                     385     368     -17
sr_get_mcn                                   269     252     -17
scsi_probe_and_add_lun                      2947    2930     -17
ring_buffer_read_prepare                     103      86     -17
request_firmware_nowait                      405     388     -17
ohci_urb_enqueue                            3185    3168     -17
nfs_alloc_seqid                               96      79     -17
nfs4_get_state_owner                        1049    1032     -17
nfs4_do_close                                587     570     -17
mempool_create_node                          173     156     -17
ip6_setup_cork                              1030    1013     -17
ida_alloc_range                              951     934     -17
gss_import_sec_context                       187     170     -17
dma_pool_alloc                               419     402     -17
devres_open_group                            223     206     -17
cfg80211_parse_mbssid_data                  2406    2389     -17
ip_setup_cork                                374     354     -20
kmalloc_caches                               336     312     -24
__i915_sw_fence_await_sw_fence               429     405     -24
kmalloc_cache_name                            57       -     -57
new_kmalloc_cache                            112       -    -112
create_kmalloc_caches                        270     148    -122
kmalloc_info                                 432       8    -424
Total: Before=3D14874616, After=3D14873867, chg -0.01%

Pengfei Li (7):
  mm, slab: Make kmalloc_info[] contain all types of names
  mm, slab: Remove unused kmalloc_size()
  mm, slab_common: Use enum kmalloc_cache_type to iterate over kmalloc
    caches
  mm, slab: Return ZERO_SIZE_ALLOC for zero sized kmalloc requests
  mm, slab_common: Make kmalloc_caches[] start at size KMALLOC_MIN_SIZE
  mm, slab_common: Initialize the same size of kmalloc_caches[]
  mm, slab_common: Modify kmalloc_caches[type][idx] to
    kmalloc_caches[idx][type]

 include/linux/slab.h | 136 ++++++++++++++------------
 mm/slab.c            |  11 ++-
 mm/slab.h            |  10 +-
 mm/slab_common.c     | 224 ++++++++++++++++++-------------------------
 mm/slub.c            |  12 +--
 5 files changed, 183 insertions(+), 210 deletions(-)

--=20
2.21.0


