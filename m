Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0FB8C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:23:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77AA6206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:23:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77AA6206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEB5E6B0003; Fri,  2 Aug 2019 16:23:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9D646B0005; Fri,  2 Aug 2019 16:23:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C640D6B0006; Fri,  2 Aug 2019 16:23:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAE76B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:23:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so41231469pgv.0
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:23:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xys9TyxEqEMujzeooIIYd3Bw4lde42i+TGmQE2EgBJg=;
        b=FPuFvBS1QiJLYtv87J8tR5mksswid2igp7p4YJefnFNAj1LXNBssl/hkW1NCAWdKwV
         0efvl+TTvEutqAT/lXt4EDKleJb3lYpeCFDw0RR+EVcx2Ev11BaqLGIqhdw1EMwlzxrs
         EoHBpmy5pMO8fbCsaxoc4k9YN/8dSq5fydb6GG1bHzaQgm6LLrWBJrngBQUOrp62QTPe
         F/u/IsRnRi7Hn8TS5l6dhzSmCL/c5g15NZLgrV2P2KkoU2e/A4PEimi4bAqHIK1zggyC
         OZ6bCxUhUpg/DGbUBcqPzUR8j7Vk9S5rB14KTqAa0BdopT3mpUAojXswy5jahVhv3rVT
         JHhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAX5ZBF8bfsEB6XhUChG7jsxBG/KPQM2pneAdJ5cW4aVKbKwoA3A
	Tw7Nevy2gEetO87EIQEAi3nlk6zmvIGM2SH9lelz5Nje9w7zxxm3PI9h13DtcXXHzRWIWTSXdS/
	GSQnu3Ndz0oAe3TaaIZYSeaOxe72EBuXVVyVoUM8ayr2J9LvTKeAq18SovJWuoiM4UQ==
X-Received: by 2002:a63:f401:: with SMTP id g1mr129695836pgi.314.1564777395141;
        Fri, 02 Aug 2019 13:23:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMxa4qCILrQ0z62pq7JoymlFn9+IMAMjdkWJcuzCh1iDS3DwhClhrKrBx4bab6MNrw7vf7
X-Received: by 2002:a63:f401:: with SMTP id g1mr129695786pgi.314.1564777393965;
        Fri, 02 Aug 2019 13:23:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564777393; cv=none;
        d=google.com; s=arc-20160816;
        b=GOZ0gDDTpUXPCbUk/I79yMRSrF/7Rfpfom/hWCAU5VCMqLggIK2cw0t0iOZJzrHrY/
         iRmc405xD94VID9y6lpfmqoaBRUhv8D2agqSFBXhm5DbLYlliWTe7xkR0aXRSwtZBqf9
         k8cBP1K5/K8UKlKtWFKkL7vmX40XZ7Hl7Qr3GFn6E84wAx7CgS1gN66jY1xYrjEOPMUA
         Bv24YI3ToOBb8QhXOjyIhW4KlMJgiohO10u1WGjnFtd3fs+i7mnMr6Y1P5k8qCyEPWZ1
         B+Xaj8FlKxfVtzMpG4370iAei1nu82E0itYlI5Fi7C4/kyy5BAO2GesxoZu3uQn2TyBS
         pF2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=xys9TyxEqEMujzeooIIYd3Bw4lde42i+TGmQE2EgBJg=;
        b=xVUg7KsKDCEbQ0g2xGiu0c6B6ul/fgYI4CJiMHpkFqKvkkRagyevgtxM1WmRmVDdb+
         tVUNOIEXw8qfArcbbUyhoBOq3X8KdYCGiUCg030uNqY+Wn6miG9D/56Y3ddxIVz79qkE
         8yMVBSNEHUjQ0v3zOW9ZvoxSPO6sh2g9klNj4dEm4DbQ3fgTDEsNwHLYxvHme7diHFR0
         gLJDxdfb73qTDgXPaLv1wlw1YPjweXwUuU6lZdVSYBQEjAHgnL7H//K5hj3BxJIHLaSq
         DGUElSG144x2tnIGN/quFJrl8aUm+RtDuILVioKH8odRfi+pfkvidrX5ZtDGWwycA0wR
         9rDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u71si40358964pgd.279.2019.08.02.13.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 13:23:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id DF84613A2;
	Fri,  2 Aug 2019 20:23:08 +0000 (UTC)
