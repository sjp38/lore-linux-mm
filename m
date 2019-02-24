Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F83C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 08:05:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC450206BA
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 08:05:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=wiesinger.com header.i=@wiesinger.com header.b="Vmkx92B3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC450206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wiesinger.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8319D8E015C; Sun, 24 Feb 2019 03:05:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E14F8E015B; Sun, 24 Feb 2019 03:05:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6834B8E015C; Sun, 24 Feb 2019 03:05:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E99988E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 03:05:22 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id u74so988044wmf.0
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 00:05:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:to:from:subject:cc
         :message-id:date:user-agent:mime-version:content-transfer-encoding
         :content-language;
        bh=P+mNbIM+XehTCK2pT9JWPp0Mof+iSV1ybR9LprpnNMI=;
        b=baffxnziIf/VuoDJPArzNQPKuEOimlzgKOYxuZleCtd9+Oo2h1smUR7EzuuZyfKIrc
         20SbCka01mXYhbPMNl0wiaQCyBz2xZek+GDEGFOiJO9j5iYIte8qoekiCds0im3Rty9R
         GOaeOgdomVG5oUhDBPdt02veRc+E8wPEiW/N9PlqFDAplCzZAEg+s5nFT4yOfrpHFGit
         RQGbv1VP2aNaUBlOamnh19ONKOcD2j7pCYBGS5cuapgJTqNcnCdKIW72GvyAmEQvbdiB
         wwv4TB2EWMCPoQ52JYz4WfGTkxWih6tEadG3zNC84DHSIXoez/7SN9/t33fA5NKRJveU
         WzgA==
X-Gm-Message-State: AHQUAuZ9q5F82tq89pfDm6AwV9LxUJPcSONXjjZj+liF5EBzChubMGwg
	JmzNDvpGtUN6UW0XeS/euDDOWzRIGGjMcISiM0sdYBF+qMRHIFnMJEWsr9Yh3c7qqJSnd/iuJ31
	+ZZBCIjgGEe5ldH+eMd2H7Db6h9hFF+WI/94jRVnXqIQjNk/EXGCurL93N2Y63CmTzw==
X-Received: by 2002:a1c:a5c8:: with SMTP id o191mr6981064wme.137.1550995522177;
        Sun, 24 Feb 2019 00:05:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBH7nfkIexHbvU5b/1qFF2hqRj39wrnkpo8YlKf9ENoUeXbgIPaDaSjkbZRG5PUPQCobY5
X-Received: by 2002:a1c:a5c8:: with SMTP id o191mr6980946wme.137.1550995519616;
        Sun, 24 Feb 2019 00:05:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550995519; cv=none;
        d=google.com; s=arc-20160816;
        b=gzK4ykpfbS59IRAMBMb68UhXVk4XixZKpT2iqdpyV6V2zP+Ndn8orqM81qJwP+fj9W
         2ZDOfLezvzSyUledGIoSZ31i35tXt+S1fCg80jM4RfZ1pAV2dsR65rmtpmV3Jw8DfPtr
         BIy0AiQ5Ahlrb+tJfkRFeIJC1fb+lcDxxp1oR86OWmtWCYAZ4ji9SBXH6f8wrybQyRoH
         pW89qsj9gWL2Wf85cjk90O5CgVoxywJ64YApGET1P3z4i5+ReylTw8xVG0T+EQjPJl8M
         SQE+cZs9XWNCNCUVAmuWppjAUQSGxHTNGJSzDWYYKi2RRs5XDbd3FKkANNDv2AlD5eM8
         T3WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:cc:subject:from:to:dkim-signature:dkim-filter;
        bh=P+mNbIM+XehTCK2pT9JWPp0Mof+iSV1ybR9LprpnNMI=;
        b=AIudMg9RZrDrg+4kzHXoNuS5j7iSODDwwy3pMMmU+KGmZK3kp34hOuNaff3UcLZsZo
         TPNsbYH0Faj90xEcN9wIj44MC1Ru354EHGHBjpMtUMMg4siXPm0UaDUS7VzlRJfK1Q5k
         iQU17fozEhgaC9a8XUNbtLRWFuiuq9jVb5l8U8ntaYOBn4vJtcJSk6WxjrhIMWJ4n5Y6
         gnS5rOj28V4vah2wtfmM2bPiSLpTTyU3/OWPzYtG9vSM+8gH48+XfC6Y8LRiO5fxum24
         DmOZHKSMWA6XysmeK29yH9XvZz9RthDWblmEkXORzwE2S6kyq1K6L3DtiqMuFKLyNnup
         epOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=Vmkx92B3;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id h8si3427967wmb.159.2019.02.24.00.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 24 Feb 2019 00:05:19 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) client-ip=46.36.37.179;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=Vmkx92B3;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from wiesinger.com (wiesinger.com [84.113.44.87])
	by vps01.wiesinger.com (Postfix) with ESMTPS id BB1429F2C4;
	Sun, 24 Feb 2019 09:05:16 +0100 (CET)
