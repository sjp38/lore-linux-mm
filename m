Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38328C4332F
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 11:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C78DB21479
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 11:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rWVKQrPC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C78DB21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614646B0005; Sun,  8 Sep 2019 07:09:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5236B0006; Sun,  8 Sep 2019 07:09:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B2E06B0007; Sun,  8 Sep 2019 07:09:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 2191D6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 07:09:27 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C6101813E
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 11:09:26 +0000 (UTC)
X-FDA: 75911482332.20.bun64_8c8e5d8741429
X-HE-Tag: bun64_8c8e5d8741429
X-Filterd-Recvd-Size: 23754
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com [209.85.167.67])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 11:09:25 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id q27so8282276lfo.10
        for <linux-mm@kvack.org>; Sun, 08 Sep 2019 04:09:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=aihZM1X1CEOUIRMDG8QNQidnhEFdFRnLaM11TyfJl54=;
        b=rWVKQrPCw5Mesid2BwvXG9xfWSNMpD8i4axuEJ/liDi3OmN3P1b7kSzcYdHoZropGJ
         EX/mAXWbzJfxuMm+r3oAXjmGDsvUpr/BeEywJpqIs7FNxqYsqODlaFmls9Z8PeXFwc2q
         BkGk9qk3mjhhNrOlXnF3qXaQtHrCnB4FC1KSUSKXrx4tug7oGzfNmIN0+eRht920iJsf
         5SA5B1zGKGfkqF9XThSM12NrlxtVrL1MQhT3MyBNC2NVzjpPwKPvqM1iX7HbU23xKBKi
         ePa6L5aa7iypTTryyaAu+gscjlcJ82oEL/83oaxwTiHo0wD2zZaPUjrwPvmGKMwxEdal
         k0Nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=aihZM1X1CEOUIRMDG8QNQidnhEFdFRnLaM11TyfJl54=;
        b=OXLFgln01ojEOggj4rCfs28TcghSPNlncx5cMMwn4rYtRHpFjVOSZycCFyCDxhEGpP
         s7QahN4BfCh8GjElq5SFzV2oLZKaynTUbDWbYHAe9cXoIubCRBdR+sxXuwreeGKr4f8K
         DJhPkDhS6cIuUyHk/fWDCaLwZfQGGoN2sCusClIPA1P2XCFXOstk6/tEu8M8xuiZoMmc
         Hp7e98N3tCSVbdRZIfn3njbQp+AIS4QZJmy/T34+enHxjFNol9/7ISm76EpSDu1bzS3a
         RQmGKPzGrtycf4/PJU+mGpze1zZPw0oxkdPgMwXanwR+hfQQX8qEfhZxlQO3tSkhX23R
         iZeQ==
X-Gm-Message-State: APjAAAVQl67AuGN3dUCUT7ipEexBgOOcNHN+hTuvcIUWQBAwii1s6fyo
	DuIp/av8S5yn4BiMv7zvTR9Cf09ivVBVHa9cEsk=
X-Google-Smtp-Source: APXvYqyfFDarIldB/FGSwTwf1RLgplGSXlD53D/KYyyWujxGAt2OhNzofsddPQnFJ1Da496gQE8ujhvaWs8vHgfGzgU=
X-Received: by 2002:ac2:5ec8:: with SMTP id d8mr13376216lfq.183.1567940964124;
 Sun, 08 Sep 2019 04:09:24 -0700 (PDT)
MIME-Version: 1.0
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar> <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz>
In-Reply-To: <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sun, 8 Sep 2019 14:09:12 +0300
Message-ID: <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
Subject: Re: CRASH: General protection fault in z3fold
To: Vlastimil Babka <vbabka@suse.cz>
Cc: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>, 
	Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey,

On Thu, Sep 5, 2019 at 2:55 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> +CC Vitaly

Thanks for CC'ing Vlastimil.

> On 9/5/19 6:05 AM, Agust=C3=ADn Dall=CA=BCAlba wrote:
> > Hello,
> >
> > I've been experiencing crashes using zswap with the z3fold allocator. T=
he
> > crashes happen once I'm using more memory than fits in the zpool. I can
> > reliably reproduce the crash on v5.3-rc7 with these steps:
> >
> > 1. Enable swap. My swap is located on a small 16 GB SSD that I dedicate=
 to