Date: Fri, 2 Aug 2019 13:23:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: petr@vandrovec.name
Cc: bugzilla-daemon@bugzilla.kernel.org, Christian Koenig
 <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>, David Airlie
 <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
Message-Id: <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
In-Reply-To: <bug-204407-27@https.bugzilla.kernel.org/>
References: <bug-204407-27@https.bugzilla.kernel.org/>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 01 Aug 2019 22:34:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=204407
> 
>             Bug ID: 204407
>            Summary: Bad page state in process Xorg
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 5.3.0-rc2-00013
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: petr@vandrovec.name
>         Regression: No
> 
> Created attachment 284081
>   --> https://bugzilla.kernel.org/attachment.cgi?id=284081&action=edit
> dmesg
> 
> I've upgraded from 5.3-rc1 to 5.3-rc2, and when I started X server, system
> became unhappy:
> 
> [259701.387365] BUG: Bad page state in process Xorg  pfn:2a300
> [259701.393593] page:ffffea0000a8c000 refcount:0 mapcount:-128
> mapping:0000000000000000 index:0x0
> [259701.402832] flags: 0x2000000000000000()
> [259701.407426] raw: 2000000000000000 ffffffff822ab778 ffffea0000a8f208
> 0000000000000000
> [259701.415900] raw: 0000000000000000 0000000000000003 00000000ffffff7f
> 0000000000000000
> [259701.424373] page dumped because: nonzero mapcount
> [259701.429847] Modules linked in: af_packet xt_REDIRECT nft_compat x_tables
> nft_counter nft_chain_nat nf_nat nf_conntrack nf_defrag_ipv4 nf_tables
> nfnetlink ppdev parport fuse autofs4 binfmt_misc uinput twofish_generic
> twofish_avx_x86_64 twofish_x86_64_3way twofish_x86_64 twofish_common
> camellia_generic camellia_aesni_avx_x86_64 camellia_x86_64 serpent_avx_x86_64
> serpent_sse2_x86_64 serpent_generic blowfish_generic blowfish_x86_64
> blowfish_common cast5_avx_x86_64 cast5_generic cast_common des_generic cmac
> xcbc rmd160 af_key xfrm_algo rpcsec_gss_krb5 nfsv4 nls_iso8859_2 cifs libarc4
> nfsv3 nfsd auth_rpcgss nfs_acl nfs lockd grace fscache sunrpc ipv6 crc_ccitt
> nf_defrag_ipv6 snd_hda_codec_hdmi pktcdvd coretemp hwmon intel_rapl_common
> iosf_mbi x86_pkg_temp_thermal snd_hda_codec_realtek snd_hda_codec_generic
> ledtrig_audio snd_hda_intel snd_hda_codec crct10dif_pclmul crc32_pclmul
> snd_hwdep crc32c_intel snd_hda_core ghash_clmulni_intel snd_pcm_oss uas
> iTCO_wdt aesni_intel e1000e
> [259701.429873]  snd_mixer_oss iTCO_vendor_support aes_x86_64 snd_pcm
> crypto_simd ptp mei_me dcdbas lpc_ich sr_mod cryptd usb_storage snd_timer
> glue_helper mfd_core input_leds pps_core tpm_tis cdrom i2c_i801 snd mei
> tpm_tis_core sg tpm [last unloaded: parport_pc]
> [259701.539387] CPU: 10 PID: 4860 Comm: Xorg Tainted: G                T
> 5.3.0-rc2-64-00013-g03f05a670a3d #69
> [259701.549382] Hardware name: Dell Inc. Precision T3610/09M8Y8, BIOS A16
> 02/05/2018
> [259701.549382] Call Trace:
> [259701.549382]  dump_stack+0x46/0x60
> [259701.549382]  bad_page.cold.28+0x81/0xb4
> [259701.549382]  __free_pages_ok+0x236/0x240
> [259701.549382]  __ttm_dma_free_page+0x2f/0x40
> [259701.549382]  ttm_dma_unpopulate+0x29b/0x370
> [259701.549382]  ttm_tt_destroy.part.6+0x44/0x50
> [259701.549382]  ttm_bo_cleanup_memtype_use+0x29/0x70
> [259701.549382]  ttm_bo_put+0x225/0x280
> [259701.549382]  ttm_bo_vm_close+0x10/0x20
> [259701.549382]  remove_vma+0x20/0x40
> [259701.549382]  __do_munmap+0x2da/0x420
> [259701.549382]  __vm_munmap+0x66/0xc0
> [259701.549382]  __x64_sys_munmap+0x22/0x30
> [259701.549382]  do_syscall_64+0x5e/0x1a0
> [259701.549382]  ? prepare_exit_to_usermode+0x75/0xa0
> [259701.549382]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [259701.549382] RIP: 0033:0x7f504d0ec1d7
> [259701.549382] Code: 10 e9 67 ff ff ff 0f 1f 44 00 00 48 8b 15 b1 6c 0c 00 f7
> d8 64 89 02 48 c7 c0 ff ff ff ff e9 6b ff ff ff b8 0b 00 00 00 0f 05 <48> 3d 01
> f0 ff ff 73 01 c3 48 8b 0d 89 6c 0c 00 f7 d8 64 89 01 48
> [259701.549382] RSP: 002b:00007ffe529db138 EFLAGS: 00000206 ORIG_RAX:
> 000000000000000b
> [259701.549382] RAX: ffffffffffffffda RBX: 0000564a5eabce70 RCX:
> 00007f504d0ec1d7
> [259701.549382] RDX: 00007ffe529db140 RSI: 0000000000400000 RDI:
> 00007f5044b65000
> [259701.549382] RBP: 0000564a5eafe460 R08: 000000000000000b R09:
> 000000010283e000
> [259701.549382] R10: 0000000000000001 R11: 0000000000000206 R12:
> 0000564a5e475b08
> [259701.549382] R13: 0000564a5e475c80 R14: 00007ffe529db190 R15:
> 0000000000000c80
> [259701.707238] Disabling lock debugging due to kernel taint

