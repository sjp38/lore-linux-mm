Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21A30C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 08:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAF3921670
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 08:15:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TLyV+Rdv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAF3921670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CA1D6B04DE; Sat, 24 Aug 2019 04:15:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A686B04DF; Sat, 24 Aug 2019 04:15:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4907A6B04E0; Sat, 24 Aug 2019 04:15:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 215DA6B04DE
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 04:15:38 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B8D034FF7
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 08:15:37 +0000 (UTC)
X-FDA: 75856612314.19.fish59_4e2cdd1fc7d0f
X-HE-Tag: fish59_4e2cdd1fc7d0f
X-Filterd-Recvd-Size: 13284
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 08:15:37 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id z3so25661418iog.0
        for <linux-mm@kvack.org>; Sat, 24 Aug 2019 01:15:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kyA+aiqDA7g9aPwx+XergEgNv0HEfm8l2LrxUIwWz3Q=;
        b=TLyV+RdvvpvCPuqNANa+zQPkubqkvbksTWDY236PX9F22IfaioLqbE85xRCeXrT8Om
         hMgBMi+e08/+9Inn+0mGCSYMBNAuuok/K2+dSb5C+krNTrgbnvqMIYSY8PnR8+M3/pEr
         +KI9lPiBnpwCKBEc+JRaQFoFcQ27WKG7l6RWOReuGDkNYce7jc9bs2IHaSHzKJah0V5f
         koHW4h96LtwwLQ/9ZPN06MjhUXIm6nXTQz0+3RBe/gdV2HE+gbS0Grw1vZqlhDGRee94
         3uemiLLtDoCBNPCPMCmiqSsqCTdJVh6v0AcMO9IMyDRzM4xcRLdywdH12M9ZrG99D1qL
         HLNw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=kyA+aiqDA7g9aPwx+XergEgNv0HEfm8l2LrxUIwWz3Q=;
        b=Tcd3mS6b0msXYH3J9EKvlut7g6pzw1wHI8fjmDG8B6+S2yBXvvpBdeGnwSx9OZDahJ
         sXktiG2a3DzF5yRDTTqu8zlfu2cpUAqkAa1Khzp0P9beUPcTPz7qbAiBUZiLWaejtYlP
         84tNo4fWiRwD0pU3HHBP2RNB9Pe45edgSdfOgBx0SZbUIiZFuvg9o5ZeCbOBvEVyl6yd
         PETpEndkpEkW3gYZ7wHgqcfjnnUjktItmGXjMFBH104zvWOva7ygmqeQwJrRRps7Z4nr
         PtaERYd3nyU+LMzdN2lUaK022fnnfFFpR1+NVhVUsfX39JQDjxEr3bIGTP8O+nxnfAEj
         ljOg==
X-Gm-Message-State: APjAAAXtzVk0tjVP7+8UZU68tgEiC7970/7rILnOqTgGz74aA6Dd6hUS
	qtkOQDWeP/zSqE74CY+Iv+IEyjIqCXl0rh8anIs=
X-Google-Smtp-Source: APXvYqzN0V2GodIbUCzHrx8suNiK0pCba4E8jOJb48ry1vQe2RsEIOvot6+1g6/rN8fPW2mCYvwiv099nRApZqvm1FM=
X-Received: by 2002:a5d:934c:: with SMTP id i12mr5096328ioo.203.1566634536298;
 Sat, 24 Aug 2019 01:15:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190824045143.9276-1-hdanton@sina.com>
In-Reply-To: <20190824045143.9276-1-hdanton@sina.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 24 Aug 2019 16:15:00 +0800
Message-ID: <CALOAHbDEmoZi8Lo47Re2Txjrkk6sZEsWRsvXJW8q_J9-gsstnw@mail.gmail.com>
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup and
 fullmemory usage