Received: from [192.168.32.242] (bgld-ip-242.intern [192.168.32.242])
	(authenticated bits=0)
	by wiesinger.com (8.15.2/8.15.2) with ESMTPSA id x1O84v2W011708
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Sun, 24 Feb 2019 09:05:07 +0100
DKIM-Filter: OpenDKIM Filter v2.11.0 wiesinger.com x1O84v2W011708
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wiesinger.com;
	s=default; t=1550995512;
	bh=P+mNbIM+XehTCK2pT9JWPp0Mof+iSV1ybR9LprpnNMI=;
	h=To:From:Subject:Cc:Date:From;
	b=Vmkx92B3tce695QjysTTCAUhLIKXgWQ8I6h07ve8XE9I5M2QNvflhlsM3awG+WdYK
	 xu0Kgpsln2ptjF9VUzr2PNQBo0GwsVRvmUwwA6eKiWDzLN+GW2LrCQjjM1wFF87F2T
	 RiwzCAsGWHlVi7ANa6nSzkQ4vLm/fqyLV1+PgPb29M9y7Nc/QRVK4LN4ZUuvFQzQhf
	 2wByTuXFNypYEVZf5v7+EtQLwEHzM6cFGDkRBhmlRNBUhFCFP0hDpUuPzPRPPSQDR1
	 0hEjqM+JwitzslKKrlW7zq7qq3djDnX+j4znxwQLmOe602RPp1XqAJCmA/PdYiuLCx
	 Fgg49br+VMVoTrcUMHW+QFqjYCns0/5arEX1tuSYvhaJEmtNVjw0PW7tL5iKHyz/iT
	 YG8NLlneX9oCVxMt3zFNipxx2KNQQb9D3zNzHf0tGlbe6O24j8cdfkq/6QQTRkChaj
	 eZrJRRX0KxUs9CAsg7hK5DpRsA2DCjV6oKQsKYFkSDIRd2EEK01jQn20do3RM+4U/9
	 fLKyDBJYtZrRPhFGFqnRCTbgihZpNza6rvWWSOugIp4UhbvsBpetnwIiV5jgStTHdp
	 WJDUnP/n5C7SRV64wH523pWhbPUCCA1+o6NFCCDEOxFO/K7UCYsv5WEot91AYLATls
	 kbF8CRs4so5nVCI/MzzEXY3o=
To: arm@lists.fedoraproject.org, Maxime Ripard <maxime.ripard@bootlin.com>,
        Chen-Yu Tsai <wens@csie.org>, LKML <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org
From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Banana Pi-R1 stabil
Cc: Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
Message-ID: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
Date: Sun, 24 Feb 2019 09:04:57 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I've 3 Banana Pi R1, one running with self compiled kernel 
4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 
2 others are running with Fedora 29 latest, kernel 
4.20.10-200.fc29.armv7hl. I tried a lot of kernels between of around 
4.11 (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes 
without any output on the serial console or kernel panics after a short 
time of period (minutes, hours, max. days)

Latest known working and stable self compiled kernel: kernel 
4.7.4-200.BPiR1.fc24.armv7hl:

https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/

With 4.8.x the DSA b53 switch infrastructure has been introduced which 
didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel 
4.18.x):

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/net/dsa/b53?h=v4.20.12

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=v4.20.12

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/drivers/net/dsa/b53?h=v4.20.12&id=ca8931948344c485569b04821d1f6bcebccd376b

I has been fixed with kernel 4.18.x:

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=linux-4.18.y


So current status is, that kernel crashes regularly, see some samples 
below. It is typically a "Unable to handle kernel paging request at 
virtual addres"

Another interesting thing: A Banana Pro works well (which has also an 
Allwinner A20 in the same revision) running same Fedora 29 and latest 
kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).

Since it happens on 2 different devices and with different power 
supplies (all with enough power) and also the same type which works well 
on the working old kernel) a hardware issue is very unlikely.

I guess it has something to do with virtual memory.

Any ideas?

Thanx.

Ciao,

Gerhard

