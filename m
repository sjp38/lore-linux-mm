Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E49C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 974012183E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:44:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 974012183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3815B6B0003; Fri, 22 Mar 2019 11:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3329B6B0006; Fri, 22 Mar 2019 11:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21E456B0007; Fri, 22 Mar 2019 11:44:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEEDF6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:44:38 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id p13so1210461wrm.5
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:44:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=RkEs9CA3N2AyTYkTg+qRDR2x0IeivrdGmV70Wk+Nn8Q=;
        b=EWC/v9f8MkT+LhoX6HVwQxzI72MPFw7Hdo+Hl0zs31rg4bpwjseI+gPX/URmhaKeCw
         HcQczA1FFvGbZVv9SX8b0GE/w34MlslYExOVF8O1gWFQFvpLIezHekWafqD6nW5ZvpsV
         1KRYg+ey+in+oXmNFLsO/aLo34txWslGsrJnEDYnkCNqNR1whFVf1G6+G1XVjjUXDgZr
         H83Kec+tasGYgZt+0/aaP2kWugzh6gN+Y6xA46InJZP4DNmjIOLsDCRVZtIqoHbKLive
         14iIWjiFbu9+IrBkfP6skPEVfnyOEBVo6UFT6VkiuHqYOhdwPlTqfaekW5HGY+UTCPfa
         +qNw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAVp1ff48AULPS370IubPvyQdXXno/ZXvVY0YXSR1DUO/+vyRH5Q
	sAVQXr818vwhYbyIrH4CkpFXm3hZpeqE8iP100KqqtFyF5I/YDFJMfEf71+bDFpdWhBqh7J1ucW
	PKgOiJ73kPL5kYIYAtr7fzpAsutwv6dGdVJQmRW4p19AIQmLTkQ1R1YLcipJ56v4=
X-Received: by 2002:a1c:7508:: with SMTP id o8mr2953214wmc.38.1553269478139;
        Fri, 22 Mar 2019 08:44:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOO6u8w1aSAF4poBJa77v0YY9M1/1n6rVO/RQjFrgtRuWOjYKUYPT2XG9iT/Ralekzr+py
X-Received: by 2002:a1c:7508:: with SMTP id o8mr2953109wmc.38.1553269475848;
        Fri, 22 Mar 2019 08:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269475; cv=none;
        d=google.com; s=arc-20160816;
        b=hxUZp95fLV2HlliyRCO1jvGsS5idGO4yiatKxa5AEv4dPj2zPara+pKYKk76m+S1B0
         2bHsG8bxirbP8Pb94eSCxXJn9weLGlQw6mVwEMvW6IFYQtvtbzBY4cj4re85Po12hMiA
         S+ToFOz5IggmS6eeAnVTcIjFyhUifOjjsMAeUFQrVdnKageo5mb2gC1RtSjzE0sEzTXQ
         hjcztzCsvXp68e7We6zkqMV+GT0LZCl+VQXL2I9I5cFE67jlKe31UP1mOQVbsxF5tkbO
         pvDUMqEck2chH+lu4W53aNDVMKYjmENxzWnvdfAINF888KVrpoEsdikPjaGyOp3uTMnp
         l62g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=RkEs9CA3N2AyTYkTg+qRDR2x0IeivrdGmV70Wk+Nn8Q=;
        b=WSo+KXwRgW6wEqv1Y3ds3i5g+wga9J6JkCkjE+UQ7VwRssb2K4c7dLYw0Ty/pJ15Hw
         4hAfW9Nt6uXrTMlK378lLPwpmgDbaM/gEChDGivnTUCarj2wFfUUr5w901jFXyG3NDIL
         GS9nRxPFBee9+Vl9JwU5iZFzAUMqsnCCjRAVRMEeteARYDceE3cE2c8AA3bCwx9vxHHk
         JTTy7b+Vnf8ZtD1XYloMsNVXniyD3QO63Br6W+Iv5A2WAnOuPKtPaGFPwFslXpw81oFt
         Ymq+c7SX0ywThB6KT15BUOdw6a9GqFgDyyCvNpi+f9/84Ihn8LHAc1R0wI4Mp8wWJ5Fe
         WW2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id l11si5383080wrm.128.2019.03.22.08.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 08:44:35 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.13;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from wuerfel.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue108 [212.227.15.145]) with ESMTPA (Nemesis) id
 1MkHIV-1gj4Cu3Ett-00kfr1; Fri, 22 Mar 2019 16:44:33 +0100
