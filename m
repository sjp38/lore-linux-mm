Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 28C4F6B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 21:04:14 -0400 (EDT)
Received: by pvc30 with SMTP id 30so641748pvc.14
        for <linux-mm@kvack.org>; Thu, 08 Jul 2010 18:04:11 -0700 (PDT)
Message-ID: <4C3675B5.5090903@gmail.com>
Date: Thu, 08 Jul 2010 18:04:53 -0700
From: "Justin P. Mattock" <justinmattock@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug 16337] general protection fault: 0000 [#1] SMP
References: <201007082338.o68NcT0C019156@demeter.kernel.org> <20100708171855.872d7910.akpm@linux-foundation.org> <20100709094849.CD62.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100709094849.CD62.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/08/2010 05:53 PM, KOSAKI Motohiro wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Thu, 8 Jul 2010 23:38:29 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=16337
>>
>> [10384.818511] general protection fault: 0000 [#1] SMP
>> : [10384.818517] last sysfs file: /sys/devices/platform/applesmc.768/light
>> : [10384.818520] CPU 1
>> : [10384.818522] Modules linked in: radeon ttm drm_kms_helper drm sco xcbc bnep rmd160 sha512_generic xt_tcpudp ipt_LOG iptable_nat nf_nat xt_state nf_conntrack_ftp nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables ath9k ath9k_common firewire_ohci firewire_core battery ath9k_hw ac video evdev ohci1394 sky2 ath joydev button thermal i2c_i801 hid_magicmouse aes_x86_64 lzo lzo_compress zlib ipcomp xfrm_ipcomp crypto_null sha256_generic cbc des_generic cast5 blowfish serpent camellia twofish twofish_common ctr ah4 esp4 authenc raw1394 ieee1394 uhci_hcd ehci_hcd hci_uart rfcomm btusb hidp l2cap bluetooth coretemp acpi_cpufreq processor mperf appletouch applesmc uvcvideo
>> : [10384.818594]
>> : [10384.818598] Pid: 409, comm: kswapd0 Not tainted 2.6.35-rc3-00398-g5a847c7-dirty #13 Mac-F42187C8/MacBookPro2,2
>> : [10384.818601] RIP: 0010:[<ffffffff810b7487>]  [<ffffffff810b7487>] find_get_pages+0x62/0xc0
>> : [10384.818611] RSP: 0018:ffff88003e011b40  EFLAGS: 00010293
>> : [10384.818614] RAX: ffff88000008f000 RBX: ffff88003e011bf0 RCX: 0000000000000003
>> : [10384.818617] RDX: ffff88003e011c08 RSI: 0000000000000001 RDI: 8ed88ec88ce88b66
>> : [10384.818620] RBP: ffff88003e011b90 R08: 8ed88ec88ce88b6e R09: 0000000000000002
>> : [10384.818623] R10: ffff88000008f050 R11: ffff88000008f050 R12: ffffffffffffffff
>> : [10384.818626] R13: 000000000000000e R14: 0000000000000000 R15: 0000000000000003
>> : [10384.818629] FS:  0000000000000000(0000) GS:ffff880001b00000(0000) knlGS:0000000000000000
>> : [10384.818632] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> : [10384.818635] CR2: 00007f1a8989b000 CR3: 000000000166d000 CR4: 00000000000006e0
>> : [10384.818638] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> : [10384.818641] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> : [10384.818644] Process kswapd0 (pid: 409, threadinfo ffff88003e010000, task ffff88003eded490)
>> : [10384.818646] Stack:
>> : [10384.818648]  ffff88003e011b70 ffffffff810c0e85 ffff880018a2afe0 0000000e0001fad8
>> : [10384.818652]<0>  ffff880018a30c68 ffff88003e011be0 0000000000000000 ffff88003e011be0
>> : [10384.818657]<0>  ffffffffffffffff ffff880018a2afd8 ffff88003e011bb0 ffffffff810bed06
>> : [10384.818663] Call Trace:
>> : [10384.818669]  [<ffffffff810c0e85>] ? __remove_mapping+0xa5/0xbe
>> : [10384.818674]  [<ffffffff810bed06>] pagevec_lookup+0x1d/0x26
>> : [10384.818678]  [<ffffffff810bfb78>] invalidate_mapping_pages+0xe7/0x10b
>> : [10384.818683]  [<ffffffff810fdc4a>] shrink_icache_memory+0x10a/0x227
>> : [10384.818687]  [<ffffffff810c21fc>] shrink_slab+0xd6/0x147
>> : [10384.818691]  [<ffffffff810c25d2>] balance_pgdat+0x365/0x5b4
>> : [10384.818695]  [<ffffffff810c29c7>] kswapd+0x1a6/0x1bc
>> : [10384.818700]  [<ffffffff81070d75>] ? autoremove_wake_function+0x0/0x34
>> : [10384.818704]  [<ffffffff810c2821>] ? kswapd+0x0/0x1bc
>> : [10384.818707]  [<ffffffff81070953>] kthread+0x7a/0x82
>> : [10384.818712]  [<ffffffff81027264>] kernel_thread_helper+0x4/0x10
>> : [10384.818716]  [<ffffffff810708d9>] ? kthread+0x0/0x82
>> : [10384.818719]  [<ffffffff81027260>] ? kernel_thread_helper+0x0/0x10
>> : [10384.818721] Code: f5 d0 11 00 48 89 da 89 45 cc 31 c9 eb 64 48 8b 02 48 8b 38 40 f6 c7 01 49 0f 45 fc 48 85 ff 74 4b 48 83 ff ff 74 c8 4c 8d 47 08<8b>  77 08 85 f6 74 dc 44 8d 4e 01 89 f0 f0 45 0f b1 08 39 f0 74
>> : [10384.818762] RIP  [<ffffffff810b7487>] find_get_pages+0x62/0xc0
>> : [10384.818767]  RSP<ffff88003e011b40>
>> : [10384.818770] ---[ end trace 594fde37483e4533 ]---
>> :
>>
>> Gad.  Did we do anything recently which could have caused that?
>
> I can't find doubious commit in this area ;-)
>
>
>
>


when this hit.. I had only reverted this commit 6a4f3b52. As for seeing 
this again nothing.. only this one time so far..(tried numerous times to 
reproduce so I can bisect, but nothing, just the one time).

Justin P. Mattock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
