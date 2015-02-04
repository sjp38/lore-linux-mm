Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 706336B0083
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 11:34:27 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id 29so1109485yhl.13
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 08:34:27 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id x47si602437yhd.91.2015.02.04.08.34.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 08:34:25 -0800 (PST)
Received: by mail-qg0-f48.google.com with SMTP id a108so2002747qge.7
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 08:34:24 -0800 (PST)
MIME-Version: 1.0
From: Andrey Korolyov <andrey@xdel.ru>
Date: Wed, 4 Feb 2015 20:34:04 +0400
Message-ID: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, wanpeng.li@linux.intel.com, jipan.yang@gmail.com

>Hi,
>
>I've seen the problem quite a few times.  Before spending more time on
>it, I'd like to have a quick check here to see if anyone ever saw the
>same problem?  Hope it is a relevant question with this mail list.
>
>
>Jul  2 11:08:21 arno-3 kernel: [ 2165.078623] BUG: unable to handle
>kernel NULL pointer dereference at 0000000000000008
>Jul  2 11:08:21 arno-3 kernel: [ 2165.078916] IP: [<ffffffff8118d0fa>]
>copy_huge_page+0x8a/0x2a0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079128] PGD 0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079198] Oops: 0000 [#1] SMP
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079319] Modules linked in:
>ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
>iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle xt_tcpudp
>iptable_filter ip_tables x_tables kvm_intel kvm bridge stp llc ast ttm
>drm_kms_helper drm sysimgblt sysfillrect syscopyarea lp mei_me ioatdma
>ext2 parport mei shpchp dcdbas joydev mac_hid lpc_ich acpi_pad wmi
>hid_generic usbhid hid ixgbe igb dca i2c_algo_bit ahci ptp libahci
>mdio pps_core
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081090] CPU: 19 PID: 3494 Comm:
>qemu-system-x86 Not tainted 3.11.0-15-generic #25~precise1-Ubuntu
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081424] Hardware name: Dell Inc.
>PowerEdge C6220 II/09N44V, BIOS 2.0.3 07/03/2013
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081705] task: ffff881026750000
>ti: ffff881026056000 task.ti: ffff881026056000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081973] RIP:
>0010:[<ffffffff8118d0fa>]  [<ffffffff8118d0fa>]
>copy_huge_page+0x8a/0x2a0


Hello,

sorry for possible top-posting, the same issue appears on at least
3.10 LTS series. The original thread is at
http://marc.info/?l=kvm&m=14043742300901. The necessary components for
failure to reappear are a single running kvm guest and mounted large
thp: hugepagesz=1G (seemingly the same as in initial report). With
default 2M pages everything is working well, the same for 3.18 with 1G
THP. Are there any obvious clues for the issue?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