From: Arnd Bergmann <arnd@arndb.de>
To: stable@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mmc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-mm@kvack.org,
	dccp@vger.kernel.org,
	alsa-devel@alsa-project.org
Subject: [BACKPORT 4.4.y 00/25] candidates from spreadtrum 4.4 product kernel
Date: Fri, 22 Mar 2019 16:43:51 +0100
Message-Id: <20190322154425.3852517-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:YIdI4mJ+CBmMKtqvrMVynG9K2C6p8ReOaBkbvYFzll91mqWGcOM
 P5oDqnEthusGpVqTOWVcu7AGbZCddxJ38c5A6Cs8Oj4R3mDfvk6tYLLyiE6R/rwss52g9VO
 TZKgZMUocQh2LDGxv/Fb+AGie6/H9cRWw+5Ax3Cb4MYK72Xr+8zRAorr7AzMNER/f8fH/I0
 d+cvzzGvae3m7GFQCAFaQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:nIh5mVVwUlE=:u64jKyc00poFeTsEjIk6bg
 wrOiXid8x44ob/2xSEUzkSIHLFcOMwIQmF+2AKmo8Xlfhu9mIJAB2mq6FZ+oNW1kKtgCr87zz
 8+y7hVIDFDwATqqePwLST/Sf/ZZj+0CW58JsIrBuERL03GbJ0PpKj22SURkhXw+rrYDs4hv91
 VSYFQ9IyQcfMn8dHfwZzUj0sG28XgkBeJxvd6IbNYb5GYj6oGukW1BPQhJCFQYQtvtTx6bye7
 K5rCpKmbXeUOlyviuNlJgKPm4JO5JSLBR1TVyi0s7v8I2M0IgeOO4K9nNzOAekUfW1SLAkjQk
 gsYHujFJP7vI0JVTlsx48OSAqXIUIHjF82X3Xpuyb6WvQH1yDlDz3a5oRE5/Gve1vSIbmwTe9
 Csuu377CNPo+QjofU4cROfu/LPnfUbuGcaeqcd5uW2A+Uo1pNPfuNmCYzApAGT+2TKc1hfrY4
 x9EaH0tKr3C/c2HmRb2a0mhvuJTGF3erZNCIomKhGOviFQcuLktI3gTmlEJUy0yo+7aA/NkcS
 MomJtHd8fGM4Rpbc6hU0wKitqY9yQtloYeNauH5vv0HOjFyUjSrxZyqXfwJED9cKDpfncSEjv
 VqK6hCfvhXmlz5aJNqCiC/egHAtlEm9NZNeHuwe9HcXkv4SmPlH5Hv/PLaB89ukM04yY+XO0y
 1r4roJMo6Z/rm5/CKXIStvEF98L+dXTpkUW9KcSu91wvK6NCQEUC0rdk8DkVF32KmzU0+NVqJ
 ALkKYiTVFBL8ldT7l9oXDYjFTRp0ByPOdW4Vug==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I took a scripted approach to look at some product kernels for patches
backported into vendor kernels. This is a set of (mostly) bugfixes I found
in Spreadtrum's linux-4.4 kernel that are missing in 4.4.176:

