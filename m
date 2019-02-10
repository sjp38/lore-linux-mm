Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DEAR_SOMETHING,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 013B3C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 11:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0645920863
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 11:09:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=interia.pl header.i=@interia.pl header.b="mwcyC5Ej"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0645920863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=interia.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50F898E00BA; Sun, 10 Feb 2019 06:09:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4964D8E00B5; Sun, 10 Feb 2019 06:09:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 337108E00BA; Sun, 10 Feb 2019 06:09:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id AABEE8E00B5
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 06:09:14 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k16-v6so2182461lji.5
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 03:09:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:to:cc:subject:from:message-id:date:user-agent
         :mime-version:content-language:dkim-signature;
        bh=p4qE1lxsnSdIGxqRlU0EPPkdDSe8IZ/w/KhYo5bMCgk=;
        b=Ni4cVpPm8YuZ1MNN9s6KqjSI7fvNWI03i2c0Q0a4nwNL8Nfv2YYXLeImau54KW6ngr
         uJJRo3PoaT/gYeL4gg+N0G4iCgEX9SChyZzelBNX/dSZCAOIHJZCH9aHIZf7qbIZznne
         SJRiTvl868w6PZBed60nylzArpTj5GKRagXEI5is5u9ldECvMh5jITXScGldKYtif+ks
         sdYFw6ZCiNW7GtFQe4dESPVLemxKbYV8+ygwAGmaAFX0jzXXrPMmh1kjHOc1KV9nT8yj
         s+U0lWOvb2brpDwlZYoe0e7k/bPs+eCv9w7dTruFc0coK6A9FKCt3HVM3SBVQAKEt5dd
         f8uA==
X-Gm-Message-State: AHQUAuakA35XGWi9trUCGg7wRVLJ/7tfzkogXgtYzDr6I/KAy1twxNyi
	Nh2emtQdwIMqYV+LaA9xMUWsCmBOMqQ/t03X5srQW1IZCHz6c7LeLYz7d+BmfxUo70xzbN8TFW2
	R6+hFtHyMFLewV4rbnkaX5xv8JQ/mVYHIl7RLVhH+8JmE+MIaAB3HASUWdM4TzTuOjw==
X-Received: by 2002:a19:f814:: with SMTP id a20mr7581143lff.138.1549796953968;
        Sun, 10 Feb 2019 03:09:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbM/P94Kv4WQrKnX6TsOJ1gHbwambGLzukKWEUsWFAxNuCrNGwz2YbnFrTzzZe4NHxGEoPC
X-Received: by 2002:a19:f814:: with SMTP id a20mr7581108lff.138.1549796953104;
        Sun, 10 Feb 2019 03:09:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549796953; cv=none;
        d=google.com; s=arc-20160816;
        b=UxI/y9xwpAQ3JA4+ExeElIvEnAWZmbW1tntrbwThafgW8GHw29DlxCyOeoePLr6SIy
         uUPLDVzqtnvIroFY8olmnkHysAoS6trbIewjWfP+68v36gUiwo8aDul6vEK2YcqhMQGN
         +xfJsGGJJE9VJvU1cEdmchlqgHiH2lWVejx83+WCmhWorOFCLY6jpQsmYOjYQzzn2LG/
         QlB9FPZk+vRLMxYJRgjtz623iCBxikiSpHl0qBEgBlhTzP0a2ToQ7EjfkumykKqbFVG5
         okGB3ghpfP5DVOUDsmUIeJQu98yUtEHwvPht2lBY0JX94NizaDQMMt4QMbdnLOEuoX/i
         aSjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-language:mime-version:user-agent:date
         :message-id:from:subject:cc:to;
        bh=p4qE1lxsnSdIGxqRlU0EPPkdDSe8IZ/w/KhYo5bMCgk=;
        b=cIL6v/SSHiYVXHRsjhPpfFglK9hJjupn0sdsKZoBolO16MlKmj9hFxH+94aYqcfnqy
         2hm1UjXQ6LPsFDG99RZY8kregE0fxv1X61D7bW+BzDwFgmF2h7nVoWKDJ/ffW1cJVSGR
         /BHo1E0yXBxNOcB1Fv323ABP9/MALl/05GrJ2dMZ0nlWq57RcZJyhcu4j3OOE22yGv01
         f4eT6PjfkKb8vGGXKVkm9peBz4qY2yDg1rILlIdNL28+/p42MYefcNjhC968i6isRBzl
         V14lHP4j54K0qM28pqKvqNxQUdnJDNG8D7FC6GszmU5FlbQ9qqNB1CIbpuZzBFUFFekV
         uapg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@interia.pl header.s=biztos header.b=mwcyC5Ej;
       spf=pass (google.com: domain of kfgz@interia.pl designates 217.74.65.156 as permitted sender) smtp.mailfrom=kfgz@interia.pl