> >    this purpose, encrypted with dm-crypt. I didn't test other backing d=
evices.
> > 2. echo z3fold > /sys/module/zswap/parameters/zpool
> >    echo lz4 > /sys/module/zswap/parameters/compressor
> >    echo 1 > /sys/module/zswap/parameters/enabled
> > 3. `watch -d grep -r . /sys/kernel/debug/zswap/` to monitor the statist=
ics.
> >    The most important parameter is pool_limit_hit.
> > 4. Use a lot of memory. I spawn several `stress -m 1 --vm-hang 0&`.
> > 5. At some point, pool_limit_hit starts increasing. Soon after TRACE 1
> >    (at the bottom of the email) appears in dmesg.
> > 6. Now at least 1 process is in an unkillable state and I must reset my=
 CPU.
> >
> > Additional notes:
> >  - I can't reproduce the issue with zbud or zsmalloc. For now I'm using
> >    zsmalloc as a workaround.
> >  - Sometimes TRACE 2 and/or TRACE 3 appear in dmesg after or before
> >    the protection fault.
> >  - If I run swapoff after the fault it seems to only move a handful of
> >    pages per second so I haven't left it running long enough to see if
> >    it ever finishes.
> >
> > I first noticed this bug on 5.2.11 but I noticed there had been several
> > commits to z3fold in 5.3 so I compiled rc7 using the Arch Linux config =
file.

Would you care to test with
https://bugzilla.kernel.org/attachment.cgi?id=3D284883 ? That one should
fix the problem you're facing.

> > I think this isn't a regression: A few months ago I tried zswap and end=
ed up
> > disabling it because it crashed my machine, but I didn't have time to f=
igure
> > out why back then. But that might have been a different bug. I'm willin=
g
> > to test older versions, of course.

I believe this was introduced in 5.2 with the changes to make z3fold
pages movable. 5.1 should be ok.

Best regards,
   Vitaly