To: Hillf Danton <hdanton@sina.com>
Cc: Adric Blake <promarbler14@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Kirill Tkhai <ktkhai@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Yang Shi <yang.shi@linux.alibaba.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 24, 2019 at 12:51 PM Hillf Danton <hdanton@sina.com> wrote:
>
>
> On Sat, 24 Aug 2019 11:36:31 +0800 Yafang Shao wrote:
> > On Sat, Aug 24, 2019 at 10:57 AM Hillf Danton <hdanton@sina.com> wrote:
> > > On Fri, 23 Aug 2019 18:00:15 -0400 Adric Blake wrote:
> > > > Synopsis:
> > > > A WARN_ON_ONCE is hit twice in set_task_reclaim_state under the
> > > > following conditions:
> > > > - a memory cgroup has been created and a task assigned it it
> > > > - memory.limit_in_bytes has been set
> > > > - memory has filled up, likely from cache
> > > >
> > > Thanks for report.
> > >
> > > > In my usage, I create a cgroup under the current session scope and
> > > > assign a task to it. I then set memory.limit_in_bytes and
> > > > memory.soft_limit_in_bytes for the cgroup to reasonable values, say
> > > > 1G/512M. The program accesses large files frequently and gradually
> > > > fills memory with the page cache. The warnings appears when the
> > > > entirety of the system memory is filled, presumably from other
> > > > programs.
> > > >
> > > > If I wait until the program has filled the entirety of system memory
> > > > with cache and then assign a memory limit, the warnings appear
> > > > immediately.
> > > >
> > > > I am building the linux git. I first noticed this issue with the
> > > > drm-tip 5.3rc3 and 5.3rc4 kernels, and tested linux master after
> > > > 5.3rc5 to confirm the bug more resoundingly.
> > > >
> > > > Here are the warnings.
> > > >
> > > > [38491.963105] WARNING: CPU: 7 PID: 175 at mm/vmscan.c:245 set_task_reclaim_state+0x1e/0x40
> > > > [38491.963106] Modules linked in: iwlmvm mac80211 libarc4 iwlwifi
> > > > cfg80211 xt_comment nls_iso8859_1 nls_cp437 vfat fat xfs jfs btrfs xor
> > > > raid6_pq libcrc32c ccm tun rfcomm fuse xt_tcpudp ip6t_REJECT
> > > > nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_multiport xt_owner
> > > > snd_hda_codec_hdmi ip6table_filter ip6_tables iptable_filter bnep ext4
> > > > crc32c_generic mbcache jbd2 snd_hda_codec_realtek
> > > > snd_hda_codec_generic snd_soc_skl snd_soc_hdac_hda snd_hda_ext_core
> > > > snd_soc_skl_ipc x86_pkg_temp_thermal intel_powerclamp snd_soc_sst_ipc
> > > > coretemp snd_soc_sst_dsp snd_soc_acpi_intel_match kvm_intel
> > > > snd_soc_acpi i915 snd_soc_core kvm snd_compress ac97_bus
> > > > snd_pcm_dmaengine snd_hda_intel i2c_algo_bit btusb irqbypass
> > > > drm_kms_helper btrtl snd_hda_codec dell_laptop btbcm crct10dif_pclmul
> > > > snd_hda_core crc32c_intel btintel iTCO_wdt ghash_clmulni_intel drm
> > > > ledtrig_audio aesni_intel iTCO_vendor_support snd_hwdep dell_wmi
> > > > rtsx_usb_ms r8169 dell_smbios aes_x86_64 mei_hdcp crypto_simd
> > > > intel_gtt bluetooth snd_pcm cryptd dcdbas
> > > > [38491.963155]  wmi_bmof dell_wmi_descriptor intel_rapl_msr
> > > > glue_helper snd_timer joydev intel_cstate snd realtek memstick
> > > > dell_smm_hwmon mousedev psmouse input_leds libphy intel_uncore
> > > > ecdh_generic ecc crc16 rfkill intel_rapl_perf soundcore i2c_i801
> > > > agpgart mei_me tpm_crb syscopyarea sysfillrect sysimgblt mei
> > > > intel_xhci_usb_role_switch fb_sys_fops idma64 tpm_tis roles
> > > > processor_thermal_device intel_rapl_common i2c_hid tpm_tis_core
> > > > int3403_thermal intel_soc_dts_iosf battery wmi intel_lpss_pci
> > > > intel_lpss intel_pch_thermal tpm int3400_thermal int3402_thermal
> > > > acpi_thermal_rel int340x_thermal_zone rng_core intel_hid ac
> > > > sparse_keymap evdev mac_hid crypto_user ip_tables x_tables
> > > > hid_multitouch rtsx_usb_sdmmc mmc_core rtsx_usb hid_logitech_hidpp
> > > > sr_mod cdrom sd_mod uas usb_storage hid_logitech_dj hid_generic usbhid
> > > > hid ahci serio_raw libahci atkbd libps2 libata xhci_pci scsi_mod
> > > > xhci_hcd crc32_pclmul i8042 serio f2fs [last unloaded: cfg80211]
> > > > [38491.963221] CPU: 7 PID: 175 Comm: kswapd0 Not tainted 5.3.0-rc5+149+gbb7ba8069de9 #1
> > > > [38491.963222] Hardware name: Dell Inc. Inspiron 5570/09YTN7, BIOS 1.2.3 05/15/2019
> > > > [38491.963226] RIP: 0010:set_task_reclaim_state+0x1e/0x40
> > > > [38491.963228] Code: 78 a9 e7 ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00
> > > > 00 55 48 89 f5 53 48 89 fb 48 85 ed 48 8b 83 08 08 00 00 74 11 48 85
> > > > c0 74 02 <0f> 0b 48 89 ab 08 08 00 00 5b 5d c3 48 85 c0 75 f1 0f 0b 48
> > > > 89 ab
> > > > [38491.963229] RSP: 0018:ffff8c898031fc60 EFLAGS: 00010286
> > > > [38491.963230] RAX: ffff8c898031fe28 RBX: ffff892aa04ddc40 RCX: 0000000000000000
> > > > [38491.963231] RDX: ffff8c898031fc60 RSI: ffff8c898031fcd0 RDI: ffff892aa04ddc40
> > > > [38491.963233] RBP: ffff8c898031fcd0 R08: ffff8c898031fd48 R09: ffff89279674b800
> > > > [38491.963234] R10: 00000000ffffffff R11: 0000000000000000 R12: ffff8c898031fd48
> > > > [38491.963235] R13: ffff892a842ef000 R14: ffff892aaf7fc000 R15: 0000000000000000
> > > > [38491.963236] FS:  0000000000000000(0000) GS:ffff892aa33c0000(0000) knlGS:0000000000000000
> > > > [38491.963238] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > [38491.963239] CR2: 00007f90628fa000 CR3: 000000027ee0a002 CR4: 00000000003606e0
> > > > [38491.963239] Call Trace:
> > > > [38491.963246]  mem_cgroup_shrink_node+0x9b/0x1d0
> > > > [38491.963250]  mem_cgroup_soft_limit_reclaim+0x10c/0x3a0
> > > > [38491.963254]  balance_pgdat+0x276/0x540
> > > > [38491.963258]  kswapd+0x200/0x3f0
> > > > [38491.963261]  ? wait_woken+0x80/0x80
> > > > [38491.963265]  kthread+0xfd/0x130
> > > > [38491.963267]  ? balance_pgdat+0x540/0x540
> > > > [38491.963269]  ? kthread_park+0x80/0x80
> > > > [38491.963273]  ret_from_fork+0x35/0x40
> > > > [38491.963276] ---[ end trace 727343df67b2398a ]---
> > >
> > > Save and restore reclaim state for global reclaimer as it
> > > can be clobbered by memcg.
> > >
> >
> > Hi Hillf,
> >
> > Thanks for your patch. It could fix this issue.
> > But I'm wondering if it is proper to place a new scan_control in
> > mem_cgroup_shrink_node().
>
> Hi Yafang
>
> Good point.
>
> > Because the page alloction context is stored in the original
> > scan_control, but this new scan_control beaks it at all.
> > For example, the sc.nodemask is the page allocation preferred node,
> > but it is override by the new scan_control, that may cause extra
> > useless page reclaim, especially in the direct reclaim path.
> >
> We can fix that break in concern that it will not make MH grumpy,
> see below for detail.
>
> > Thanks
> > Yafang
> > > --- a/mm/vmscan.c
> > > +++ b/bb/vmscan.c
> > > @@ -253,6 +253,22 @@ static void set_task_reclaim_state(struc
> > >         task->reclaim_state =3D rs;
> > >  }
> > >
> > > +static struct reclaim_state *
> > > +save_task_reclaim_state(struct task_struct *task)
> > > +{
> > > +       struct reclaim_state *rs =3D task->reclaim_state;
> > > +       if (rs)
> > > +               set_task_reclaim_state(task, NULL);
> > > +       return rs;
> > > +}
> > > +
> > > +static void restore_task_reclaim_state(struct task_struct *task,
> > > +                                       struct reclaim_state *rs)
> > > +{
> > > +       if (rs)
> > > +               set_task_reclaim_state(task, rs);
> > > +}
> > > +
> > >  #ifdef CONFIG_MEMCG
> > >  static bool global_reclaim(struct scan_control *sc)
> > >  {
> > > @@ -3241,7 +3257,9 @@ unsigned long mem_cgroup_shrink_node(str
> > >                 .may_shrinkslab =3D 1,
> > >         };
> > >         unsigned long lru_pages;
> > > +       struct reclaim_state *rs;
> > >
> > > +       rs =3D save_task_reclaim_state(current);
> > >         set_task_reclaim_state(current, &sc.reclaim_state);
> > >         sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> > >                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> > > @@ -3261,6 +3279,7 @@ unsigned long mem_cgroup_shrink_node(str
> > >         trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
> > >
> > >         set_task_reclaim_state(current, NULL);
> > > +       restore_task_reclaim_state(current, rs);
> > >         *nr_scanned =3D sc.nr_scanned;
> > >
> > >         return sc.nr_reclaimed;
> > > --
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3260,6 +3260,25 @@ unsigned long mem_cgroup_shrink_node(str
>         struct reclaim_state *rs;
>
>         rs = save_task_reclaim_state(current);
> +       if (rs) {
> +               struct scan_control *save_sc = container_of(rs,
> +                               struct scan_control, reclaim_state);
> +
> +               sc.may_writepage  = save_sc->may_writepage;
> +               sc.may_unmap      = save_sc->may_unmap;
> +               sc.reclaim_idx    = save_sc->reclaim_idx;
> +               sc.may_swap       = save_sc->may_swap;
> +               sc.may_shrinkslab = save_sc->may_shrinkslab;
> +               /*
> +               sc.order          = save_sc->order;
> +               sc.nr_to_reclaim  = save_sc->nr_to_reclaim;
> +
> +               or simply duplicate it as memcg reclaiming is smart enough;)
> +
> +               sc = *save_sc;
> +               sc.target_mem_cgroup = memcg;
> +               */
> +       }
>         set_task_reclaim_state(current, &sc.reclaim_state);
>         sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> --
>

The memcg soft reclaim is called from kswapd reclam path and direct
reclaim path,
so why not pass the scan_control from the callsite in these two
reclaim paths and use it in memcg soft reclaim ?
Seems there's no specially reason that we must introduce a new
scan_control here.


> And then make memcg soft-limit reclaiming forget reclaiming order.
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2984,9 +2984,6 @@ unsigned long mem_cgroup_soft_limit_recl
>         unsigned long excess;
>         unsigned long nr_scanned;
>
> -       if (order > 0)
> -               return 0;
> -


I have checked the hisotry why this order check is introduced here.
The first commit is 4e41695356fb ("memory controller: soft limit
reclaim on contention"),
but it didn't explained why.
At the first glance it is reasonable to remove it, but we should
understand why it was introduced at the first place.

>         mctz = soft_limit_tree_node(pgdat->node_id);
>
>         /*
> --
>