Received: from smtpo.poczta.interia.pl (smtpo.poczta.interia.pl. [217.74.65.156])
        by mx.google.com with ESMTPS id o1si6296472lfl.114.2019.02.10.03.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Feb 2019 03:09:13 -0800 (PST)
Received-SPF: pass (google.com: domain of kfgz@interia.pl designates 217.74.65.156 as permitted sender) client-ip=217.74.65.156;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@interia.pl header.s=biztos header.b=mwcyC5Ej;
       spf=pass (google.com: domain of kfgz@interia.pl designates 217.74.65.156 as permitted sender) smtp.mailfrom=kfgz@interia.pl
X-Interia-R: Interia
X-Interia-R-IP: 109.231.53.78
X-Interia-R-Helo: <[192.168.1.2]>
Received: from [192.168.1.2] (unknown [109.231.53.78])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by poczta.interia.pl (INTERIA.PL) with ESMTPSA;
	Sun, 10 Feb 2019 12:09:10 +0100 (CET)
To: dan.j.williams@intel.com
Cc: akpm@linux-foundation.org, dri-devel@lists.freedesktop.org, hch@lst.de,
 jglisse@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 logang@deltatee.com, stable@vger.kernel.org, torvalds@linux-foundation.org
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
From: Krzysztof Grygiencz <kfgz@interia.pl>
Message-ID: <30d86b36-8421-f899-205e-4b9c6a5fcc9d@interia.pl>
Date: Sun, 10 Feb 2019 12:09:08 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------2A9A357F73A2C91AEDD30CF0"
Content-Language: pl-PL
X-Interia-Antivirus: OK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=interia.pl;
	s=biztos; t=1549796952;
	bh=p4qE1lxsnSdIGxqRlU0EPPkdDSe8IZ/w/KhYo5bMCgk=;
	h=X-Interia-R:X-Interia-R-IP:X-Interia-R-Helo:To:Cc:Subject:From:
	 Message-ID:Date:User-Agent:MIME-Version:Content-Type:
	 Content-Language:X-Interia-Antivirus;
	b=mwcyC5EjvMpjKR8lvf7y2D0XnkbiKIMmDQfKCvfrhiknOHSZNk9eMg4ec7NDP5U+M
	 UcNO+C8JUfAGOpQDJ9BvLkQRspaIrR5l+3A4q4RsepbyyCevk2tM7GL5N3RtIjHRIC
	 ScRUA0N4NSNsdlgsVYslweN96Odn7FcN2D1+FdZo=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------2A9A357F73A2C91AEDD30CF0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Dear Sir,

I'm using ArchLinux distribution. After kernel upgrade form 4.19.14 to 
4.19.15 my X environment stopped working. I have AMD HD3300 (RS780D) 
graphics card. I have bisected kernel and found a failing commit:

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=v4.19.20&id=ec5471c92fb29ad848c81875840478be201eeb3f

I'm attaching Xorg.0.log file

Best Regards
Krzysztof Grygiencz

--------------2A9A357F73A2C91AEDD30CF0
Content-Type: text/x-log;
 name="Xorg.0.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="Xorg.0.log"

[    22.027] 
X.Org X Server 1.20.3
X Protocol Version 11, Revision 0
[    22.027] Build Operating System: Linux Arch Linux
[    22.027] Current Operating System: Linux h4xxx 4.19.15-1-lts #1 SMP Sun Jan 13 13:53:52 CET 2019 x86_64
[    22.027] Kernel command line: BOOT_IMAGE=../vmlinuz-linux-lts root=UUID=a6e22cbe-f0cd-4efc-b9c2-c9fe90e829d3 rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vt.global_cursor_default=0 net.ifnames=0 initrd=../initramfs-linux-lts.img
[    22.027] Build Date: 25 October 2018  04:42:32PM
[    22.027]  
[    22.027] Current version of pixman: 0.36.0
[    22.027] 	Before reporting problems, check http://wiki.x.org
	to make sure that you have the latest version.