> > I'm sorry if this has already been reported, I've seen a few similar re=
ports
> > but not one exactly like this.
> >
> > Kind regards,
> >
> > Agust=C3=ADn.
> >
> >
> > Additional information:
> >
> > /proc/version
> > Linux version 5.3.0-rc7-1-ARCH (agustin@hostname) (gcc version 9.1.0 (G=
CC)) #1 SMP PREEMPT Wed Sep 4 17:23:45 -03 2019
> >
> > /proc/iomem
> > 00000000-00000fff : Reserved
> > 00001000-00057fff : System RAM
> > 00058000-00058fff : Reserved
> > 00059000-0008bfff : System RAM
> > 0008c000-0009ffff : Reserved
> > 000a0000-000bffff : PCI Bus 0000:00
> > 000c0000-000cfdff : Video ROM
> > 000d0000-000d3fff : pnp 00:00
> > 000d4000-000d7fff : pnp 00:00
> > 000d8000-000dbfff : pnp 00:00
> > 000dc000-000dffff : pnp 00:00
> > 000e0000-000fffff : Reserved
> >   000f0000-000fffff : System ROM
> > 00100000-c006d017 : System RAM
> >   66600000-67200e20 : Kernel code
> >   67200e21-6794a3ff : Kernel data
> >   67e87000-681fffff : Kernel bss
> > c006d018-c007d657 : System RAM
> > c007d658-c007e017 : System RAM
> > c007e018-c008e057 : System RAM
> > c008e058-cbd01fff : System RAM
> > cbd02000-ccbfdfff : Reserved
> > ccbfe000-ccd7dfff : ACPI Non-volatile Storage
> > ccd7e000-ccdfdfff : ACPI Tables
> > ccdfe000-ccdfefff : System RAM
> > ccdff000-ccdfffff : MSFT0101:00
> >   ccdff000-ccdff02f : MSFT0101:00
> >   ccdff080-ccdfffff : MSFT0101:00
> > cce00000-cdffffff : RAM buffer
> > ce000000-cfffffff : Reserved
> >   ce000000-cfffffff : Graphics Stolen Memory
> > d0000000-febfffff : PCI Bus 0000:00
> >   d0000000-d000ffff : pnp 00:05
> >   d0010000-d001ffff : pnp 00:05
> >   e0000000-efffffff : 0000:00:02.0
> >   f0000000-f0ffffff : 0000:00:02.0
> >   f1000000-f10fffff : PCI Bus 0000:03
> >     f1000000-f1001fff : 0000:03:00.0
> >       f1000000-f1001fff : iwlwifi
> >   f1100000-f11fffff : PCI Bus 0000:02
> >     f1100000-f1100fff : 0000:02:00.0
> >       f1100000-f1100fff : rtsx_pci
> >   f1200000-f121ffff : 0000:00:19.0
> >     f1200000-f121ffff : e1000e
> >   f1220000-f122ffff : 0000:00:14.0
> >     f1220000-f122ffff : xhci-hcd
> >   f1230000-f1233fff : 0000:00:03.0
> >     f1230000-f1233fff : ICH HD audio
> >   f1234000-f1237fff : 0000:00:1b.0
> >     f1234000-f1237fff : ICH HD audio
> >   f1238000-f12380ff : 0000:00:1f.3
> >   f1239000-f123901f : 0000:00:16.0
> >     f1239000-f123901f : mei_me
> >   f123b000-f123bfff : 0000:00:1f.6
> >     f123b000-f123bfff : Intel PCH thermal driver
> >   f123c000-f123c7ff : 0000:00:1f.2
> >     f123c000-f123c7ff : ahci
> >   f123d000-f123d3ff : 0000:00:1d.0
> >     f123d000-f123d3ff : ehci_hcd
> >   f123e000-f123efff : 0000:00:19.0
> >     f123e000-f123efff : e1000e
> >   f8000000-fbffffff : PCI MMCONFIG 0000 [bus 00-3f]
> >     f80f8000-f80f8fff : Reserved
> > fec00000-fec003ff : IOAPIC 0
> > fed00000-fed003ff : HPET 0
> >   fed00000-fed003ff : PNP0103:00
> > fed10000-fed17fff : pnp 00:01
> > fed18000-fed18fff : pnp 00:01
> > fed19000-fed19fff : pnp 00:01
> > fed1c000-fed1ffff : Reserved
> >   fed1c000-fed1ffff : pnp 00:01
> >     fed1f410-fed1f414 : iTCO_wdt.0.auto
> >       fed1f410-fed1f414 : iTCO_wdt.0.auto
> >     fed1f800-fed1f9ff : intel-spi
> >       fed1f800-fed1f9ff : intel-spi
> > fed40000-fed4bfff : PCI Bus 0000:00
> >   fed45000-fed4bfff : pnp 00:01
> > fed70000-fed70fff : MSFT0101:00
> >   fed70000-fed70fff : MSFT0101:00
> > fed90000-fed90fff : dmar0
> > fed91000-fed91fff : dmar1
> > fee00000-fee00fff : Local APIC
> > 100000000-12dffffff : System RAM
> > 12e000000-12fffffff : RAM buffer
> >
> > /proc/config.gz
> > (attached)
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > TRACE 1: WARNING z3fold.c:428 + general protection fault
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > ------------[ cut here ]------------
> > WARNING: CPU: 2 PID: 144 at mm/z3fold.c:428 handle_to_buddy.cold+0xc/0x=
13
> > Modules linked in: ccm bnep fuse snd_hda_codec_hdmi uvcvideo joydev mou=
sedev rmi_smbus rmi_core videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 =
videobuf2_common btusb videodev btrtl btbcm btintel bluetooth mc msr intel_=
rapl_msr intel_rapl_common ecdh_generic ecc x86_pkg_temp_thermal crc16 i915=
 intel_powerclamp coretemp kvm_intel lz4 lz4_compress iwlmvm i2c_algo_bit d=
rm_kms_helper mac80211 kvm drm ofpart snd_hda_codec_realtek cmdlinepart lib=
arc4 nls_iso8859_1 snd_hda_codec_generic intel_spi_platform nls_cp437 intel=
_spi vfat spi_nor snd_hda_intel wmi_bmof mei_wdt iwlwifi mei_hdcp irqbypass=
 intel_gtt fat iTCO_wdt intel_cstate snd_hda_codec agpgart mtd syscopyarea =
tpm_crb intel_uncore iTCO_vendor_support snd_hda_core tpm_tis rtsx_pci_ms p=
smouse snd_hwdep tpm_tis_core thinkpad_acpi input_leds cfg80211 sysfillrect=
 pcspkr intel_rapl_perf nvram sysimgblt memstick ledtrig_audio tpm snd_pcm =