[47322.960193] Unable to handle kernel paging request at virtual addres 
5675d0
[47322.967832] pgd = c4567fe6
[47322.970913] [085675d0] *pgd=00000000
[47322.974795] Internal error: Oops: 5 [#1] SMP ARM
[47322.979522] Modules linked in: xt_recent xt_comment ip_set_hash_net 
ip_set xt_addrtype iptable_nat nf_nat_ipv4 xt_mark iptable_mangle xt_CT 
iptable_raw xt_multiport xt_conntrack nfnetlink_log xt_NFLOG nf_log_ipv4 
nf_log_common xt_LOG nf_conntrack_sane nf_conntrack_netlink nfnetlink 
nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp 
nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_nat 
nf_conntrack_tftp nf_conntrack_sip nf_conntrack_pptp 
nf_conntrack_proto_gre nf_conntrack_netbios_ns nf_conntrack_broadcast 
nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp ts_kmp 
nf_conntrack_amanda nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c 
8021q garp mrp rtl8xxxu arc4 rtl8192cu rtl_usb rtl8192c_common rtlwifi 
mac80211 cfg80211 huawei_cdc_ncm cdc_wdm cdc_ncm option usbnet mii 
usb_wwan rfkill b53_mdio b53_common dsa_core sun4i_codec bridge 
snd_soc_core stp llc axp20x_pek ac97_bus phylink snd_pcm_dmaengine 
axp20x_adc snd_pcm devlink sun4i_backend snd_timer
[47322.980312]  sun4i_gpadc_iio snd sunxi_cir sun4i_ts nvmem_sunxi_sid 
rc_core soundcore sun4i_drm sunxi_wdt sun4i_ss sun4i_frontend sun4i_tcon 
des_generic sun4i_drm_hdmi sun8i_tcon_top drm_kms_helper spi_sun4i drm 
fb_sys_fops syscopyarea sysfillrect sysimgblt leds_gpio cpufreq_dt 
axp20x_usb_power axp20x_battery axp20x_ac_power industrialio 
axp20x_regulator pinctrl_axp209 mmc_block dwmac_sunxi stmmac_platform 
sunxi phy_generic stmmac musb_hdrc i2c_mv64xxx sun4i_gpadc ahci_sunxi 
udc_core phy_sun4i_usb libahci_platform ohci_platform ehci_platform 
sun4i_dma sunxi_mmc rtc_ds1307 i2c_dev
[47323.120402] CPU: 1 PID: 31989 Comm: kworker/1:4 Not tainted 
4.20.10-200.fc29.armv7hl #1
[47323.128536] Hardware name: Allwinner sun7i (A20) Family
[47323.133910] Workqueue: events dbs_work_handler
[47323.138500] PC is at regulator_set_voltage_unlocked+0x14/0x304
[47323.144456] LR is at regulator_set_voltage+0x34/0x48
[47323.149524] pc : [<c078b814>]    lr : [<c078bb38>]    psr: 60070013
[47323.155898] sp : eb23ddf8  ip : 00000000  fp : c9567580
[47323.161222] r10: 365c0400  r9 : 000f4240  r8 : 000f4240
[47323.166552] r7 : ef692050  r6 : 08567580  r5 : 000f4240  r4 : 08567580
[47323.173190] r3 : 00000000  r2 : 000f4240  r1 : 000f4240  r0 : 08567580
[47323.179832] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  
Segment none
[47323.187085] Control: 10c5387d  Table: 6d53c06a  DAC: 00000051
[47323.192950] Process kworker/1:4 (pid: 31989, stack limit = 0x40c1176f)
[47323.199582] Stack: (0xeb23ddf8 to 0xeb23e000)
[47323.204045] dde0: ef034e40 016e3600
[47323.212397] de00: 365c0400 365c0400 c9567580 c07404fc 02dc6c00 
08567580 000f4240 000f4240
[47323.220748] de20: ef692050 000f4240 000f4240 365c0400 c9567580 
c078bb38 c9657b2c 00000000
[47323.229100] de40: c9567580 c0957fe8 08954400 c12bcd08 c975683c 
08954400 ee739a40 00690050
[47323.237450] de60: 00000000 c9756800 c96573c0 c96573ec c9657b00 
c0958940 00000000 ee72e300
[47323.245798] de80: c9657b2c 08954400 08954400 365c0400 00000000 
ee72e300 00023280 00000000
[47323.254143] dea0: 00000000 c13bda88 00000000 00023280 00000008 
bf1fa0d8 00000000 ee72e300
[47323.262487] dec0: 00000000 c095d334 00000000 00000000 00000002 
000dea80 00023280 00000021
[47323.270836] dee0: ee72e300 c9567980 00000000 00000000 c9567f80 
c9567980 c9657080 c0960730
[47323.279186] df00: c95679b8 ee72e300 c9567984 c1304648 00000000 
c95679bc 00000000 c0961184
[47323.287536] df20: eb299500 c95679b8 ef6a9a00 ef6acd00 00000000 
c0369710 eb299500 c95679b8
[47323.295888] df40: eb299500 ef6a9a00 ef6a9a00 ffffe000 c1203d00 
ef6a9a18 eb299514 c036a448
[47323.304237] df60: 00000000 ea1c8cc0 ea097d80 eb23c000 eb299500 
c036a18c 00000000 ea3e3ee0
[47323.312584] df80: ea1c8cdc c036effc 0000007e ea097d80 c036eec4 
00000000 00000000 00000000
[47323.320923] dfa0: 00000000 00000000 00000000 c03010e8 00000000 
00000000 00000000 00000000
[47323.329260] dfc0: 00000000 00000000 00000000 00000000 00000000 
00000000 00000000 00000000
[47323.337597] dfe0: 00000000 00000000 00000000 00000000 00000013 
00000000 00000000 00000000
[47323.345994] [<c078b814>] (regulator_set_voltage_unlocked) from 
[<c078bb38>] (regulator_set_voltage+0x34/0x48)
[47323.356118] [<c078bb38>] (regulator_set_voltage) from [<c0957fe8>] 
(_set_opp_voltage+0x74/0x108)
[47323.365107] [<c0957fe8>] (_set_opp_voltage) from [<c0958940>] 
(dev_pm_opp_set_rate+0x398/0x48c)
[47323.374049] [<c0958940>] (dev_pm_opp_set_rate) from [<bf1fa0d8>] 
(set_target+0x34/0x54 [cpufreq_dt])
[47323.383477] [<bf1fa0d8>] (set_target [cpufreq_dt]) from [<c095d334>] 
(__cpufreq_driver_target+0x444/0x510)
[47323.393349] [<c095d334>] (__cpufreq_driver_target) from [<c0960730>] 
(od_dbs_update+0xd4/0x160)
[47323.402241] [<c0960730>] (od_dbs_update) from [<c0961184>] 
(dbs_work_handler+0x30/0x5c)
[47323.410426] [<c0961184>] (dbs_work_handler) from [<c0369710>] 
(process_one_work+0x23c/0x41c)
[47323.419047] [<c0369710>] (process_one_work) from [<c036a448>] 
(worker_thread+0x2bc/0x43c)
[47323.427409] [<c036a448>] (worker_thread) from [<c036effc>] 
(kthread+0x138/0x150)
[47323.434984] [<c036effc>] (kthread) from [<c03010e8>] 
(ret_from_fork+0x14/0x2c)
[47323.442338] Exception stack(0xeb23dfb0 to 0xeb23dff8)
[47323.447502] dfa0:                                     00000000 
00000000 00000000 00000000
[47323.455839] dfc0: 00000000 00000000 00000000 00000000 00000000 
00000000 00000000 00000000
[47323.464168] dfe0: 00000000 00000000 0

================================================================================================================================================================

[52329.225568] Unable to handle kernel NULL pointer dereference at 
virtual address 00000067
[52329.233848] pgd = 3694849b
[52329.236624] [00000067] *pgd=00000000
[52329.240307] Internal error: Oops: 805 [#1] SMP ARM
[52329.245176] Modules linked in: xt_recent xt_comment ip_set_hash_net 
ip_set xt_addrtype iptable_nat nf_nat_ipv4 xt_mark i
ptable_mangle xt_CT iptable_raw xt_multiport xt_conntrack nfnetlink_log 
xt_NFLOG nf_log_ipv4 nf_log_common xt_LOG nf_conntr
ack_sane nf_conntrack_netlink nfnetlink nf_nat_tftp nf_nat_snmp_basic 
nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto
_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_nat 
nf_conntrack_tftp nf_conntrack_sip nf_conntrack_pptp nf_conntra
ck_proto_gre nf_conntrack_netbios_ns nf_conntrack_broadcast 
nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp ts_kmp nf_c
onntrack_amanda nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c 
8021q garp mrp rtl8xxxu arc4 rtl8192cu rtl_usb rtl8192
c_common rtlwifi mac80211 huawei_cdc_ncm cdc_wdm cfg80211 cdc_ncm option 
usbnet usb_wwan mii rfkill b53_mdio b53_common dsa
_core bridge sun4i_codec stp snd_soc_core llc phylink devlink ac97_bus 
snd_pcm_dmaengine axp20x_adc snd_pcm axp20x_pek sun4
i_backend sunxi_cir
[52329.245959]  snd_timer sun4i_gpadc_iio snd rc_core sun4i_ts soundcore 
nvmem_sunxi_sid sunxi_wdt sun4i_drm sun4i_frontend
  sun4i_ss sun4i_tcon sun4i_drm_hdmi des_generic sun8i_tcon_top 
drm_kms_helper drm spi_sun4i fb_sys_fops syscopyarea sysfill
rect sysimgblt leds_gpio cpufreq_dt axp20x_usb_power axp20x_ac_power 
axp20x_battery industrialio axp20x_regulator pinctrl_a
xp209 mmc_block dwmac_sunxi sunxi stmmac_platform phy_generic stmmac 
musb_hdrc i2c_mv64xxx sun4i_gpadc ahci_sunxi phy_sun4i
_usb sunxi_mmc udc_core libahci_platform ohci_platform ehci_platform 
sun4i_dma rtc_ds1307 i2c_dev
[52329.386308] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 
4.20.10-200.fc29.armv7hl #1
[52329.393913] Hardware name: Allwinner sun7i (A20) Family
[52329.399291] PC is at collect_expired_timers+0xac/0xd8
[52329.404452] LR is at 0x63
[52329.407162] pc : [<c03c5d64>]    lr : [<00000063>]    psr: 20010193
[52329.413537] sp : ef147e88  ip : 00633ada  fp : c1204df4
[52329.418859] r10: 10000000  r9 : 00000002  r8 : 00000000
[52329.424188] r7 : 00000001  r6 : ef6a4698  r5 : ef147eac  r4 : ef6a46e0
[52329.430824] r3 : 00000040  r2 : 0000005a  r1 : ef147eb0  r0 : 00000001
[52329.437467] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  
Segment none
[52329.444824] Control: 10c5387d  Table: 6d54806a  DAC: 00000051
[52329.450679] Process swapper/1 (pid: 0, stack limit = 0xf38eb60d)
[52329.456792] Stack: (0xef147e88 to 0xef148000)
[52329.461276] 7e80:                   ef6a4680 c1203d00 c1140680 
c11459c0 2e564000 00000100
[52329.469626] 7ea0: c1203080 c03c6150 2e564000 00000063 ffffe000 
ef138000 c11459c0 ef0cac00
[52329.477974] 7ec0: ef146000 c1144f30 00000000 c037d924 c1203084 
00000001 00000082 c11459c0
[52329.486319] 7ee0: ffffe000 c0302994 00000001 00ffffff 00200042 
0000000a 0319d6d2 00000002
[52329.494668] 7f00: c1203d00 ef0cac00 ef146000 ffffe000 00000000 
c11459a4 00000013 ef0cac00
[52329.503014] 7f20: ef146000 c1144f30 00000000 c0356bfc 00000000 
c03af364 c1205998 f0802000
[52329.511364] 7f40: ef147f68 f0803000 c1204df4 c0302588 c0309574 
60010013 ffffffff ef147f9c
[52329.519710] 7f60: c1204df4 c0301a0c 00000000 019d6174 00000001 
c031db20 00000000 ffffe000
[52329.528055] 7f80: 00000000 00000002 c1204df4 c1204e3c c1144f30 
00000000 00000000 ef147fb8
[52329.536403] 7fa0: c0309598 c0309574 60010013 ffffffff 00000051 
00000000 00000000 c037ea58
[52329.544749] 7fc0: ef6a9e00 00000000 00000002 00000087 00000051 
10c0387d c1343a68 4020406a
[52329.553094] 7fe0: 410fc074 00000000 00000000 c037edd0 6f13406a 
40302b6c 00000000 00000000
[52329.561494] [<c03c5d64>] (collect_expired_timers) from [<c03c6150>] 
(run_timer_softirq+0xf8/0x168)
[52329.570651] [<c03c6150>] (run_timer_softirq) from [<c0302994>] 
(__do_softirq+0x244/0x380)
[52329.579015] [<c0302994>] (__do_softirq) from [<c0356bfc>] 
(irq_exit+0x7c/0xdc)
[52329.586418] [<c0356bfc>] (irq_exit) from [<c03af364>] 
(__handle_domain_irq+0x88/0xbc)
[52329.594432] [<c03af364>] (__handle_domain_irq) from [<c0302588>] 
(gic_handle_irq+0x5c/0x88)
[52329.602958] [<c0302588>] (gic_handle_irq) from [<c0301a0c>] 
(__irq_svc+0x6c/0x90)
[52329.610573] Exception stack(0xef147f68 to 0xef147fb0)
[52329.615749] 7f60:                   00000000 019d6174 00000001 
c031db20 00000000 ffffe000
[52329.624093] 7f80: 00000000 00000002 c1204df4 c1204e3c c1144f30 
00000000 00000000 ef147fb8
[52329.632418] 7fa0: c0309598 c0309574 60010013 ffffffff
[52329.637626] [<c0301a0c>] (__irq_svc) from [<c0309574>] 
(arch_cpu_idle+0x24/0x54)
[52329.645210] [<c0309574>] (arch_cpu_idle) from [<c037ea58>] 
(do_idle+0x11c/0x240)
[52329.652791] [<c037ea58>] (do_idle) from [<c037edd0>] 
(cpu_startup_entry+0x20/0x28)
[52329.660527] [<c037edd0>] (cpu_startup_entry) from [<40302b6c>] 
(0x40302b6c)
[52329.667640] Code: e794e102 e2800001 e481e004 e35e0000 (158e5004)
[52329.673878] ---[ end trace a2a7eae81da6630f ]---
[52329.678593] Kernel panic - not syncing: Fatal exception in interrupt
[52329.685097] CPU0: stopping
[52329.687952] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G D           
4.20.10-200.fc29.armv7hl #1
[52329.696959] Hardware name: Allwinner sun7i (A20) Family
[52329.702353] [<c0312804>] (unwind_backtrace) from [<c030cbf0>] 
(show_stack+0x18/0x1c)
[52329.710279] [<c030cbf0>] (show_stack) from [<c0b168c0>] 
(dump_stack+0x80/0xa0)
[52329.717683] [<c0b168c0>] (dump_stack) from [<c0310224>] 
(handle_IPI+0x1ac/0x348)
[52329.725261] [<c0310224>] (handle_IPI) from [<c03025ac>] 
(gic_handle_irq+0x80/0x88)

================================================================================================================================================================

[71815.335299] Unable to handle kernel paging request at virtual address 
2aff6c00
[71815.342612] pgd = d5ce368a
[71815.345421] [2aff6c00] *pgd=00000000
[71815.349118] Internal error: Oops: 805 [#1] SMP ARM
[71815.353927] Modules linked in: xt_recent xt_comment ip_set_hash_net 
ip_set xt_addrtype iptable_nat nf_nat_ipv4 xt_mark i
ptable_mangle xt_CT iptable_raw xt_multiport xt_conntrack nfnetlink_log 
xt_NFLOG nf_log_ipv4 nf_log_common xt_LOG nf_conntrack_sane 
nf_conntrack_netlink nfnetlink nf_nat_tftp nf_nat_snmp_basic 
nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc 
nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_nat nf_conntrack_tftp 
nf_conntrack_sip nf_conntrack_pptp nf_conntrack_proto_gre 
nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc 
nf_conntrack_h323 nf_conntrack_ftp ts_kmp nf_conntrack_amanda 
nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c 8021q garp mrp 
rtl8xxxu arc4 rtl8192cu rtl_usb rtl8192c_common rtlwifi mac80211 
cfg80211 huawei_cdc_ncm cdc_wdm cdc_ncm option usbnet mii usb_wwan 
rfkill b53_mdio b53_common dsa_core bridge stp llc phylink devlink 
sun4i_codec snd_soc_core ac97_bus snd_pcm_dmaengine snd_pcm 
sun4i_backend axp20x_adc axp20x_pek snd_timer snd
[71815.354094]  sun4i_gpadc_iio soundcore sun4i_ts nvmem_sunxi_sid 
sunxi_cir rc_core sunxi_wdt sun4i_drm_hdmi sun4i_ss des_generic 
spi_sun4i sun4i_drm sun4i_frontend sun4i_tcon sun8i_tcon_top 
drm_kms_helper drm fb_sys_fops syscopyarea sysfillrect sysimgblt 
leds_gpio cpufreq_dt axp20x_battery axp20x_ac_power axp20x_usb_power 
industrialio pinctrl_axp209 axp20x_regulator mmc_block dwmac_sunxi 
stmmac_platform stmmac sunxi phy_generic musb_hdrc i2c_mv64xxx 
ahci_sunxi sun4i_gpadc libahci_platform phy_sun4i_usb ehci_platform 
udc_core ohci_platform sunxi_mmc sun4i_dma rtc_ds1307 i2c_dev
[71815.492728] CPU: 0 PID: 29892 Comm: resolvconf Not tainted 
4.20.7-200.fc29.armv7hl #1
[71815.500561] Hardware name: Allwinner sun7i (A20) Family
[71815.505804] PC is at __d_lookup_rcu+0xdc/0x160
[71815.510257] LR is at lookup_fast+0x40/0x298
[71815.514444] pc : [<c0506770>]    lr : [<c04f8f90>]    psr: 60030013
[71815.520713] sp : ec76bd90  ip : 2f62696c  fp : 00000003
[71815.525941] r10: 337c2e6c  r9 : ec76bed8  r8 : eeba1cc0
[71815.531169] r7 : 00000003  r6 : 00320890  r5 : 00000002  r4 : ee32d998
[71815.537699] r3 : 2aff6c00  r2 : ffffffff  r1 : 2f000000  r0 : ee32d9bf
[71815.544231] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  
Segment none
[71815.551368] Control: 10c5387d  Table: 6c4a806a  DAC: 00000051
[71815.557122] Process resolvconf (pid: 29892, stack limit = 0xc1da550f)
[71815.563567] Stack: (0xec76bd90 to 0xec76c000)
[71815.567930] bd80:                                     00000000 
337c2e6c 2aff6c00 ef1bf014
[71815.576117] bda0: 00000001 ec76bed0 ec76bed0 eeba1cc0 ec76be00 
ec76bdf8 ef325f10 ec76bdfc
[71815.584304] bdc0: 7fffffff c04f8f90 ec76bed0 ec76be00 ec76bdf8 
ec76bed0 ec76bed0 00000003
[71815.592490] bde0: 00000000 61c88647 80808080 d0d0d0d0 7fffffff 
c04fb83c ec76bed0 00000003
[71815.600676] be00: 00210080 0000006c 00000000 ec76bed0 ef1bf015 
00000142 61c88647 c04fbb64
[71815.608863] be20: ec63ce40 00020000 e9553a80 c04f8398 ec76bed0 
ec76bed0 ffffe000 ec63ce40
[71815.617054] be40: 00000142 c0301204 ec76a000 00000142 bef482d4 
c04fd6b0 e69a3c00 e69a3c80
[71815.625243] be60: ec76bf74 00020000 ffffe000 ee815990 ef699e00 
00000041 00000000 00000004
[71815.633430] be80: 00000000 0000000f ec76bee8 00000000 00000000 
00000010 00100000 c0b2b9a4
[71815.641616] bea0: ec76bf08 c03705d8 ffffffff 00000001 ec76bf74 
00000001 00000142 c0301204
[71815.649803] bec0: ec76a000 00000142 bef482d4 c04fe394 ef325f10 
eeba1cc0 337c2e6c 00000003
[71815.657990] bee0: ef1bf011 c04d6484 ef325f10 eeba1cc0 c98ed7f0 
00000051 00000002 000012d6
[71815.666176] bf00: 00000000 00000000 00000000 ec76bf10 0806d538 
00000ff0 b6f92ac8 ef1bf010
[71815.674362] bf20: ffffe000 c06b12b0 ef1bf000 00000001 e9a75240 
e9a55b00 000a0000 00000100
[71815.682548] bf40: ef1bf000 00000000 000a0000 00000002 ffffff9c 
00000142 00000001 ffffff9c
[71815.690735] bf60: ef1bf000 c04ec2e0 c120ba74 b6bd9138 ec76bfb0 
00020000 b6ca0000 00000004
[71815.698921] bf80: 00000100 00000001 00000000 004823cd 00000000 
bef4831c 00000142 c0301204
[71815.707108] bfa0: ec76a000 c0301000 004823cd 00000000 ffffff9c 
b6f92ac8 000a0000 00000000
[71815.715294] bfc0: 004823cd 00000000 bef4831c 00000142 00000001 
b6f92ac8 b6f95b08 bef482d4
[71815.723481] bfe0: 00404000 bef48268 b6f6af28 b6f7da0c 20030010 
ffffff9c 00000000 00000000
[71815.731686] [<c0506770>] (__d_lookup_rcu) from [<c04f8f90>] 
(lookup_fast+0x40/0x298)
[71815.739447] [<c04f8f90>] (lookup_fast) from [<c04fb83c>] 
(walk_component+0xc8/0x26c)
[71815.747203] [<c04fb83c>] (walk_component) from [<c04fbb64>] 
(link_path_walk.part.5+0x184/0x444)
[71815.755916] [<c04fbb64>] (link_path_walk.part.5) from [<c04fd6b0>] 
(path_openat+0x2bc/0xf68)
[71815.764366] [<c04fd6b0>] (path_openat) from [<c04fe394>] 
(do_filp_open+0x38/0x84)
[71815.771860] [<c04fe394>] (do_filp_open) from [<c04ec2e0>] 
(do_sys_open+0x100/0x1b0)
[71815.779530] [<c04ec2e0>] (do_sys_open) from [<c0301000>] 
(ret_fast_syscall+0x0/0x54)
[71815.787277] Exception stack(0xec76bfa8 to 0xec76bff0)
[71815.792335] bfa0:                   004823cd 00000000 ffffff9c 
b6f92ac8 000a0000 00000000
[71815.800522] bfc0: 004823cd 00000000 bef4831c 00000142 00000001 
b6f92ac8 b6f95b08 bef482d4
[71815.808704] bfe0: 00404000 bef48268 b6f6af28 b6f7da0c
[71815.813768] Code: e12fff3c e3500000 1a00001c e59d3008 (e5835000)
[71815.820242] ---[ end trace 53e9b1784dbb8ed6 ]---

================================================================================================================================================================

[ 2920.834432] Unable to handle kernel NULL pointer dereference at 
virtual address 000002ad
[ 2920.842633] pgd = 4c7fb172
[ 2920.845421] [000002ad] *pgd=00000000
[ 2920.849099] Internal error: Oops: 5 [#1] SMP ARM
[ 2920.853814] Modules linked in: xt_recent xt_comment ip_set_hash_net 
ip_set xt_addrtype iptable_nat nf_nat_ipv4 xt_mark iptable_mangle xt_CT 
iptable_raw xt_multiport xt_conntrack nfnetlink_log xt_NFLOG nf_log_ipv4 
nf_log_common xt_LOG nf_conntrack_sane nf_conntrack_netlink nfnetlink 
nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp 
nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_nat 
nf_conntrack_tftp nf_conntrack_sip nf_conntrack_pptp 
nf_conntrack_proto_gre nf_conntrack_netbios_ns nf_conntrack_broadcast 
nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp ts_kmp 
nf_conntrack_amanda nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c 
8021q garp mrp rtl8xxxu arc4 rtl8192cu rtl_usb rtl8192c_common rtlwifi 
mac80211 huawei_cdc_ncm cdc_wdm cfg80211 cdc_ncm usbnet option ftdi_sio 
mii usb_wwan rfkill b53_mdio b53_common dsa_core bridge sun4i_codec stp 
llc axp20x_pek snd_soc_core phylink devlink axp20x_adc ac97_bus 
snd_pcm_dmaengine snd_pcm sun4i_backend
[ 2920.854541]  snd_timer sunxi_cir snd sun4i_gpadc_iio rc_core 
soundcore nvmem_sunxi_sid sun4i_ts sun4i_ss sunxi_wdt sun4i_drm_hdmi 
sun4i_drm des_generic sun4i_frontend sun4i_tcon spi_sun4i sun8i_tcon_top 
drm_kms_helper drm fb_sys_fops syscopyarea sysfillrect leds_gpio 
sysimgblt cpufreq_dt axp20x_battery axp20x_ac_power axp20x_usb_power 
industrialio axp20x_regulator pinctrl_axp209 mmc_block dwmac_sunxi 
stmmac_platform sunxi stmmac phy_generic musb_hdrc i2c_mv64xxx 
sun4i_gpadc ahci_sunxi udc_core libahci_platform phy_sun4i_usb sunxi_mmc 
ohci_platform ehci_platform sun4i_dma rtc_ds1307 i2c_dev
[ 2920.994747] CPU: 0 PID: 445 Comm: kworker/0:3 Not tainted 
4.20.10-200.fc29.armv7hl #1
[ 2921.002677] Hardware name: Allwinner sun7i (A20) Family
[ 2921.008022] Workqueue: events dbs_work_handler
[ 2921.012585] PC is at mark_wakeup_next_waiter+0x3c/0xb4
[ 2921.017780] LR is at mark_wakeup_next_waiter+0x30/0xb4
[ 2921.022960] pc : [<c03a0468>]    lr : [<c03a045c>]    psr: 20070093
[ 2921.029267] sp : c9a6bcb8  ip : 00000000  fp : 00000000
[ 2921.034530] r10: 00000023  r9 : 00000023  r8 : 00000000
[ 2921.039797] r7 : c9a6bcd0  r6 : ee7b5cbc  r5 : 00000291  r4 : ffffe000
[ 2921.046365] r3 : 0000a816  r2 : 0000a816  r1 : 00000000  r0 : c9d36e58
[ 2921.052937] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  
Segment none
[ 2921.060210] Control: 10c5387d  Table: 6ab7c06a  DAC: 00000051
[ 2921.066008] Process kworker/0:3 (pid: 445, stack limit = 0x42c75bb1)
[ 2921.072404] Stack: (0xc9a6bcb8 to 0xc9a6c000)
[ 2921.076803] bca0: ee7b5cbc ee7b5cc8
[ 2921.085047] bcc0: 00000001 a0070013 00000000 c0b2e944 00000001 
c9a6bcd0 ee7b5ca8 00000001
[ 2921.093290] bce0: 00000001 c99e3f81 c99e3f81 c090375c 00000002 
00000001 00000001 c09037a8
[ 2921.101535] bd00: c9802400 00000034 00000002 c99e3f80 00000002 
c081c354 c9802e00 c0817cd0
[ 2921.109778] bd20: c9802e00 c0815fc4 c99e3f80 00000001 00000000 
00000023 c9802e00 00000001
[ 2921.118023] bd40: 00000000 c9802e00 00000023 0000003f ffffffff 
000f4240 00155cc0 c0817648
[ 2921.126266] bd60: c9802e00 0000001c 0000003f c9802e00 00000023 
0000003f 0000000c bf14dab0
[ 2921.134508] bd80: ffffffff c0818840 00000000 00000000 0000003f 
c9a6f000 000f4240 0000000c
[ 2921.142752] bda0: 00000001 c078e428 00000000 00000000 00000000 
c078e3e0 c9a6f000 c0789f90
[ 2921.150997] bdc0: 0000000c 00155cc0 000f4240 000f4240 ef034e40 
00000000 c9a6f000 e9ccef80
[ 2921.159240] bde0: 00000000 000f4240 00000000 39387000 00000000 
c078ba10 ef034e40 00155cc0
[ 2921.167486] be00: 00155cc0 39387000 000f4240 000f4240 0632ea00 
e9ccef80 000f4240 000f4240
[ 2921.175730] be20: ef692050 000f4240 000f4240 39387000 e9ccef80 
c078bb38 ebb9b1ac 00000000
[ 2921.183976] be40: e9ccef80 c0957fe8 1298be00 c12bcd08 c986423c 
1298be00 ee639d00 ef692050
[ 2921.192220] be60: 00000000 c9864200 e98467c0 e98467ec ebb9b180 
c0958940 00000000 c9e97f00
[ 2921.200464] be80: ebb9b1ac 1298be00 1298be00 39387000 00000000 
c9e97f00 0004c2c0 00000000
[ 2921.208708] bea0: 00000000 c13bda88 00000000 0004c2c0 00000008 
bf1f10d8 00000001 c9e97f00
[ 2921.216950] bec0: 00000000 c095d334 00000000 00000000 00000002 
000ea600 0004c2c0 00000021
[ 2921.225196] bee0: c9e97f00 e9cce800 003b4480 0043bc00 e9ccec00 
e9cce800 ebb9b6c0 c0960730
[ 2921.233441] bf00: e9cce838 c9e97f00 e9cce804 c1304648 00000000 
e9cce83c 00000000 c0961184
[ 2921.241686] bf20: c981a600 e9cce838 ef699a00 ef69cd00 00000000 
c0369710 c981a600 e9cce838
[ 2921.249931] bf40: c981a600 ef699a00 ef699a00 ffffe000 c1203d00 
ef699a18 c981a614 c036a448
[ 2921.258175] bf60: 00000000 c9a52d80 c9a528c0 c9a6a000 c981a600 
c036a18c 00000000 ef145ee0
[ 2921.266419] bf80: c9a52d9c c036effc 00000109 c9a528c0 c036eec4 
00000000 00000000 00000000
[ 2921.274658] bfa0: 00000000 00000000 00000000 c03010e8 00000000 
00000000 00000000 00000000
[ 2921.282898] bfc0: 00000000 00000000 00000000 00000000 00000000 
00000000 00000000 00000000
[ 2921.291137] bfe0: 00000000 00000000 00000000 00000000 00000013 
00000000 00000000 00000000
[ 2921.299414] [<c03a0468>] (mark_wakeup_next_waiter) from [<c0b2e944>] 
(rt_mutex_unlock+0xd8/0xf4)
[ 2921.308285] [<c0b2e944>] (rt_mutex_unlock) from [<c090375c>] 
(i2c_transfer+0xd0/0xdc)
[ 2921.316193] [<c090375c>] (i2c_transfer) from [<c09037a8>] 
(i2c_transfer_buffer_flags+0x40/0x50)
[ 2921.324974] [<c09037a8>] (i2c_transfer_buffer_flags) from 
[<c081c354>] (regmap_i2c_write+0x1c/0x38)
[ 2921.334100] [<c081c354>] (regmap_i2c_write) from [<c0817cd0>] 
(_regmap_raw_write_impl+0x5ac/0x7b8)
[ 2921.343133] [<c0817cd0>] (_regmap_raw_write_impl) from [<c0817648>] 
(_regmap_update_bits+0xc8/0xcc)
[ 2921.352253] [<c0817648>] (_regmap_update_bits) from [<c0818840>] 
(regmap_update_bits_base+0x54/0x78)
[ 2921.361470] [<c0818840>] (regmap_update_bits_base) from [<c078e428>] 
(regulator_set_voltage_sel_regmap+0x48/0x84)
[ 2921.371818] [<c078e428>] (regulator_set_voltage_sel_regmap) from 
[<c0789f90>] (_regulator_do_set_voltage+0x290/0x428)
[ 2921.382509] [<c0789f90>] (_regulator_do_set_voltage) from 
[<c078ba10>] (regulator_set_voltage_unlocked+0x210/0x304)
[ 2921.393024] [<c078ba10>] (regulator_set_voltage_unlocked) from 
[<c078bb38>] (regulator_set_voltage+0x34/0x48)
[ 2921.403015] [<c078bb38>] (regulator_set_voltage) from [<c0957fe8>] 
(_set_opp_voltage+0x74/0x108)
[ 2921.411873] [<c0957fe8>] (_set_opp_voltage) from [<c0958940>] 
(dev_pm_opp_set_rate+0x398/0x48c)
[ 2921.420667] [<c0958940>] (dev_pm_opp_set_rate) from [<bf1f10d8>] 
(set_target+0x34/0x54 [cpufreq_dt])
[ 2921.429922] [<bf1f10d8>] (set_target [cpufreq_dt]) from [<c095d334>] 
(__cpufreq_driver_target+0x444/0x510)
[ 2921.439663] [<c095d334>] (__cpufreq_driver_target) from [<c0960730>] 
(od_dbs_update+0xd4/0x160)
[ 2921.448436] [<c0960730>] (od_dbs_update) from [<c0961184>] 
(dbs_work_handler+0x30/0x5c)
[ 2921.456512] [<c0961184>] (dbs_work_handler) from [<c0369710>] 
(process_one_work+0x23c/0x41c)
[ 2921.465023] [<c0369710>] (process_one_work) from [<c036a448>] 
(worker_thread+0x2bc/0x43c)
[ 2921.473273] [<c036a448>] (worker_thread) from [<c036effc>] 
(kthread+0x138/0x150)
[ 2921.480740] [<c036effc>] (kthread) from [<c03010e8>] 
(ret_from_fork+0x14/0x2c)
[ 2921.488013] Exception stack(0xc9a6bfb0 to 0xc9a6bff8)
[ 2921.493109] bfa0:                                     00000000 
00000000 00000000 00000000
[ 2921.501348] bfc0: 00000000 00000000 00000000 00000000 00000000 
00000000 00000000 00000000
[ 2921.509583] bfe0: 00000000 00000000 00000000 00000000 00000013 00000000
[ 2921.516256] Code: eb1e4048 e5965008 e3550000 0a000003 (e595301c)
[ 2921.522400] ---[ end trace d77f7ba410481ae8 ]---