[    22.027] Markers: (--) probed, (**) from config file, (==) default setting,
	(++) from command line, (!!) notice, (II) informational,
	(WW) warning, (EE) error, (NI) not implemented, (??) unknown.
[    22.027] (==) Log file: "/var/log/Xorg.0.log", Time: Tue Jan 15 17:37:23 2019
[    22.027] (==) Using config directory: "/etc/X11/xorg.conf.d"
[    22.027] (==) Using system config directory "/usr/share/X11/xorg.conf.d"
[    22.028] (==) No Layout section.  Using the first Screen section.
[    22.028] (==) No screen section available. Using defaults.
[    22.028] (**) |-->Screen "Default Screen Section" (0)
[    22.028] (**) |   |-->Monitor "<default monitor>"
[    22.028] (==) No monitor specified for screen "Default Screen Section".
	Using a default monitor configuration.
[    22.028] (==) Automatically adding devices
[    22.028] (==) Automatically enabling devices
[    22.028] (==) Automatically adding GPU devices
[    22.028] (==) Automatically binding GPU devices
[    22.028] (==) Max clients allowed: 256, resource mask: 0x1fffff
[    22.028] (==) FontPath set to:
	/usr/share/fonts/misc,
	/usr/share/fonts/TTF,
	/usr/share/fonts/OTF,
	/usr/share/fonts/Type1,
	/usr/share/fonts/100dpi,
	/usr/share/fonts/75dpi
[    22.028] (==) ModulePath set to "/usr/lib/xorg/modules"
[    22.028] (II) The server relies on udev to provide the list of input devices.
	If no devices become available, reconfigure udev or disable AutoAddDevices.
[    22.028] (II) Module ABI versions:
[    22.028] 	X.Org ANSI C Emulation: 0.4
[    22.028] 	X.Org Video Driver: 24.0
[    22.028] 	X.Org XInput driver : 24.1
[    22.028] 	X.Org Server Extension : 10.0
[    22.029] (++) using VT number 7

