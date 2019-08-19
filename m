Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28DAAC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B776C214DA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:42:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K22enUUI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B776C214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5093B6B0007; Mon, 19 Aug 2019 15:42:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 492FC6B0008; Mon, 19 Aug 2019 15:42:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A196B000A; Mon, 19 Aug 2019 15:42:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 02EBE6B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:42:23 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A5014181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:42:23 +0000 (UTC)
X-FDA: 75840198966.21.crush16_6c18a0950915e
X-HE-Tag: crush16_6c18a0950915e
X-Filterd-Recvd-Size: 21744
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com [209.85.167.49])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:42:22 +0000 (UTC)
Received: by mail-lf1-f49.google.com with SMTP id j17so2267357lfp.3
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:42:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=t6xXfDBe3jpLzDYMBnh5me3YYl+ZLtlNKFZKNfTnM/Y=;
        b=K22enUUIVyQD/LiQv8ozetJXWaYI7i2WsMTtzomieuQEo1hdoepn/7dt1FXUg9dmK3
         TKafy8Wae1Zn9WjzGz4zdmka3AQKGU/Zc2DuQ7BdM/P6Bff8YVi3/b+QTBfBsWckCfY+
         UuMgREy6ETbNE/l4cFRzcAAHpv7HF53FTBvMAU46GLAH7kiV+yWI19CwsGpip0whHBPm
         GvkFPZmbiOeF0AYdUkMUDjTdP9wRTfvpCyqliL/bi7nnQEr4k2h5OI5GzxJmjEjLIugY
         lHFC9C3lI3lX5ianmLbjMKhJgkpnJEymLRKaojRbh8aW/6mJ2vJFiRBR57D6EhchD0dc
         rd1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=t6xXfDBe3jpLzDYMBnh5me3YYl+ZLtlNKFZKNfTnM/Y=;
        b=P065CRgOmWhVr/8sASJ0gdbCFK80CFaM9ne8/c+yKHOr63tA4ILbpIsIUvjwI2rSi4
         A+FS3fUdRUFbu0s8QHLhY+8+wuAupo3hLdraaTY2H/CYQRPPxMa5Rp0tHq60Cb+og4HY
         iGS9P+QPg/K1NgnAms6GFhTG22TmjY/K8WmlNWLDW/1r0/Hqp7McC605HPWuoZlWmFaB
         kCZXQSFji/ZLLLV9L2t5+WUBZQmKtRHqC+hLb39/uZpXBlYHvWmUhPf21ngw497Y6Bdi
         5wdZy1QpNqnP/7Zs/OnG8DXguRUSVXY6miIrSgIvHAkglRmFMYZNRtkgoeU66rPmVeY/
         JiTA==
X-Gm-Message-State: APjAAAXBEL7ugo8hTKfiN+L+yQDOS406pY9qkYRAYp8UltGGOygPV9OU
	+WLco59CR0KT2Ca7iBiNvj9VQ5GhmvOlicxCyiE=
X-Google-Smtp-Source: APXvYqx1hyqUUROcF3+ctPY/1q7U6ohA+U3RXQsKQeYlGRpUplGi2Tc2r+z5hEzGphB/39Urz6O/PsDDxWW3Z2h2aYw=
X-Received: by 2002:ac2:42cc:: with SMTP id n12mr13146574lfl.47.1566243741101;
 Mon, 19 Aug 2019 12:42:21 -0700 (PDT)
MIME-Version: 1.0
References: <CAH6yVy3s6Z6EH+7QRcN740pZe6CP-kkC83VwYd4RvbRm6LF4OQ@mail.gmail.com>
 <20190819073456.GC3111@dhcp22.suse.cz> <CAMJBoFPGT0_GqZLuOxLWPtrYkwM2WLvZ9=8F7phnGEoGYSEW8Q@mail.gmail.com>
 <CAMJBoFN-TPggasbaEnpubXt+77XHQt+AGmu9A9JX2c=h7Tog0Q@mail.gmail.com>
 <CAH6yVy0S_=2tOcx2+LMT7DOe8xg+4KaVnzQiSGwLfGPsxD1g1Q@mail.gmail.com>
 <CAMJBoFPAOSd3w9YECBqT3nudBozEsMi7ODNE+3nCvKEjT-nhnQ@mail.gmail.com> <CAH6yVy3N0Khp8sdwU-h=jgX_ynoWfCVRzk3uJiYJGAYXBnHJTQ@mail.gmail.com>
