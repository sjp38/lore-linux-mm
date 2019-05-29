Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B544FC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:32:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7340421855
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:32:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U8X6tS1G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7340421855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 018386B0266; Wed, 29 May 2019 13:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0A906B026A; Wed, 29 May 2019 13:32:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1FCB6B026B; Wed, 29 May 2019 13:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0E4C6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 13:32:21 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w3so2410633iot.5
        for <linux-mm@kvack.org>; Wed, 29 May 2019 10:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=IIFsJ6Yevo2NFwTJqan/HqzEkDJSaCO62nPJNhhmr9A=;
        b=eIhryfuRacVu3uZo9eiZSAaQvpT6+MADZ3WA3mDIMudN21fhHIsYLbAeeTQrU/Vfq3
         g/Le5iv33na9yuOP06+LymZii7E5nJM4hRkCtHI7dWWZZ+4T6RxApBfYQUO0kRUOBkh6
         MKJbUg8vCw+MQqV0miUKLnCNABbHDXzt+WiJfu/husOmkV9wLqvtqrkJd/HdNlCymCVd
         9PCaDAQz6wut3xf0msLnJtCq5cggapxq0TSlu9DV9Jj8Xl4g3J/Qz92l9te8fBSdRk7d
         NYLOhW/J+/BgqHaBAp6t7opJzUsg/zt1Z1K9DiTGIct6qpY48q4S2a8cXs0imUUhRjOL
         8/NQ==
X-Gm-Message-State: APjAAAUE93kPWfs7ALRW0lT8XZdJXhbvMjsHIVYB3V6AWn2Xxy/UfED+
	qufRCEKfvKrPp+DtNU5HVICXs2wXKeser4okht2vds7lGZWhPKrePcB+Advd5EKduzMnnUqwHiR
	I20wsXnNdbzBsqbUmiHjbtKpbAlLdnd32/hc+LEIR8eYY4HZoO90PP/ff1AcDq92tBQ==
X-Received: by 2002:a5e:a710:: with SMTP id b16mr5326900iod.38.1559151141518;
        Wed, 29 May 2019 10:32:21 -0700 (PDT)
X-Received: by 2002:a5e:a710:: with SMTP id b16mr5326827iod.38.1559151140512;
        Wed, 29 May 2019 10:32:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559151140; cv=none;
        d=google.com; s=arc-20160816;
        b=0Fu3/g1Q2ncRguORxtQHdJAPpqhSkQlqpCUPfjXYbF7QwEAxYvCRzFkmpAUL+hLGtN
         w/d/lzg5QrIgqg4vvgggrP8eA+tDGKtSaP0i4oAm9YjUwHfMXwnzcduoLgw+fFl9PINq
         GC3mc8UthRKTnWqpPgR3pF71xElEXMCEvoM3JoyVhCFG07VczGrzfDITjvCPmGBc6JG7
         xo33mFkTHOCmFT0HsaRFR+KQXVp83KMrOj7qMtFHs6ZWqm36G+Lk84eyJwUnt7dE6Eig
         w816sR3E52In5a9lhwcX8JMXX8bYt+kT0H9CiTt2IV+8HMiBFVG/HMUyRaZcymbcojeM
         sbiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=IIFsJ6Yevo2NFwTJqan/HqzEkDJSaCO62nPJNhhmr9A=;
        b=z0YKYVPsPzui4Zkync72biEPTVTaSoGUghUxC6y4NHeixAwZ3rF5vrFQ/nhB+elWS1
         k3kyxUTHugH1IFsGLx2unFvtkczi2Ls3XMjQWHFl42KcuJ8cJnU6jBQhn8E/AbPycph+
         CnrW+VqtkOZA9ghBgv8Mm9iq3VUlBOIIuZPNq64owqMebS3Qeb3vAOmyFd/7LgY7GVRM
         K8ZgtO471mDfQWS1LJftt4xxJB+l+yELUHoBGToHqyrIb7o+8UvCNww8jksa65nU7vMf
         E2AT1lz61nn81+UUR1sUnBPlf3YWCSOWI8lAhI3vE6Nyn2ekP5yCR96kzUDuBWCXbk2G
         EF3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U8X6tS1G;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor264751itg.7.2019.05.29.10.32.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 10:32:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U8X6tS1G;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=IIFsJ6Yevo2NFwTJqan/HqzEkDJSaCO62nPJNhhmr9A=;
        b=U8X6tS1GXkPYA3XY5xrCoF84CkY3FD4cR0pilBAs92V0vmkKIotP+XwY3W8d2lWEkk
         TKoMviZGXft25bj01k/0nEfIl6fy0rDAVYHF96XkXfHL6KvQA/4pZB3Zpxu/+xMXdAPF
         T7k5zbB5m0LvPXR2NS5ozndZLC34abaEmVx98/IUVhSOmvsMP2lMu6Ui71mxQgsAGYkU
         ZUP0R0KlYtOE9M3UlKdfqDT8uMeoDSh4YKpss0OYGKZFqMWKISSNpJYTGxreQoLqp+Ih
         IuLqoYijB2jTN1aH+NSXyXWwY/025IaXJq0eAZ1BCkc02jHoqvP8nObdsXvgnxilo5Py
         soFg==
X-Google-Smtp-Source: APXvYqwozQsvPy233eaKB0wYMTv0I8IFk7vNlWpAnM6+345ysanReut81mkMkMdmrmv1VLALOpXHvz2znCNLxP2xwbY=
X-Received: by 2002:a24:5094:: with SMTP id m142mr8551838itb.96.1559151139165;
 Wed, 29 May 2019 10:32:19 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