[    22.029] (II) systemd-logind: logind integration requires -keeptty and -keeptty was not provided, disabling logind integration
[    22.031] (--) PCI:*(1@0:5:0) 1002:9614:1043:834d rev 0, Mem @ 0xd0000000/268435456, 0xfe0f0000/65536, 0xfdf00000/1048576, I/O @ 0x0000c000/256, BIOS @ 0x????????/131072
[    22.032] (II) Open ACPI successful (/var/run/acpid.socket)
[    22.032] (II) LoadModule: "glx"
[    22.032] (II) Loading /usr/lib/xorg/modules/extensions/libglx.so
[    22.034] (II) Module glx: vendor="X.Org Foundation"
[    22.034] 	compiled for 1.20.3, module version = 1.0.0
[    22.034] 	ABI class: X.Org Server Extension, version 10.0
[    22.034] (==) Matched ati as autoconfigured driver 0
[    22.034] (==) Matched modesetting as autoconfigured driver 1
[    22.034] (==) Matched fbdev as autoconfigured driver 2
[    22.034] (==) Matched vesa as autoconfigured driver 3
[    22.034] (==) Assigned the driver to the xf86ConfigLayout
[    22.034] (II) LoadModule: "ati"
[    22.034] (II) Loading /usr/lib/xorg/modules/drivers/ati_drv.so
[    22.034] (II) Module ati: vendor="X.Org Foundation"
[    22.034] 	compiled for 1.20.1, module version = 18.1.0
[    22.034] 	Module class: X.Org Video Driver
[    22.034] 	ABI class: X.Org Video Driver, version 24.0
[    22.034] (II) LoadModule: "radeon"
[    22.034] (II) Loading /usr/lib/xorg/modules/drivers/radeon_drv.so
[    22.035] (II) Module radeon: vendor="X.Org Foundation"
[    22.035] 	compiled for 1.20.1, module version = 18.1.0
[    22.035] 	Module class: X.Org Video Driver
[    22.035] 	ABI class: X.Org Video Driver, version 24.0
[    22.035] (II) LoadModule: "modesetting"
[    22.035] (II) Loading /usr/lib/xorg/modules/drivers/modesetting_drv.so
[    22.035] (II) Module modesetting: vendor="X.Org Foundation"
[    22.035] 	compiled for 1.20.3, module version = 1.20.3
[    22.035] 	Module class: X.Org Video Driver
[    22.035] 	ABI class: X.Org Video Driver, version 24.0
[    22.035] (II) LoadModule: "fbdev"
[    22.035] (WW) Warning, couldn't open module fbdev
[    22.035] (EE) Failed to load module "fbdev" (module does not exist, 0)
[    22.035] (II) LoadModule: "vesa"
[    22.035] (WW) Warning, couldn't open module vesa
[    22.035] (EE) Failed to load module "vesa" (module does not exist, 0)
[    22.035] (II) RADEON: Driver for ATI/AMD Radeon chipsets:
	ATI Radeon Mobility X600 (M24), ATI FireMV 2400,
	ATI Radeon Mobility X300 (M24), ATI FireGL M24 GL,
	ATI Radeon X600 (RV380), ATI FireGL V3200 (RV380),
	ATI Radeon IGP320 (A3), ATI Radeon IGP330/340/350 (A4),
	ATI Radeon 9500, ATI Radeon 9600TX, ATI FireGL Z1, ATI Radeon 9800SE,
	ATI Radeon 9800, ATI FireGL X2, ATI Radeon 9600, ATI Radeon 9600SE,
	ATI Radeon 9600XT, ATI FireGL T2, ATI Radeon 9650, ATI FireGL RV360,
	ATI Radeon 7000 IGP (A4+), ATI Radeon 8500 AIW,
	ATI Radeon IGP320M (U1), ATI Radeon IGP330M/340M/350M (U2),
	ATI Radeon Mobility 7000 IGP, ATI Radeon 9000/PRO, ATI Radeon 9000,
	ATI Radeon X800 (R420), ATI Radeon X800PRO (R420),
	ATI Radeon X800SE (R420), ATI FireGL X3 (R420),
	ATI Radeon Mobility 9800 (M18), ATI Radeon X800 SE (R420),
	ATI Radeon X800XT (R420), ATI Radeon X800 VE (R420),
	ATI Radeon X850 (R480), ATI Radeon X850 XT (R480),
	ATI Radeon X850 SE (R480), ATI Radeon X850 PRO (R480),
	ATI Radeon X850 XT PE (R480), ATI Radeon Mobility M7,
	ATI Mobility FireGL 7800 M7, ATI Radeon Mobility M6,
	ATI FireGL Mobility 9000 (M9), ATI Radeon Mobility 9000 (M9),
	ATI Radeon 9700 Pro, ATI Radeon 9700/9500Pro, ATI FireGL X1,
	ATI Radeon 9800PRO, ATI Radeon 9800XT,
	ATI Radeon Mobility 9600/9700 (M10/M11),
	ATI Radeon Mobility 9600 (M10), ATI Radeon Mobility 9600 (M11),
	ATI FireGL Mobility T2 (M10), ATI FireGL Mobility T2e (M11),
	ATI Radeon, ATI FireGL 8700/8800, ATI Radeon 8500, ATI Radeon 9100,
	ATI Radeon 7500, ATI Radeon VE/7000, ATI ES1000,
	ATI Radeon Mobility X300 (M22), ATI Radeon Mobility X600 SE (M24C),
	ATI FireGL M22 GL, ATI Radeon X800 (R423), ATI Radeon X800PRO (R423),
	ATI Radeon X800LE (R423), ATI Radeon X800SE (R423),
	ATI Radeon X800 XTP (R430), ATI Radeon X800 XL (R430),
	ATI Radeon X800 SE (R430), ATI Radeon X800 (R430),
	ATI FireGL V7100 (R423), ATI FireGL V5100 (R423),
	ATI FireGL unknown (R423), ATI Mobility FireGL V5000 (M26),
	ATI Mobility Radeon X700 XL (M26), ATI Mobility Radeon X700 (M26),
	ATI Radeon X550XTX, ATI Radeon 9100 IGP (A5),
	ATI Radeon Mobility 9100 IGP (U3), ATI Radeon XPRESS 200,
	ATI Radeon XPRESS 200M, ATI Radeon 9250, ATI Radeon 9200,
	ATI Radeon 9200SE, ATI FireMV 2200, ATI Radeon X300 (RV370),
	ATI Radeon X600 (RV370), ATI Radeon X550 (RV370),
	ATI FireGL V3100 (RV370), ATI FireMV 2200 PCIE (RV370),
	ATI Radeon Mobility 9200 (M9+), ATI Mobility Radeon X800 XT (M28),
	ATI Mobility FireGL V5100 (M28), ATI Mobility Radeon X800 (M28),
	ATI Radeon X850, ATI unknown Radeon / FireGL (R480),
	ATI Radeon X800XT (R423), ATI FireGL V5000 (RV410),
	ATI Radeon X700 XT (RV410), ATI Radeon X700 PRO (RV410),
	ATI Radeon X700 SE (RV410), ATI Radeon X700 (RV410),
	ATI Radeon X1800, ATI Mobility Radeon X1800 XT,
	ATI Mobility Radeon X1800, ATI Mobility FireGL V7200,
	ATI FireGL V7200, ATI FireGL V5300, ATI Mobility FireGL V7100,
	ATI FireGL V7300, ATI FireGL V7350, ATI Radeon X1600, ATI RV505,
	ATI Radeon X1300/X1550, ATI Radeon X1550, ATI M54-GL,
	ATI Mobility Radeon X1400, ATI Radeon X1550 64-bit,
	ATI Mobility Radeon X1300, ATI Radeon X1300, ATI FireGL V3300,
	ATI FireGL V3350, ATI Mobility Radeon X1450,
	ATI Mobility Radeon X2300, ATI Mobility Radeon X1350,
	ATI FireMV 2250, ATI Radeon X1650, ATI Mobility FireGL V5200,
	ATI Mobility Radeon X1600, ATI Radeon X1300 XT/X1600 Pro,
	ATI FireGL V3400, ATI Mobility FireGL V5250,
	ATI Mobility Radeon X1700, ATI Mobility Radeon X1700 XT,
	ATI FireGL V5200, ATI Radeon X2300HD, ATI Mobility Radeon HD 2300,
	ATI Radeon X1950, ATI Radeon X1900, ATI AMD Stream Processor,
	ATI RV560, ATI Mobility Radeon X1900, ATI Radeon X1950 GT, ATI RV570,
	ATI FireGL V7400, ATI Radeon 9100 PRO IGP,
	ATI Radeon Mobility 9200 IGP, ATI Radeon X1200, ATI RS740,
	ATI RS740M, ATI Radeon HD 2900 XT, ATI Radeon HD 2900 Pro,
	ATI Radeon HD 2900 GT, ATI FireGL V8650, ATI FireGL V8600,
	ATI FireGL V7600, ATI Radeon 4800 Series, ATI Radeon HD 4870 x2,
	ATI Radeon HD 4850 x2, ATI FirePro V8750 (FireGL),
	ATI FirePro V7760 (FireGL), ATI Mobility RADEON HD 4850,
	ATI Mobility RADEON HD 4850 X2, ATI FirePro RV770,
	AMD FireStream 9270, AMD FireStream 9250, ATI FirePro V8700 (FireGL),
	ATI Mobility RADEON HD 4870, ATI Mobility RADEON M98,
	ATI FirePro M7750, ATI M98, ATI Mobility Radeon HD 4650,
	ATI Radeon RV730 (AGP), ATI Mobility Radeon HD 4670,
	ATI FirePro M5750, ATI RV730XT [Radeon HD 4670], ATI RADEON E4600,
	ATI Radeon HD 4600 Series, ATI RV730 PRO [Radeon HD 4650],
	ATI FirePro V7750 (FireGL), ATI FirePro V5700 (FireGL),
	ATI FirePro V3750 (FireGL), ATI Mobility Radeon HD 4830,
	ATI Mobility Radeon HD 4850, ATI FirePro M7740, ATI RV740,
	ATI Radeon HD 4770, ATI Radeon HD 4700 Series, ATI RV610,
	ATI Radeon HD 2400 XT, ATI Radeon HD 2400 Pro,
	ATI Radeon HD 2400 PRO AGP, ATI FireGL V4000, ATI Radeon HD 2350,
	ATI Mobility Radeon HD 2400 XT, ATI Mobility Radeon HD 2400,
	ATI RADEON E2400, ATI FireMV 2260, ATI RV670, ATI Radeon HD3870,
	ATI Mobility Radeon HD 3850, ATI Radeon HD3850,
	ATI Mobility Radeon HD 3850 X2, ATI Mobility Radeon HD 3870,
	ATI Mobility Radeon HD 3870 X2, ATI Radeon HD3870 X2,
	ATI FireGL V7700, ATI Radeon HD3690, AMD Firestream 9170,
	ATI Radeon HD 4550, ATI Radeon RV710, ATI Radeon HD 4350,
	ATI Mobility Radeon 4300 Series, ATI Mobility Radeon 4500 Series,
	ATI FirePro RG220, ATI Mobility Radeon 4330, ATI RV630,
	ATI Mobility Radeon HD 2600, ATI Mobility Radeon HD 2600 XT,
	ATI Radeon HD 2600 XT AGP, ATI Radeon HD 2600 Pro AGP,
	ATI Radeon HD 2600 XT, ATI Radeon HD 2600 Pro, ATI Gemini RV630,
	ATI Gemini Mobility Radeon HD 2600 XT, ATI FireGL V5600,
	ATI FireGL V3600, ATI Radeon HD 2600 LE,
	ATI Mobility FireGL Graphics Processor, ATI Radeon HD 3470,
	ATI Mobility Radeon HD 3430, ATI Mobility Radeon HD 3400 Series,
	ATI Radeon HD 3450, ATI Radeon HD 3430, ATI FirePro V3700,
	ATI FireMV 2450, ATI Radeon HD 3600 Series, ATI Radeon HD 3650 AGP,
	ATI Radeon HD 3600 PRO, ATI Radeon HD 3600 XT,
	ATI Mobility Radeon HD 3650, ATI Mobility Radeon HD 3670,
	ATI Mobility FireGL V5700, ATI Mobility FireGL V5725,
	ATI Radeon HD 3200 Graphics, ATI Radeon 3100 Graphics,
	ATI Radeon HD 3300 Graphics, ATI Radeon 3000 Graphics, SUMO, SUMO2,
	ATI Radeon HD 4200, ATI Radeon 4100, ATI Mobility Radeon HD 4200,
	ATI Mobility Radeon 4100, ATI Radeon HD 4290, ATI Radeon HD 4250,
	AMD Radeon HD 6310 Graphics, AMD Radeon HD 6250 Graphics,
	AMD Radeon HD 6300 Series Graphics,
	AMD Radeon HD 6200 Series Graphics, PALM, CYPRESS,
	ATI FirePro (FireGL) Graphics Adapter, AMD Firestream 9370,
	AMD Firestream 9350, ATI Radeon HD 5800 Series,
	ATI Radeon HD 5900 Series, ATI Mobility Radeon HD 5800 Series,
	ATI Radeon HD 5700 Series, ATI Radeon HD 6700 Series,
	ATI Mobility Radeon HD 5000 Series, ATI Mobility Radeon HD 5570,
	ATI Radeon HD 5670, ATI Radeon HD 5570, ATI Radeon HD 5500 Series,
	REDWOOD, ATI Mobility Radeon Graphics, CEDAR, ATI FirePro 2270,
	ATI Radeon HD 5450, CAYMAN, AMD Radeon HD 6900 Series,
	AMD Radeon HD 6900M Series, Mobility Radeon HD 6000 Series, BARTS,
	AMD Radeon HD 6800 Series, AMD Radeon HD 6700 Series, TURKS, CAICOS,
	ARUBA, TAHITI, PITCAIRN, VERDE, OLAND, HAINAN, BONAIRE, KABINI,
	MULLINS, KAVERI, HAWAII
[    22.037] (II) modesetting: Driver for Modesetting Kernel Drivers: kms
[    22.038] (II) [KMS] drm report modesetting isn't supported.
[    22.038] (EE) open /dev/dri/card0: No such file or directory
[    22.038] (WW) Falling back to old probe method for modesetting
[    22.038] (EE) open /dev/dri/card0: No such file or directory
[    22.038] (EE) Screen 0 deleted because of no matching config section.
[    22.038] (II) UnloadModule: "radeon"
[    22.038] (EE) Screen 0 deleted because of no matching config section.
[    22.038] (II) UnloadModule: "modesetting"
[    22.038] (EE) Device(s) detected, but none match those in the config file.
[    22.038] (EE) 
Fatal server error:
[    22.038] (EE) no screens found(EE) 
[    22.038] (EE) 
Please consult the The X.Org Foundation support 
	 at http://wiki.x.org
 for help. 
[    22.038] (EE) Please also check the log file at "/var/log/Xorg.0.log" for additional information.
[    22.038] (EE) 
[    22.038] (EE) Server terminated with error (1). Closing log file.

--------------2A9A357F73A2C91AEDD30CF0--