wmi battery rfkill ac fb_sys_fops mei_me rng_core snd_timer evdev e1000e in=
tel_pch_thermal
> >  mac_hid mei snd lpc_ich i2c_i801 soundcore crypto_user ip_tables x_tab=
les btrfs libcrc32c crc32c_generic xor raid6_pq dm_crypt dm_mod sd_mod crct=
10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel rtsx_pci_sdmmc s=
erio_raw mmc_core atkbd libps2 aesni_intel ahci aes_x86_64 crypto_simd liba=
hci xhci_pci cryptd glue_helper xhci_hcd libata scsi_mod ehci_pci ehci_hcd =
rtsx_pci i8042 serio
> > CPU: 2 PID: 144 Comm: kswapd0 Not tainted 5.3.0-rc7-1-ARCH #1
> > Hardware name: LENOVO 20BXCTO1WW/20BXCTO1WW, BIOS JBET63WW (1.27 ) 11/1=
0/2016
> > RIP: 0010:handle_to_buddy.cold+0xc/0x13
> > Code: 44 24 10 85 c0 0f 85 61 ff ff ff 4c 8b 44 24 18 4d 85 c0 0f 85 f8=
 fe ff ff e9 f7 fd ff ff 48 c7 c7 80 c7 ea 94 e8 42 c2 e5 ff <0f> 0b e9 6f =