In-Reply-To: <CAH6yVy3N0Khp8sdwU-h=jgX_ynoWfCVRzk3uJiYJGAYXBnHJTQ@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 19 Aug 2019 21:44:11 +0200
Message-ID: <CAMJBoFPrOMuff34d=Dh0XXQt+aUqwLeai6+POB-OVGz68UpURw@mail.gmail.com>
Subject: Re: PROBLEM: zswap with z3fold makes swap stuck
To: Markus Linnala <markus.linnala@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Content-Type: multipart/alternative; boundary="000000000000d1f39805907d89e7"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000d1f39805907d89e7
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 19, 2019, 7:49 PM Markus Linnala <markus.linnala@gmail.com>
wrote:

> I have applied your patch against vanilla v5.3-rc5. There was no config
> changes.
>
> So far I've gotten couple of these GPF. I guess this is different
> issue. It will take several hours to get full view.
>
Thanks. This looks different, I will update you tomorrow on this one.

~Vitaly

>
> I've attached one full console log as: console-1566235171.001993084.log
>
> [   13.821223] general protection fault: 0000 [#1] SMP PTI
> [   13.821882] CPU: 0 PID: 151 Comm: kswapd0 Tainted: G        W
>   5.3.0-rc5+ #71
> [   13.822755] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009),
> BIOS 1.12.0-2.fc30 04/01/2014
> [   13.824272] RIP: 0010:handle_to_buddy+0x20/0x30
> [   13.824786] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 53
> 48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00
> f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 00
> 00 55
> [   13.826854] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206
> [   13.827452] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX:
> 0000000000000000
> [   13.828256] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI:
> ffff97ddbe5d89c8
> [   13.829056] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09:
> 0000000000000000
> [   13.829860] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff97dd890fd001
> [   13.830660] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15:
> ffffb18cc0197838
> [   13.831468] FS:  0000000000000000(0000) GS:ffff97ddbe400000(0000)
> knlGS:0000000000000000
> [   13.832673] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   13.833593] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4:
> 0000000000160ef0
> [   13.834508] Call Trace:
> [   13.834828]  z3fold_zpool_map+0x76/0x110
> [   13.835332]  zswap_writeback_entry+0x50/0x410
> [   13.835888]  z3fold_zpool_shrink+0x3d1/0x570
> [   13.836434]  ? sched_clock_cpu+0xc/0xc0
> [   13.836919]  zswap_frontswap_store+0x424/0x7c1
> [   13.837484]  __frontswap_store+0xc4/0x162
> [   13.837992]  swap_writepage+0x39/0x70
> [   13.838460]  pageout.isra.0+0x12c/0x5d0
> [   13.838950]  shrink_page_list+0x1124/0x1830
> [   13.839484]  shrink_inactive_list+0x1da/0x460
> [   13.840036]  shrink_node_memcg+0x202/0x770
> [   13.840746]  shrink_node+0xdf/0x490
> [   13.841931]  balance_pgdat+0x2db/0x580
> [   13.842396]  kswapd+0x239/0x500
> [   13.842772]  ? finish_wait+0x90/0x90
> [   13.847323]  kthread+0x108/0x140
> [   13.848358]  ? balance_pgdat+0x580/0x580
> [   13.849626]  ? kthread_park+0x80/0x80
> [   13.850352]  ret_from_fork+0x3a/0x50
> [   13.851086] Modules linked in: ip6t_rpfilter ip6t_REJECT
> nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat
> ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat
> iptable_mangle iptable_raw iptable_security nf_conntrack
> nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink
> ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul
> crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon
> net_failover failover intel_agp intel_gtt qxl drm_kms_helper
> syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel
> virtio_blk virtio_console serio_raw agpgart qemu_fw_cfg
> [   13.857818] ---[ end trace 4517028df5e476fe ]---
> [   13.858400] RIP: 0010:handle_to_buddy+0x20/0x30
> [   13.859761] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 53
> 48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00
> f0 ff ff <0f> b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 00
> 00 55
> [   13.862703] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206
> [   13.864232] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX:
> 0000000000000000
> [   13.865834] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI:
> ffff97ddbe5d89c8
> [   13.867362] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09:
> 0000000000000000
> [   13.869121] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff97dd890fd001
> [   13.871091] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15:
> ffffb18cc0197838
> [   13.872742] FS:  0000000000000000(0000) GS:ffff97ddbe400000(0000)
> knlGS:0000000000000000
> [   13.874448] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   13.876382] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4:
> 0000000000160ef0
> [   13.878007] ------------[ cut here ]------------
>
>
> (gdb) l *handle_to_buddy+0x20
> 0xffffffff813376b0 is in handle_to_buddy (/src/linux/mm/z3fold.c:429).
> 424 unsigned long addr;
> 425
> 426 WARN_ON(handle & (1 << PAGE_HEADLESS));
> 427 addr = *(unsigned long *)handle;
> 428 zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
> 429 return (addr - zhdr->first_num) & BUDDY_MASK;
> 430 }
> 431
> 432 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header
> *zhdr)
> 433 {
> (gdb) l *z3fold_zpool_map+0x76
> 0xffffffff81337cb6 is in z3fold_zpool_map (/src/linux/mm/z3fold.c:1257).
> 1252 if (test_bit(PAGE_HEADLESS, &page->private))
> 1253 goto out;
> 1254
> 1255 z3fold_page_lock(zhdr);
> 1256 buddy = handle_to_buddy(handle);
> 1257 switch (buddy) {
> 1258 case FIRST:
> 1259 addr += ZHDR_SIZE_ALIGNED;
> 1260 break;
> 1261 case MIDDLE:
> (gdb) l *zswap_writeback_entry+0x50
> 0xffffffff812e8260 is in zswap_writeback_entry (/src/linux/mm/zswap.c:858).
> 853 .sync_mode = WB_SYNC_NONE,
> 854 };
> 855
> 856 /* extract swpentry from data */
> 857 zhdr = zpool_map_handle(pool, handle, ZPOOL_MM_RO);
> 858 swpentry = zhdr->swpentry; /* here */
> 859 zpool_unmap_handle(pool, handle);
> 860 tree = zswap_trees[swp_type(swpentry)];
> 861 offset = swp_offset(swpentry);
> (gdb) l *z3fold_zpool_shrink+0x3d1
> 0xffffffff81338821 is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:1186).
> 1181 ret = pool->ops->evict(pool, middle_handle);
> 1182 if (ret)
> 1183 goto next;
> 1184 }
> 1185 if (first_handle) {
> 1186 ret = pool->ops->evict(pool, first_handle);
> 1187 if (ret)
> 1188 goto next;
> 1189 }
> 1190 if (last_handle) {
>
>
> To compare, I got following Call Trace "signatures" against vanilla
> v5.3-rc5. Some of them might not be related to zswap at all.
>
> [   15.469831] Call Trace:
> [   15.470171]  migrate_pages+0x20c/0xfb0
> [   15.470678]  ? isolate_freepages_block+0x410/0x410
> [   15.471344]  ? __ClearPageMovable+0x90/0x90
> [   15.471914]  compact_zone+0x74c/0xef0
> --
> [  105.611480] Call Trace:
> [  105.611817]  zswap_writeback_entry+0x50/0x410
> [  105.612417]  z3fold_zpool_shrink+0x29d/0x540
> [  105.612947]  zswap_frontswap_store+0x424/0x7c1
> [  105.613494]  __frontswap_store+0xc4/0x162
> --
> [   15.103942] Call Trace:
> [   15.104280]  z3fold_zpool_map+0x76/0x110
> [   15.104824]  zswap_writeback_entry+0x50/0x410
> [   15.105398]  z3fold_zpool_shrink+0x3c4/0x540
> [   15.105960]  zswap_frontswap_store+0x424/0x7c1
> --
> [  632.066122] Call Trace:
> [  632.066124]  z3fold_zpool_map+0x76/0x110
> [  632.066128]  zswap_writeback_entry+0x50/0x410
> [  632.069101]  do_user_addr_fault+0x1fe/0x480
> [  632.069650]  z3fold_zpool_shrink+0x3c4/0x540
> --
> [  133.419601] Call Trace:
> [  133.420199]  zswap_writeback_entry+0x50/0x410
> [  133.421244]  z3fold_zpool_shrink+0x4a6/0x540
> [  133.422266]  zswap_frontswap_store+0x424/0x7c1
> [  133.423386]  __frontswap_store+0xc4/0x162
> --
> [  155.374773] Call Trace:
> [  155.375122]  get_page_from_freelist+0x57d/0x1a40
> [  155.375725]  __alloc_pages_nodemask+0x19d/0x400
> [  155.376354]  alloc_pages_vma+0xcc/0x170
> [  155.376854]  __read_swap_cache_async+0x1e9/0x3e0
> --
> [   23.849834] Call Trace:
> [   23.851038]  get_page_from_freelist+0x57d/0x1a40
> [   23.853300]  ? wake_all_kswapds+0x54/0xb0
> [   23.855280]  __alloc_pages_slowpath+0x1ae/0x1000
> [   23.857512]  ? __lock_acquire+0x247/0x1900
> --
> [  197.206331] Call Trace:
> [  197.207923]  __release_z3fold_page.constprop.0+0x7e/0x130
> [  197.211387]  do_compact_page+0x2c9/0x430
> [  197.213830]  process_one_work+0x272/0x5a0
> [  197.216392]  worker_thread+0x50/0x3b0
>

--000000000000d1f39805907d89e7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" =
class=3D"gmail_attr">On Mon, Aug 19, 2019, 7:49 PM Markus Linnala &lt;<a hr=
ef=3D"mailto:markus.linnala@gmail.com">markus.linnala@gmail.com</a>&gt; wro=
te:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex">I have applied your patch again=
st vanilla v5.3-rc5. There was no config changes.<br>
<br>
So far I&#39;ve gotten couple of these GPF. I guess this is different<br>
issue. It will take several hours to get full view.<br></blockquote></div><=
/div><div dir=3D"auto">Thanks. This looks different, I will update you=C2=
=A0tomorrow on this one.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D=
"auto">~Vitaly</div><div dir=3D"auto"><div class=3D"gmail_quote"><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">
<br>
I&#39;ve attached one full console log as: console-1566235171.001993084.log=
<br>
<br>
[=C2=A0 =C2=A013.821223] general protection fault: 0000 [#1] SMP PTI<br>
[=C2=A0 =C2=A013.821882] CPU: 0 PID: 151 Comm: kswapd0 Tainted: G=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 W<br>
=C2=A0 5.3.0-rc5+ #71<br>
[=C2=A0 =C2=A013.822755] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009)=
,<br>
BIOS 1.12.0-2.fc30 04/01/2014<br>
[=C2=A0 =C2=A013.824272] RIP: 0010:handle_to_buddy+0x20/0x30<br>
[=C2=A0 =C2=A013.824786] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00=
 53<br>
48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00<br>
f0 ff ff &lt;0f&gt; b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 0=
0<br>
00 55<br>
[=C2=A0 =C2=A013.826854] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206<br>
[=C2=A0 =C2=A013.827452] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX: 0=
000000000000000<br>
[=C2=A0 =C2=A013.828256] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI: f=
fff97ddbe5d89c8<br>
[=C2=A0 =C2=A013.829056] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09: 0=
000000000000000<br>
[=C2=A0 =C2=A013.829860] R10: 0000000000000000 R11: 0000000000000000 R12: f=
fff97dd890fd001<br>
[=C2=A0 =C2=A013.830660] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15: f=
fffb18cc0197838<br>
[=C2=A0 =C2=A013.831468] FS:=C2=A0 0000000000000000(0000) GS:ffff97ddbe4000=
00(0000)<br>
knlGS:0000000000000000<br>
[=C2=A0 =C2=A013.832673] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 000000008005=
0033<br>
[=C2=A0 =C2=A013.833593] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4: 0=
000000000160ef0<br>
[=C2=A0 =C2=A013.834508] Call Trace:<br>
[=C2=A0 =C2=A013.834828]=C2=A0 z3fold_zpool_map+0x76/0x110<br>
[=C2=A0 =C2=A013.835332]=C2=A0 zswap_writeback_entry+0x50/0x410<br>
[=C2=A0 =C2=A013.835888]=C2=A0 z3fold_zpool_shrink+0x3d1/0x570<br>
[=C2=A0 =C2=A013.836434]=C2=A0 ? sched_clock_cpu+0xc/0xc0<br>
[=C2=A0 =C2=A013.836919]=C2=A0 zswap_frontswap_store+0x424/0x7c1<br>
[=C2=A0 =C2=A013.837484]=C2=A0 __frontswap_store+0xc4/0x162<br>
[=C2=A0 =C2=A013.837992]=C2=A0 swap_writepage+0x39/0x70<br>
[=C2=A0 =C2=A013.838460]=C2=A0 pageout.isra.0+0x12c/0x5d0<br>
[=C2=A0 =C2=A013.838950]=C2=A0 shrink_page_list+0x1124/0x1830<br>
[=C2=A0 =C2=A013.839484]=C2=A0 shrink_inactive_list+0x1da/0x460<br>
[=C2=A0 =C2=A013.840036]=C2=A0 shrink_node_memcg+0x202/0x770<br>
[=C2=A0 =C2=A013.840746]=C2=A0 shrink_node+0xdf/0x490<br>
[=C2=A0 =C2=A013.841931]=C2=A0 balance_pgdat+0x2db/0x580<br>
[=C2=A0 =C2=A013.842396]=C2=A0 kswapd+0x239/0x500<br>
[=C2=A0 =C2=A013.842772]=C2=A0 ? finish_wait+0x90/0x90<br>
[=C2=A0 =C2=A013.847323]=C2=A0 kthread+0x108/0x140<br>
[=C2=A0 =C2=A013.848358]=C2=A0 ? balance_pgdat+0x580/0x580<br>
[=C2=A0 =C2=A013.849626]=C2=A0 ? kthread_park+0x80/0x80<br>
[=C2=A0 =C2=A013.850352]=C2=A0 ret_from_fork+0x3a/0x50<br>
[=C2=A0 =C2=A013.851086] Modules linked in: ip6t_rpfilter ip6t_REJECT<br>
nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat<br>
ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat<br>
iptable_mangle iptable_raw iptable_security nf_conntrack<br>
nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c ip_set nfnetlink<br>
ip6table_filter ip6_tables iptable_filter ip_tables crct10dif_pclmul<br>
crc32_pclmul ghash_clmulni_intel virtio_net virtio_balloon<br>
net_failover failover intel_agp intel_gtt qxl drm_kms_helper<br>
syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel<br>
virtio_blk virtio_console serio_raw agpgart qemu_fw_cfg<br>
[=C2=A0 =C2=A013.857818] ---[ end trace 4517028df5e476fe ]---<br>
[=C2=A0 =C2=A013.858400] RIP: 0010:handle_to_buddy+0x20/0x30<br>
[=C2=A0 =C2=A013.859761] Code: 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00=
 53<br>
48 89 fb 83 e7 01 0f 85 31 26 00 00 48 8b 03 5b 48 89 c2 48 81 e2 00<br>
f0 ff ff &lt;0f&gt; b6 92 ca 00 00 00 29 d0 83 e0 03 c3 0f 1f 00 0f 1f 44 0=
0<br>
00 55<br>
[=C2=A0 =C2=A013.862703] RSP: 0000:ffffb18cc01977f0 EFLAGS: 00010206<br>
[=C2=A0 =C2=A013.864232] RAX: 00ffff97dd890fd0 RBX: fffff63080243f40 RCX: 0=
000000000000000<br>
[=C2=A0 =C2=A013.865834] RDX: 00ffff97dd890000 RSI: ffff97ddbe5d89c8 RDI: f=
fff97ddbe5d89c8<br>
[=C2=A0 =C2=A013.867362] RBP: ffff97dd890fd000 R08: ffff97ddbe5d89c8 R09: 0=
000000000000000<br>
[=C2=A0 =C2=A013.869121] R10: 0000000000000000 R11: 0000000000000000 R12: f=
fff97dd890fd001<br>
[=C2=A0 =C2=A013.871091] R13: ffff97dd890fd010 R14: ffff97ddb5f96408 R15: f=
fffb18cc0197838<br>
[=C2=A0 =C2=A013.872742] FS:=C2=A0 0000000000000000(0000) GS:ffff97ddbe4000=
00(0000)<br>
knlGS:0000000000000000<br>
[=C2=A0 =C2=A013.874448] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 000000008005=
0033<br>
[=C2=A0 =C2=A013.876382] CR2: 00007fec8745f010 CR3: 0000000006212004 CR4: 0=
000000000160ef0<br>
[=C2=A0 =C2=A013.878007] ------------[ cut here ]------------<br>
<br>
<br>
(gdb) l *handle_to_buddy+0x20<br>
0xffffffff813376b0 is in handle_to_buddy (/src/linux/mm/z3fold.c:429).<br>
424 unsigned long addr;<br>
425<br>
426 WARN_ON(handle &amp; (1 &lt;&lt; PAGE_HEADLESS));<br>
427 addr =3D *(unsigned long *)handle;<br>
428 zhdr =3D (struct z3fold_header *)(addr &amp; PAGE_MASK);<br>
429 return (addr - zhdr-&gt;first_num) &amp; BUDDY_MASK;<br>
430 }<br>
431<br>
432 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zh=
dr)<br>
433 {<br>
(gdb) l *z3fold_zpool_map+0x76<br>
0xffffffff81337cb6 is in z3fold_zpool_map (/src/linux/mm/z3fold.c:1257).<br=
>
1252 if (test_bit(PAGE_HEADLESS, &amp;page-&gt;private))<br>
1253 goto out;<br>
1254<br>
1255 z3fold_page_lock(zhdr);<br>
1256 buddy =3D handle_to_buddy(handle);<br>
1257 switch (buddy) {<br>
1258 case FIRST:<br>
1259 addr +=3D ZHDR_SIZE_ALIGNED;<br>
1260 break;<br>
1261 case MIDDLE:<br>
(gdb) l *zswap_writeback_entry+0x50<br>
0xffffffff812e8260 is in zswap_writeback_entry (/src/linux/mm/zswap.c:858).=
<br>
853 .sync_mode =3D WB_SYNC_NONE,<br>
854 };<br>
855<br>
856 /* extract swpentry from data */<br>
857 zhdr =3D zpool_map_handle(pool, handle, ZPOOL_MM_RO);<br>
858 swpentry =3D zhdr-&gt;swpentry; /* here */<br>
859 zpool_unmap_handle(pool, handle);<br>
860 tree =3D zswap_trees[swp_type(swpentry)];<br>
861 offset =3D swp_offset(swpentry);<br>
(gdb) l *z3fold_zpool_shrink+0x3d1<br>
0xffffffff81338821 is in z3fold_zpool_shrink (/src/linux/mm/z3fold.c:1186).=
<br>
1181 ret =3D pool-&gt;ops-&gt;evict(pool, middle_handle);<br>
1182 if (ret)<br>
1183 goto next;<br>
1184 }<br>
1185 if (first_handle) {<br>
1186 ret =3D pool-&gt;ops-&gt;evict(pool, first_handle);<br>
1187 if (ret)<br>
1188 goto next;<br>
1189 }<br>
1190 if (last_handle) {<br>
<br>
<br>
To compare, I got following Call Trace &quot;signatures&quot; against vanil=
la<br>
v5.3-rc5. Some of them might not be related to zswap at all.<br>
<br>
[=C2=A0 =C2=A015.469831] Call Trace:<br>
[=C2=A0 =C2=A015.470171]=C2=A0 migrate_pages+0x20c/0xfb0<br>
[=C2=A0 =C2=A015.470678]=C2=A0 ? isolate_freepages_block+0x410/0x410<br>
[=C2=A0 =C2=A015.471344]=C2=A0 ? __ClearPageMovable+0x90/0x90<br>
[=C2=A0 =C2=A015.471914]=C2=A0 compact_zone+0x74c/0xef0<br>
--<br>
[=C2=A0 105.611480] Call Trace:<br>
[=C2=A0 105.611817]=C2=A0 zswap_writeback_entry+0x50/0x410<br>
[=C2=A0 105.612417]=C2=A0 z3fold_zpool_shrink+0x29d/0x540<br>
[=C2=A0 105.612947]=C2=A0 zswap_frontswap_store+0x424/0x7c1<br>
[=C2=A0 105.613494]=C2=A0 __frontswap_store+0xc4/0x162<br>
--<br>
[=C2=A0 =C2=A015.103942] Call Trace:<br>
[=C2=A0 =C2=A015.104280]=C2=A0 z3fold_zpool_map+0x76/0x110<br>
[=C2=A0 =C2=A015.104824]=C2=A0 zswap_writeback_entry+0x50/0x410<br>
[=C2=A0 =C2=A015.105398]=C2=A0 z3fold_zpool_shrink+0x3c4/0x540<br>
[=C2=A0 =C2=A015.105960]=C2=A0 zswap_frontswap_store+0x424/0x7c1<br>
--<br>
[=C2=A0 632.066122] Call Trace:<br>
[=C2=A0 632.066124]=C2=A0 z3fold_zpool_map+0x76/0x110<br>
[=C2=A0 632.066128]=C2=A0 zswap_writeback_entry+0x50/0x410<br>
[=C2=A0 632.069101]=C2=A0 do_user_addr_fault+0x1fe/0x480<br>
[=C2=A0 632.069650]=C2=A0 z3fold_zpool_shrink+0x3c4/0x540<br>
--<br>
[=C2=A0 133.419601] Call Trace:<br>
[=C2=A0 133.420199]=C2=A0 zswap_writeback_entry+0x50/0x410<br>
[=C2=A0 133.421244]=C2=A0 z3fold_zpool_shrink+0x4a6/0x540<br>
[=C2=A0 133.422266]=C2=A0 zswap_frontswap_store+0x424/0x7c1<br>
[=C2=A0 133.423386]=C2=A0 __frontswap_store+0xc4/0x162<br>
--<br>
[=C2=A0 155.374773] Call Trace:<br>
[=C2=A0 155.375122]=C2=A0 get_page_from_freelist+0x57d/0x1a40<br>
[=C2=A0 155.375725]=C2=A0 __alloc_pages_nodemask+0x19d/0x400<br>
[=C2=A0 155.376354]=C2=A0 alloc_pages_vma+0xcc/0x170<br>
[=C2=A0 155.376854]=C2=A0 __read_swap_cache_async+0x1e9/0x3e0<br>
--<br>
[=C2=A0 =C2=A023.849834] Call Trace:<br>
[=C2=A0 =C2=A023.851038]=C2=A0 get_page_from_freelist+0x57d/0x1a40<br>
[=C2=A0 =C2=A023.853300]=C2=A0 ? wake_all_kswapds+0x54/0xb0<br>
[=C2=A0 =C2=A023.855280]=C2=A0 __alloc_pages_slowpath+0x1ae/0x1000<br>
[=C2=A0 =C2=A023.857512]=C2=A0 ? __lock_acquire+0x247/0x1900<br>
--<br>
[=C2=A0 197.206331] Call Trace:<br>
[=C2=A0 197.207923]=C2=A0 __release_z3fold_page.constprop.0+0x7e/0x130<br>
[=C2=A0 197.211387]=C2=A0 do_compact_page+0x2c9/0x430<br>
[=C2=A0 197.213830]=C2=A0 process_one_work+0x272/0x5a0<br>
[=C2=A0 197.216392]=C2=A0 worker_thread+0x50/0x3b0<br>
</blockquote></div></div></div>

--000000000000d1f39805907d89e7--