In-Reply-To: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 29 May 2019 22:32:08 +0500
Message-ID: <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 at 09:05, Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
>
> Hi folks.
> I am observed kernel panic after update to git tag 5.2-rc2.
> This crash happens at memory pressing when swap being used.
>
> Unfortunately in journalctl saved only this:
>

Now I captured better trace.

: page:ffffd6d34dff0000 refcount:1 mapcount:1 mapping:ffff97812323a689
index:0xfecec363
: anon
: flags: 0x17fffe00080034(uptodate|lru|active|swapbacked)
: raw: 0017fffe00080034 ffffd6d34c67c508 ffffd6d3504b8d48 ffff97812323a689
: raw: 00000000fecec363 0000000000000000 0000000100000000 ffff978433ace000
: page dumped because: VM_BUG_ON_PAGE(entry != page)
: page->mem_cgroup:ffff978433ace000
: ------------[ cut here ]------------
: kernel BUG at mm/swap_state.c:170!
: invalid opcode: 0000 [#1] SMP NOPTI
: CPU: 1 PID: 221 Comm: kswapd0 Not tainted 5.2.0-0.rc2.git0.1.fc31.x86_64 #1
: Hardware name: System manufacturer System Product Name/ROG STRIX
X470-I GAMING, BIOS 2202 04/11/2019
: RIP: 0010:__delete_from_swap_cache+0x20d/0x240
: Code: 30 65 48 33 04 25 28 00 00 00 75 4a 48 83 c4 38 5b 5d 41 5c 41
5d 41 5e 41 5f c3 48 c7 c6 2f dc 0f 8a 48 89 c7 e8 93 1b fd ff <0f> 0b
48 c7 c6 a8 74 0f 8a e8 85 1b fd ff 0f 0b 48 c7 c6 a8 7d 0f
: RSP: 0018:ffffa982036e7980 EFLAGS: 00010046
: RAX: 0000000000000021 RBX: 0000000000000040 RCX: 0000000000000006
: RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff97843d657900
: RBP: 0000000000000001 R08: ffffa982036e7835 R09: 0000000000000535
: R10: ffff97845e21a46c R11: ffffa982036e7835 R12: ffff978426387120
: R13: 0000000000000000 R14: ffffd6d34dff0040 R15: ffffd6d34dff0000
: FS:  0000000000000000(0000) GS:ffff97843d640000(0000) knlGS:0000000000000000
: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
: CR2: 00002cba88ef5000 CR3: 000000078a97c000 CR4: 00000000003406e0
: Call Trace:
:  delete_from_swap_cache+0x46/0xa0
:  try_to_free_swap+0xbc/0x110
:  swap_writepage+0x13/0x70
:  pageout.isra.0+0x13c/0x350
:  shrink_page_list+0xc14/0xdf0
:  shrink_inactive_list+0x1e5/0x3c0
:  shrink_node_memcg+0x202/0x760
:  ? do_shrink_slab+0x52/0x2c0
:  shrink_node+0xe0/0x470
:  balance_pgdat+0x2d1/0x510
:  kswapd+0x220/0x420
:  ? finish_wait+0x80/0x80
:  kthread+0xfb/0x130
:  ? balance_pgdat+0x510/0x510
:  ? kthread_park+0x90/0x90
:  ret_from_fork+0x22/0x40
: Modules linked in: uinput rfcomm fuse xt_CHECKSUM xt_MASQUERADE tun
bridge stp llc nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT
ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4
xt_conntrack ebtable_nat ip6table_nat ip6table_mangle ip6table_raw
ip6table_security iptable_nat nf_nat iptable_mangle iptable_raw
iptable_security cmac nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4
libcrc32c ip_set nfnetlink ebtable_filter ebtables ip6table_filter
ip6_tables iptable_filter ip_tables bnep sunrpc vfat fat edac_mce_amd
arc4 kvm_amd rtwpci snd_hda_codec_realtek rtw88 kvm eeepc_wmi
snd_hda_codec_generic asus_wmi sparse_keymap ledtrig_audio
snd_hda_codec_hdmi video wmi_bmof mac80211 snd_hda_intel uvcvideo
snd_hda_codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2
irqbypass snd_usb_audio videobuf2_common snd_hda_core videodev
snd_usbmidi_lib snd_seq snd_hwdep snd_rawmidi snd_seq_device btusb
snd_pcm crct10dif_pclmul btrtl crc32_pclmul btbcm btintel bluetooth
:  cfg80211 snd_timer ghash_clmulni_intel joydev snd k10temp soundcore
media sp5100_tco ccp i2c_piix4 ecdh_generic rfkill ecc gpio_amdpt
pcc_cpufreq gpio_generic acpi_cpufreq binfmt_misc hid_logitech_hidpp
hid_logitech_dj uas usb_storage hid_sony ff_memless amdgpu
amd_iommu_v2 gpu_sched ttm drm_kms_helper igb nvme dca drm
crc32c_intel i2c_algo_bit nvme_core wmi pinctrl_amd
: ---[ end trace 3840e49b1d8d2c24 ]---


$ /usr/src/kernels/`uname -r`/scripts/faddr2line
/lib/debug/lib/modules/`uname -r`/vmlinux
__delete_from_swap_cache+0x20d
__delete_from_swap_cache+0x20d/0x240:
__delete_from_swap_cache at mm/swap_state.c:170 (discriminator 1)




--
Best Regards,
Mike Gavrilov.