ffedbd2210f2 mmc: pwrseq: constify mmc_pwrseq_ops structures
c10368897e10 ALSA: compress: add support for 32bit calls in a 64bit kernel
64a67d4762ce mmc: pwrseq_simple: Make reset-gpios optional to match doc
4ec0ef3a8212 USB: iowarrior: fix oops with malicious USB descriptors
e5905ff1281f mmc: debugfs: Add a restriction to mmc debugfs clock setting
4ec96b4cbde8 mmc: make MAN_BKOPS_EN message a debug
ed9feec72fc1 mmc: sanitize 'bus width' in debug output
10a16a01d8f7 mmc: core: shut up "voltage-ranges unspecified" pr_info()
9772b47a4c29 usb: dwc3: gadget: Fix suspend/resume during device mode
6afedcd23cfd arm64: mm: Add trace_irqflags annotations to do_debug_exception()
437db4c6e798 mmc: mmc: Attempt to flush cache before reset
e51534c80660 mmc: core: fix using wrong io voltage if mmc_select_hs200 fails
e4c5800a3991 mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
04c080080855 extcon: usb-gpio: Don't miss event during suspend/resume
78283edf2c01 kbuild: setlocalversion: print error to STDERR
c526c62d565e usb: gadget: composite: fix dereference after null check coverify warning
511a36d2f357 usb: gadget: Add the gserial port checking in gs_start_tx()
1712c9373f98 mmc: core: don't try to switch block size for dual rate mode
5ea8ea2cb7f1 tcp/dccp: drop SYN packets if accept queue is full
e1dc9b08051a serial: sprd: adjust TIMEOUT to a big value
81be24d263db Hang/soft lockup in d_invalidate with simultaneous calls
6f44a0bacb79 arm64: traps: disable irq in die()
b7d44c36a6f6 usb: renesas_usbhs: gadget: fix unused-but-set-variable warning
4350782570b9 serial: sprd: clear timeout interrupt only rather than all interrupts
3f3295709ede lib/int_sqrt: optimize small argument
32fd87b3bbf5 USB: core: only clean up what we allocated

Al Viro (1):
  Hang/soft lockup in d_invalidate with simultaneous calls

Andrey Konovalov (1):
  USB: core: only clean up what we allocated

Baolin Wang (1):
  usb: gadget: Add the gserial port checking in gs_start_tx()

Chuanxiao Dong (1):
  mmc: debugfs: Add a restriction to mmc debugfs clock setting

Dong Aisheng (1):
  mmc: core: fix using wrong io voltage if mmc_select_hs200 fails

Eric Dumazet (1):
  tcp/dccp: drop SYN packets if accept queue is full

James Morse (1):
  arm64: mm: Add trace_irqflags annotations to do_debug_exception()

Josh Boyer (1):
  USB: iowarrior: fix oops with malicious USB descriptors

Julia Lawall (1):
  mmc: pwrseq: constify mmc_pwrseq_ops structures

Konstantin Khlebnikov (1):
  mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON

Lanqing Liu (1):
  serial: sprd: clear timeout interrupt only rather than all interrupts

Martin Fuzzey (1):
  mmc: pwrseq_simple: Make reset-gpios optional to match doc

Peter Chen (1):
  usb: gadget: composite: fix dereference after null check coverify
    warning

Peter Zijlstra (1):
  lib/int_sqrt: optimize small argument

Qiao Zhou (1):
  arm64: traps: disable irq in die()

Ravindra Lokhande (1):
  ALSA: compress: add support for 32bit calls in a 64bit kernel

Roger Quadros (2):
  usb: dwc3: gadget: Fix suspend/resume during device mode
  extcon: usb-gpio: Don't miss event during suspend/resume

Russell King (1):
  mmc: core: shut up "voltage-ranges unspecified" pr_info()

Wei Qiao (1):
  serial: sprd: adjust TIMEOUT to a big value

Wolfram Sang (3):
  mmc: make MAN_BKOPS_EN message a debug
  mmc: sanitize 'bus width' in debug output
  kbuild: setlocalversion: print error to STDERR

Yoshihiro Shimoda (1):
  usb: renesas_usbhs: gadget: fix unused-but-set-variable warning