de ff ff 48 c7 c7 80 c7 ea 94 e8 2f c2 e5 ff 0f 0b 48
> > RSP: 0018:ffffa7ab0023f830 EFLAGS: 00010246
> > RAX: 0000000000000024 RBX: ffff93a5fe157001 RCX: 0000000000000000
> > RDX: 0000000000000000 RSI: ffff93a669a97708 RDI: 00000000ffffffff
> > RBP: ffff93a5fe157000 R08: 0000000000000532 R09: 0000000000000004
> > R10: 0000000000000000 R11: 0000000000000001 R12: ffff93a5fe157001
> > R13: ffff93a5fe157010 R14: ffff93a64a505848 R15: ffff93a64a505840
> > FS:  0000000000000000(0000) GS:ffff93a669a80000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00007fb7ee08a928 CR3: 000000005b20a001 CR4: 00000000003606e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > Call Trace:
> >  z3fold_zpool_map+0x76/0x100
> >  zswap_writeback_entry+0x5b/0x3b0
> >  z3fold_zpool_shrink+0x28b/0x4a0
> >  zswap_frontswap_store+0x12a/0x6a0
> >  __frontswap_store+0xa6/0xf0
> >  swap_writepage+0x39/0x70
> >  pageout.isra.0+0x12b/0x360
> >  shrink_page_list+0x74b/0xb80
> >  shrink_inactive_list+0x24f/0x410
> >  shrink_node_memcg+0x258/0x7b0
> >  shrink_node+0xe8/0x4f0
> >  balance_pgdat+0x2e3/0x530
> >  kswapd+0x200/0x3f0
> >  ? wait_woken+0x70/0x70
> >  kthread+0xfb/0x130
> >  ? balance_pgdat+0x530/0x530
> >  ? kthread_park+0x80/0x80
> >  ret_from_fork+0x35/0x40
> > ---[ end trace c799dc3361263fe2 ]---
> > general protection fault: 0000 [#1] PREEMPT SMP PTI
> > CPU: 2 PID: 144 Comm: kswapd0 Tainted: G        W         5.3.0-rc7-1-A=
RCH #1
> > Hardware name: LENOVO 20BXCTO1WW/20BXCTO1WW, BIOS JBET63WW (1.27 ) 11/1=
0/2016
> > RIP: 0010:handle_to_buddy+0x20/0x30
> > Code: 8b 47 38 48 c1 e0 0c c3 66 90 0f 1f 44 00 00 53 48 89 fb 83 e7 01=
 0f 85 7e 21 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00 f0 ff ff <0f> b6 52 52 =
29 d0 83 e0 03 c3 66 0f 1f 44 00 00 0f 1f 44 00 00 55
> > RSP: 0018:ffffa7ab0023f838 EFLAGS: 00010206
> > RAX: 00ffff93a5fe1570 RBX: ffffd09502f855c0 RCX: 0000000000000000
> > RDX: 00ffff93a5fe1000 RSI: ffff93a669a97708 RDI: 00000000ffffffff
> > RBP: ffff93a5fe157000 R08: 0000000000000532 R09: 0000000000000004
> > R10: 0000000000000000 R11: 0000000000000001 R12: ffff93a5fe157001
> > R13: ffff93a5fe157010 R14: ffff93a64a505848 R15: ffff93a64a505840
> > FS:  0000000000000000(0000) GS:ffff93a669a80000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00007fb7ee08a928 CR3: 000000005b20a001 CR4: 00000000003606e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > Call Trace:
> >  z3fold_zpool_map+0x76/0x100
> >  zswap_writeback_entry+0x5b/0x3b0
> >  z3fold_zpool_shrink+0x28b/0x4a0
> >  zswap_frontswap_store+0x12a/0x6a0
> >  __frontswap_store+0xa6/0xf0
> >  swap_writepage+0x39/0x70
> >  pageout.isra.0+0x12b/0x360
> >  shrink_page_list+0x74b/0xb80
> >  shrink_inactive_list+0x24f/0x410
> >  shrink_node_memcg+0x258/0x7b0
> >  shrink_node+0xe8/0x4f0
> >  balance_pgdat+0x2e3/0x530
> >  kswapd+0x200/0x3f0
> >  ? wait_woken+0x70/0x70
> >  kthread+0xfb/0x130
> >  ? balance_pgdat+0x530/0x530
> >  ? kthread_park+0x80/0x80
> >  ret_from_fork+0x35/0x40
> > Modules linked in: ccm bnep fuse snd_hda_codec_hdmi uvcvideo joydev mou=
sedev rmi_smbus rmi_core videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 =
videobuf2_common btusb videodev btrtl btbcm btintel bluetooth mc msr intel_=
rapl_msr intel_rapl_common ecdh_generic ecc x86_pkg_temp_thermal crc16 i915=
 intel_powerclamp coretemp kvm_intel lz4 lz4_compress iwlmvm i2c_algo_bit d=
rm_kms_helper mac80211 kvm drm ofpart snd_hda_codec_realtek cmdlinepart lib=
arc4 nls_iso8859_1 snd_hda_codec_generic intel_spi_platform nls_cp437 intel=
_spi vfat spi_nor snd_hda_intel wmi_bmof mei_wdt iwlwifi mei_hdcp irqbypass=
 intel_gtt fat iTCO_wdt intel_cstate snd_hda_codec agpgart mtd syscopyarea =
tpm_crb intel_uncore iTCO_vendor_support snd_hda_core tpm_tis rtsx_pci_ms p=
smouse snd_hwdep tpm_tis_core thinkpad_acpi input_leds cfg80211 sysfillrect=
 pcspkr intel_rapl_perf nvram sysimgblt memstick ledtrig_audio tpm snd_pcm =
wmi battery rfkill ac fb_sys_fops mei_me rng_core snd_timer evdev e1000e in=
tel_pch_thermal
> >  mac_hid mei snd lpc_ich i2c_i801 soundcore crypto_user ip_tables x_tab=
les btrfs libcrc32c crc32c_generic xor raid6_pq dm_crypt dm_mod sd_mod crct=
10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel rtsx_pci_sdmmc s=
erio_raw mmc_core atkbd libps2 aesni_intel ahci aes_x86_64 crypto_simd liba=
hci xhci_pci cryptd glue_helper xhci_hcd libata scsi_mod ehci_pci ehci_hcd =
rtsx_pci i8042 serio
> > ---[ end trace c799dc3361263fe3 ]---
> > RIP: 0010:handle_to_buddy+0x20/0x30
> > Code: 8b 47 38 48 c1 e0 0c c3 66 90 0f 1f 44 00 00 53 48 89 fb 83 e7 01=
 0f 85 7e 21 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00 f0 ff ff <0f> b6 52 52 =
29 d0 83 e0 03 c3 66 0f 1f 44 00 00 0f 1f 44 00 00 55
> > RSP: 0018:ffffa7ab0023f838 EFLAGS: 00010206
> > RAX: 00ffff93a5fe1570 RBX: ffffd09502f855c0 RCX: 0000000000000000
> > RDX: 00ffff93a5fe1000 RSI: ffff93a669a97708 RDI: 00000000ffffffff
> > RBP: ffff93a5fe157000 R08: 0000000000000532 R09: 0000000000000004
> > R10: 0000000000000000 R11: 0000000000000001 R12: ffff93a5fe157001
> > R13: ffff93a5fe157010 R14: ffff93a64a505848 R15: ffff93a64a505840
> > FS:  0000000000000000(0000) GS:ffff93a669a80000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00007fb7ee08a928 CR3: 000000005b20a001 CR4: 00000000003606e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > note: kswapd0[144] exited with preempt_count 1
> >
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > TRACE 2: z3fold_zpool_destroy blocked
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > INFO: task kworker/2:3:335 blocked for more than 122 seconds.
> >       Not tainted 5.3.0-rc7-1-ARCH #1
> > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this messag=
e.
> > kworker/2:3     D    0   335      2 0x80004080
> > Workqueue: events __zswap_pool_release
> > Call Trace:
> >  ? __schedule+0x27f/0x6d0
> >  schedule+0x43/0xd0
> >  z3fold_zpool_destroy+0xe9/0x130
> >  ? wait_woken+0x70/0x70
> >  zpool_destroy_pool+0x5c/0x90
> >  __zswap_pool_release+0x6a/0xb0
> >  process_one_work+0x1d1/0x3a0
> >  worker_thread+0x4a/0x3d0
> >  kthread+0xfb/0x130
> >  ? process_one_work+0x3a0/0x3a0
> >  ? kthread_park+0x80/0x80
> >  ret_from_fork+0x35/0x40
> >
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > TRACE 3: page allocation failure (probably unrelated)
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > gnome-shell: page allocation failure: order:0, mode:0x400d0(__GFP_IO|__=
GFP_FS|__GFP_COMP|__GFP_RECLAIMABLE), nodemask=3D(null),cpuset=3D/,mems_all=
owed=3D0
> > CPU: 2 PID: 1022 Comm: gnome-shell Not tainted 5.3.0-rc7-1-ARCH #1
> > Hardware name: LENOVO 20BXCTO1WW/20BXCTO1WW, BIOS JBET63WW (1.27 ) 11/1=
0/2016
> > Call Trace:
> >  dump_stack+0x5c/0x80
> >  warn_alloc.cold+0x78/0xf8
> >  __alloc_pages_nodemask+0x107d/0x10b0
> >  new_slab+0x29a/0xbe0
> >  ___slab_alloc+0x44c/0x5d0
> >  ? xas_nomem+0x49/0x70
> >  ? xas_alloc+0x9b/0xc0
> >  ? kmem_cache_alloc+0x16f/0x210
> >  ? xas_nomem+0x49/0x70
> >  __slab_alloc.isra.0+0x52/0x70
> >  ? xas_nomem+0x49/0x70
> >  kmem_cache_alloc+0x1e3/0x210
> >  xas_nomem+0x49/0x70
> >  add_to_swap_cache+0x264/0x320
> >  __read_swap_cache_async+0x112/0x220
> >  swap_cluster_readahead+0x1e2/0x320
> >  shmem_swapin+0x74/0xc0
> >  shmem_swapin_page+0x51c/0x770
> >  ? find_get_entry+0x101/0x160
> >  shmem_getpage_gfp.isra.0+0x3dd/0x8c0
> >  shmem_read_mapping_page_gfp+0x48/0x80
> >  shmem_get_pages+0x21d/0x5b0 [i915]
> >  __i915_gem_object_get_pages+0x54/0x60 [i915]
> >  __i915_vma_do_pin+0x294/0x450 [i915]
> >  eb_lookup_vmas+0x7ce/0xb10 [i915]
> >  i915_gem_do_execbuffer+0x60f/0x12f0 [i915]
> >  ? __alloc_pages_nodemask+0x1c4/0x10b0
> >  i915_gem_execbuffer2_ioctl+0x1d3/0x3c0 [i915]
> >  ? put_swap_page+0x102/0x2e0
> >  ? i915_gem_execbuffer_ioctl+0x2d0/0x2d0 [i915]
> >  drm_ioctl_kernel+0xb8/0x100 [drm]
> >  drm_ioctl+0x23d/0x3d0 [drm]
> >  ? i915_gem_execbuffer_ioctl+0x2d0/0x2d0 [i915]
> >  do_vfs_ioctl+0x43d/0x6c0
> >  ? syscall_trace_enter+0x1f2/0x2e0
> >  ksys_ioctl+0x5e/0x90
> >  __x64_sys_ioctl+0x16/0x20
> >  do_syscall_64+0x5f/0x1c0
> >  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > RIP: 0033:0x7f500ca5421b
> > Code: 0f 1e fa 48 8b 05 75 8c 0c 00 64 c7 00 26 00 00 00 48 c7 c0 ff ff=
 ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <48> 3d 01 f0 =
ff ff 73 01 c3 48 8b 0d 45 8c 0c 00 f7 d8 64 89 01 48
> > RSP: 002b:00007ffdeab46518 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> > RAX: ffffffffffffffda RBX: 00007ffdeab46560 RCX: 00007f500ca5421b
> > RDX: 00007ffdeab46560 RSI: 0000000040406469 RDI: 000000000000000b
> > RBP: 0000000040406469 R08: 000055ea80aa8cd0 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000246 R12: 000055ea80aab240
> > R13: 000000000000000b R14: ffffffffffffffff R15: 00007f4ffe539730
> > Mem-Info:
> > active_anon:505791 inactive_anon:137312 isolated_anon:53
> >  active_file:7074 inactive_file:8072 isolated_file:32
> >  unevictable:2125 dirty:56 writeback:0 unstable:0
> >  slab_reclaimable:14348 slab_unreclaimable:31867
> >  mapped:5631 shmem:10740 pagetables:5907 bounce:0
> >  free:45505 free_pcp:908 free_cma:0
> > Node 0 active_anon:2023164kB inactive_anon:549248kB active_file:28296kB=
 inactive_file:32288kB unevictable:8500kB isolated(anon):212kB isolated(fil=
e):128kB mapped:22524kB dirty:224kB writeback:0kB shmem:42960kB shmem_thp: =
0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_u=
nreclaimable? no
> > Node 0 DMA free:15456kB min:272kB low:340kB high:408kB active_anon:160k=
B inactive_anon:68kB active_file:0kB inactive_file:16kB unevictable:0kB wri=
tepending:0kB present:15912kB managed:15872kB mlocked:0kB kernel_stack:0kB =
pagetables:20kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > lowmem_reserve[]: 0 3137 3801 3801 3801
> > Node 0 DMA32 free:160740kB min:157952kB low:171840kB high:185728kB acti=
ve_anon:1861456kB inactive_anon:523796kB active_file:27964kB inactive_file:=
32576kB unevictable:8240kB writepending:224kB present:3322892kB managed:323=
4336kB mlocked:48kB kernel_stack:7092kB pagetables:19796kB bounce:0kB free_=
pcp:3176kB local_pcp:120kB free_cma:0kB
> > lowmem_reserve[]: 0 0 663 663 663
> > Node 0 Normal free:5824kB min:38188kB low:41124kB high:44060kB active_a=
non:162152kB inactive_anon:25216kB active_file:68kB inactive_file:276kB une=
victable:260kB writepending:0kB present:753664kB managed:679748kB mlocked:1=
6kB kernel_stack:3692kB pagetables:3812kB bounce:0kB free_pcp:296kB local_p=
cp:0kB free_cma:0kB
> > lowmem_reserve[]: 0 0 0 0 0
> > Node 0 DMA: 17*4kB (UM) 7*8kB (UM) 1*16kB (U) 2*32kB (UM) 3*64kB (UM) 2=
*128kB (UM) 0*256kB 1*512kB (M) 2*1024kB (UM) 0*2048kB 3*4096kB (ME) =3D 15=
500kB
> > Node 0 DMA32: 1155*4kB (UM) 8387*8kB (UM) 2986*16kB (UME) 1229*32kB (ME=
H) 0*64kB 0*128kB 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB =
=3D 160612kB
> > Node 0 Normal: 1439*4kB (UMH) 20*8kB (UMH) 2*16kB (UH) 3*32kB (H) 0*64k=
B 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 6044kB
> > Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=3D0 hugepa=
ges_size=3D1048576kB
> > Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=3D0 hugepa=
ges_size=3D2048kB
> > 122450 total pagecache pages
> > 96549 pages in swap cache
> > Swap cache stats: add 14474738, delete 14376799, find 7531326/8981020
> > Free swap  =3D 13216084kB
> > Total swap =3D 15638612kB
> > 1023117 pages RAM
> > 0 pages HighMem/MovableOnly
> > 40628 pages reserved
> > 0 pages hwpoisoned
> > SLUB: Unable to allocate memory on node -1, gfp=3D0xc0(__GFP_IO|__GFP_F=
S)
> >   cache: radix_tree_node, object size: 576, buffer size: 584, default o=
rder: 2, min order: 0
> >   node 0: slabs: 410, objs: 11144, free: 63
> >
>