I assume the above is misbehaviour in the DRM code?

> 
> Also - maybe related, maybe not - I've got three userspace crashes earlier on
> this kernel (but never before):
> 
> [77154.886836] iscons.py[12441]: segfault at 2c ip 00000000080cf0b5 sp
> 00000000f773fb60 error 4 in python[8048000+11a000]
> [77154.898376] Code: 02 0f 84 4a 2e 00 00 8b 4d 08 8b bd 04 ff ff ff 8b 59 38
> 8b 57 20 8b 7b 10 85 ff 0f 84 ee 22 00 00 8b 8d 04 ff ff ff 8b 59 08 <8b> 43 2c
> 85 c0 0f 84 3c e3 ff ff 8b 51 34 8b 71 38 8b 79 3c ff 00
> [119529.983163] in.telnetd[616]: segfault at 0 ip 0000555fdfa09a05 sp
> 00007ffd8fc05380 error 4 in in.telnetd[555fdfa06000+b000]
> [119529.995783] Code: 8d 3d c2 76 00 00 e8 9a 2b 00 00 e9 25 fe ff ff be f2 00
> 00 00 48 8d 3d ac 76 00 00 e8 84 2b 00 00 eb 96 48 8b 05 63 ee 00 00 <0f> b6 00
> e9 fa fe ff ff 44 89 ee 48 8d 3d 8c 76 00 00 e8 64 2b 00
> [120884.183003] iscons.py[10779]: segfault at 2c ip 00000000080d0dc2 sp
> 00000000f7702b60 error 4 in python[8048000+11a000]
> [120884.195182] Code: 4c 24 08 89 44 24 04 89 3c 24 e8 d9 0b 01 00 8b 55 f0 8b
> 7d e8 8b 4d ec 8b 85 04 ff ff ff 89 55 84 89 7d 8c 89 4d 88 8b 50 08 <8b> 7a 2c
> 85 ff 0f 84 3c 10 00 00 8b bd 04 ff ff ff 89 f8 8b 57 34
> 
> I've investigated in.telnetd in detail as I was worried if there is some 0-day
> being used on my system - and as far as I could tell, problem is that part of
> the .bss turned to zeroes after process did fork/exec - there was NULL in the
> variable that cannot have NULL as variable is set to non-NULL value during
> in.telnetd initialization.
> 
> iscons crashes are from NULL pointer dereference too, and iscons does lot of
> fork/exec as well.

hm, that does sound unrelated.