Ziyuan Xu (1):
  mmc: core: don't try to switch block size for dual rate mode

 arch/arm64/kernel/traps.c              |  8 +++++--
 arch/arm64/mm/fault.c                  | 33 ++++++++++++++++++--------
 drivers/extcon/extcon-usb-gpio.c       |  3 +++
 drivers/mmc/core/core.c                | 13 ++++++----
 drivers/mmc/core/debugfs.c             |  2 +-
 drivers/mmc/core/mmc.c                 | 16 +++++++++----
 drivers/mmc/core/pwrseq.h              |  2 +-
 drivers/mmc/core/pwrseq_emmc.c         |  2 +-
 drivers/mmc/core/pwrseq_simple.c       | 24 ++++++++++++-------
 drivers/tty/serial/sprd_serial.c       |  6 +++--
 drivers/usb/core/config.c              |  9 ++++---
 drivers/usb/dwc3/gadget.c              |  6 +++++
 drivers/usb/gadget/composite.c         |  2 ++
 drivers/usb/gadget/function/u_serial.c |  7 +++++-
 drivers/usb/misc/iowarrior.c           |  6 +++++
 drivers/usb/renesas_usbhs/mod_gadget.c |  5 +---
 fs/dcache.c                            | 10 ++++----
 include/net/inet_connection_sock.h     |  5 ----
 lib/int_sqrt.c                         |  3 +++
 mm/rmap.c                              |  2 +-
 net/dccp/ipv4.c                        |  8 +------
 net/dccp/ipv6.c                        |  2 +-
 net/ipv4/tcp_input.c                   |  8 +------
 scripts/setlocalversion                |  2 +-
 sound/core/compress_offload.c          | 13 ++++++++++
 25 files changed, 126 insertions(+), 71 deletions(-)

-- 
2.20.0

This is the full list of patches that were backported and are not in
4.4.y, but as usual most of them did not appear to make sense for stable
kernels.

 100   33 da5ce874f8ca f2fs: release locks before return in f2fs_ioc_gc_range()
 100  100 1dc0f8991d4d f2fs: fix to avoid race in between atomic write and background GC
 100   27 b27bc8091ccf f2fs: do gc in greedy mode for whole range if gc_urgent mode is set
 100  100 782911f491e7 f2fs: set readdir_ra by default
  33   33 81286d3e31b7 staging: android: ion: Remove check of idev->debug_root
 100   80 ae6650163c66 loop: fix concurrent lo_open/lo_release
 100  100 466a2b42d676 cpufreq: schedutil: Use idle_calls counter of the remote CPU
 100  100 32fd87b3bbf5 USB: core: only clean up what we allocated
 100  100 3f3295709ede lib/int_sqrt: optimize small argument
  50   30 e22cdc3fc599 sched/isolcpus: Fix "isolcpus=" boot parameter handling when !CONFIG_CPUMASK_OFFSTACK
 100   85 0abd8e70d24b f2fs: clear radix tree dirty tag of pages whose dirty flag is cleared
 100  100 84a23fbe96b4 f2fs: clear FI_HOT_DATA correctly
  91   91 12ac1d0f6c3e genirq: Make sparse_irq_lock protect what it should protect
 100   55 c49cbc19b31e cpufreq: schedutil: Always process remote callback with slow switching
 100  100 e2cabe48c20e cpufreq: schedutil: Don't restrict kthread to related_cpus unnecessarily
  78   78 99d14d0e16fa cpufreq: Process remote callbacks from any CPU if the platform permits
  31   61 674e75411fc2 sched: cpufreq: Allow remote cpufreq callbacks
  50  100 4350782570b9 serial: sprd: clear timeout interrupt only rather than all interrupts
 100  100 b7d44c36a6f6 usb: renesas_usbhs: gadget: fix unused-but-set-variable warning
 100  100 6f44a0bacb79 arm64: traps: disable irq in die()
 100   33 04dfc23006a2 f2fs: show more info if fail to issue discard
  71   28 e41e6d75e501 f2fs: split wio_mutex
 100  100 773a9ef85f02 mmc: pwrseq: Add reset callback to the struct mmc_pwrseq_ops
 100  100 81be24d263db Hang/soft lockup in d_invalidate with simultaneous calls
 100  100 e9256e142f59 mmc: pwrseq_simple: Parse DTS for the power-off-delay-us property
 100  100 e1dc9b08051a serial: sprd: adjust TIMEOUT to a big value
 100  100 6c3acd97572b f2fs: allocate hot_data for atomic writes
  75  100 bdd154436077 USB: serial: spcp8x5: simplify endpoint check
  45  100 590298b22325 USB: serial: pl2303: simplify endpoint check
  68  100 32814c87f446 USB: serial: oti6858: simplify endpoint check
  85  100 8ee1592d125a USB: serial: omninet: simplify endpoint check
  42  100 206ff831bebb USB: serial: mos7720: simplify endpoint check
  84  100 35194572b4ed USB: serial: kobil_sct: simplify endpoint check
  75  100 b714d5dc0631 USB: serial: keyspan_pda: simplify endpoint check
  69  100 fb527736ebcc USB: serial: iuu_phoenix: simplify endpoint check
  65  100 e7d6507e5ba7 USB: serial: digi_acceleport: simplify endpoint check
  81  100 d183b9b43390 USB: serial: cyberjack: simplify endpoint check
  60  100 fe190ed0d602 xhci: Do not halt the host until both HCD have disconnected their devices.
 100  100 f759741d9d91 block: Fix oops in locked_inode_to_wb_and_lock_list()
 100  100 773dc118756b mmc: core: Fix access to HS400-ES devices
  64   64 e93b9865251a f2fs: add ovp valid_blocks check for bg gc victim to fg_gc
  30   49 942fd3192f83 f2fs: check last page index in cached bio to decide submission
  71  100 bcb7440e76a9 extcon: usb-gpio: Add pinctrl operation during system PM
  66  100 5278204c9818 xhci: use the trb_to_noop() helper for command trbs
 100  100 bc88c10d7e69 locking/spinlock/debug: Remove spinlock lockup detection code
 100  100 d40a43af0a57 f2fs: fix an infinite loop when flush nodes in cp
  89   86 541332a13b1d extcon: usb-gpio: Add VBUS detection support
 100   50 65aca3205046 usb: dwc3: gadget: clear events in top-half handler
  77  100 ebbb2d59398f usb: dwc3: gadget: use evt->cache for processing events
  66  100 d9fa4c63f766 usb: dwc3: core: add a event buffer cache
 100  100 9ad587710a2f usb: gadget: composite: remove unnecessary & operation
 100   76 ef3d232245ab mmc: mmc: Relax checking for switch errors after HS200 switch
 100  100 e173f8911f09 mmc: core: Update CMD13 polling policy when switch to HS DDR mode
  68   63 aa33ce3c411a mmc: core: Enable __mmc_switch() to change bus speed timing for the host
 100   33 5ec32f84111a mmc: core: Check SWITCH_ERROR bit from each CMD13 response when polling
  50   50 625228fa3e01 mmc: core: Rename ignore_crc to retry_crc_err to reflect its purpose
 100  100 89e57aedda33 mmc: core: Remove redundant __mmc_send_status()
  33   33 437590a123b6 mmc: core: Retry instead of ignore at CRC errors when polling for busy
 100  100 c2c24819b280 mmc: core: Don't power off the card when starting the host
  55   50 716bdb8953c7 mmc: core: Factor out code related to polling in __mmc_switch()
  23   89 cb26ce069ffa mmc: core: Clarify code which deals with polling in __mmc_switch()
 100  100 5ea8ea2cb7f1 tcp/dccp: drop SYN packets if accept queue is full
  72  100 8e5bfa8c1f84 sched/autogroup: Do not use autogroup->tg in zombie threads
 100  100 8fdd136f2200 cfg80211: add bitrate for 20MHz MCS 9
  75  100 fd9afd3cbe40 usb: gadget: u_ether: remove interrupt throttling
 100  100 fe1b5700c70f mmc: mmc: Use 500ms as the default generic CMD6 timeout
 100  100 1720d3545b77 mmc: core: switch to 1V8 or 1V2 for hs400es mode
 100  100 e932835377f9 f2fs: check return value of write_checkpoint during fstrim
 100  100 1712c9373f98 mmc: core: don't try to switch block size for dual rate mode
  63   81 721e0497172f mmc: pwrseq-simple: Add an optional post-power-on-delay
 100  100 00af62330c39 usb: dwc3: core: Move the mode setting to the right place
 100   75 b1149ad917b7 coresight: always use stashed trace id value in etm4_trace_id
  80   80 a399d233078e sched/core: Fix incorrect utilization accounting when switching to fair class
 100   60 9d7aba7786b6 Revert "usb: dwc3: gadget: always decrement by 1"
 100  100 511a36d2f357 usb: gadget: Add the gserial port checking in gs_start_tx()
 100  100 c526c62d565e usb: gadget: composite: fix dereference after null check coverify warning
 100  100 78283edf2c01 kbuild: setlocalversion: print error to STDERR
 100  100 bb4eecf23be2 mmc: Change the max discard sectors and erase response when HW busy detect
 100  100 6ae3e537eab9 mmc: core: expose MMC_CAP2_NO_* to dt
 100  100 5f1d1434b7a0 Documentation: mmc: add description for new no-sd* and no-mmc
 100  100 a0c3b68c72a3 mmc: core: Allow hosts to specify non-support for MMC commands
 100  100 1b8d79c54944 mmc: core: Allow hosts to specify non-support for SD commands
 100  100 649c6059d237 mmc: mmc: Fix HS switch failure in mmc_select_hs400()
  61  100 08573eaf1a70 mmc: mmc: do not use CMD13 to get status after speed mode switch
  33  100 bc26235bbd79 mmc: debugfs: add HS400 enhanced strobe description
  74  100 81ac2af65793 mmc: core: implement enhanced strobe support
 100  100 ef29c0e273b8 mmc: core: add mmc-hs400-enhanced-strobe support
 100  100 a60119ce9434 Documentation: mmc: add mmc-hs400-enhanced-strobe
  99   78 48b4800a1c6a zsmalloc: page migration support
  88   79 bfd093f5e7f0 zsmalloc: use freeobj for index
  48   62 4aa409cab7c3 zsmalloc: separate free_zspage from putback_zspage
  66   66 3783689a1aa8 zsmalloc: introduce zspage structure
  62   86 bdb0af7ca8f0 zsmalloc: factor page chain functionality out
 100  100 1b8320b620d6 zsmalloc: use bit_spin_lock
  50   68 1fc6e27d7b86 zsmalloc: keep max_object in size_class
 100   85 b1123ea6d3b3 mm: balloon: use general non-lru movable page feature
  88   93 bda807d44454 mm: migrate: support non-lru movable page migration
  90   90 c6c919eb90e0 mm: use put_page() to free page instead of putback_lru_page()
  92  100 72704f876f50 dwc3: gadget: Implement the suspend entry event handler
 100  100 da1410be21bf usb: dwc3: gadget: Add the suspend state checking when stopping gadget
  33  100 13fa2e69b1dd usb: dwc3: gadget: disable XFER_NOT_READY
  92   35 361572b5f7a9 usb: dwc3: gadget: Handle TRB index 0 when full or empty
 100  100 7d0a038b130c usb: dwc3: gadget: Account for link TRB in TRBs left
 100  100 89bc856e5a74 usb: dwc3: gadget: Don't prepare TRBs if no space
  75  100 0d25744ad107 usb: dwc3: gadget: Initialize the TRB ring
  79   86 fc8bb91bc83e usb: dwc3: implement runtime PM
  77  100 4cb4221764ef usb: dwc3: gadget: fix for possible endpoint disable race
  45   29 51f5d49ad6f0 usb: dwc3: core: simplify suspend/resume operations
  79   91 c499ff71ff2a usb: dwc3: core: re-factor init and exit paths
  55  100 bcdb3272e889 usb: dwc3: core: move fladj to dwc3 structure
  68   80 c4233573f6ee usb: dwc3: gadget: prepare TRBs on update transfers too
 100  100 7f370ed0cfe9 usb: dwc3: core: get rid of DWC3_PM_OPS macro
  73   91 9f8a67b65a49 usb: dwc3: gadget: fix gadget suspend/resume
  68   93 d7be295243bb usb: dwc3: gadget: re-factor ->udc_start and ->udc_stop
 100  100 058b6659e98f extcon: usb-gpio: add device binding for platform device
 100  100 04c080080855 extcon: usb-gpio: Don't miss event during suspend/resume
 100  100 5fc363232ae7 uas: remove can_queue set in host template
 100  100 975756c41332 f2fs: avoid ENOSPC fault in the recovery process
  80   40 c41f3cc3ae34 f2fs: inject page allocation failures
  43   26 da011cc0da8c f2fs: move node pages only in victim section during GC
 100  100 1ee4716585ed zsmalloc: remove unused pool param in obj_free
  33   66 830e4bc5baa9 zsmalloc: clean up many BUG_ON
  67   71 36b68aae8e39 usb: dwc3: gadget: use link TRB for all endpoint types
  62   62 c28f82595dde usb: dwc3: switch trb enqueue/dequeue and first_trb_index to u8
 100  100 e4c5800a3991 mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
 100  100 e51534c80660 mmc: core: fix using wrong io voltage if mmc_select_hs200 fails
 100  100 437db4c6e798 mmc: mmc: Attempt to flush cache before reset
 100  100 87e88659afd1 mmc: core: drop unnecessary bit checking
  97   96 d97a1e5d7cd2 mmc: pwrseq: convert to proper platform device
  75  100 f01b72d0fd53 mmc: pwrseq_emmc: add to_pwrseq_emmc() macro
  85  100 5b96fea730ab mmc: pwrseq_simple: add to_pwrseq_simple() macro
 100  100 4e6c71788d6b mmc: core: Do regular power cycle when lacking eMMC HW reset support
 100  100 6afedcd23cfd arm64: mm: Add trace_irqflags annotations to do_debug_exception()
  33  100 9772b47a4c29 usb: dwc3: gadget: Fix suspend/resume during device mode
 100  100 a0747eb81c1d mmc: core: remove redundant memset of sdio_read_cccr
 100  100 0076c71e37cc mmc: core: remove redundant memset of mmc_decode_cid
 100  100 07d97d872359 mmc: core: report tuning command execution failure reason
 100   77 cf925747d20b mmc: core: improve mmc_of_parse_voltage() to return better status
  75  100 10a16a01d8f7 mmc: core: shut up "voltage-ranges unspecified" pr_info()
 100  100 ed9feec72fc1 mmc: sanitize 'bus width' in debug output
 100   77 6067bafe44d7 mmc: core: use the defined function to check whether card is removable
 100  100 4ec96b4cbde8 mmc: make MAN_BKOPS_EN message a debug
 100  100 e5905ff1281f mmc: debugfs: Add a restriction to mmc debugfs clock setting
 100  100 0899e7419387 mmc: remove unnecessary assignment statements before return
 100  100 62c03ca3ffa1 mmc: core: pwrseq_simple: remove unused header file
  33   33 85ead8185a76 f2fs: delete unnecessary wait for page writeback
 100  100 4ec0ef3a8212 USB: iowarrior: fix oops with malicious USB descriptors
 100  100 5821a33b9bbd Staging: Android: align code with open parenthesis in ion_carveout_heap.c
 100  100 9f93a8a0ba91 crypto: api - Introduce crypto_queue_len() helper function
 100   92 06b241f32c71 mm: __delete_from_page_cache show Bad page if mapped
 100  100 c0992d0f5484 USB: serial: option: add support for Quectel UC20
  71   42 3158a8d416f4 USB: option: add support for SIM7100E
  87   50 ff4e2494dc17 USB: serial: option: Adding support for Telit LE922
  90  100 64a67d4762ce mmc: pwrseq_simple: Make reset-gpios optional to match doc
 100  100 c10368897e10 ALSA: compress: add support for 32bit calls in a 64bit kernel
  99  100 a5beaaf39455 usb: gadget: Add the console support for usb-to-serial port
 100  100 100a606d54a0 mmc: core: Introduce MMC_CAP2_NO_SDIO cap
  66  100 ffedbd2210f2 mmc: pwrseq: constify mmc_pwrseq_ops structures
  66  100 1ff2575bcf42 mmc: core: Check for non-removable cards earlier in the error path
 100  100 c29536e85b5f mmc: core: Make runtime resume default behavior for MMC/SD
 100  100 d234d2123fa7 mmc: core: Keep host claimed in mmc_rescan() while calling host ops
 100  100 86236813ff23 mmc: core: Invoke ->card_event() callback only when needed

Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mmc@vger.kernel.org
Cc: linux-serial@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: dccp@vger.kernel.org
Cc: alsa-devel@alsa-project.org

