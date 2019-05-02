Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0A69C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:44:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F8D2063F
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:44:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="FzpJluqE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F8D2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F68A6B0003; Thu,  2 May 2019 17:44:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A6826B0005; Thu,  2 May 2019 17:44:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0F86B0007; Thu,  2 May 2019 17:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD1A6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 17:44:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r8so1741061edd.21
        for <linux-mm@kvack.org>; Thu, 02 May 2019 14:44:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5M1sYxztvRbU0Fa/m7JfJ32dW4ShTmR9C1tXAmSl9NA=;
        b=QcOwm72hIlhlWIEm36BzIQSZvkdzf338tY1zu8dt8fG6W9Xj0A6rkGDy9mhQf1NVMo
         XaUD/uuTxJSqzhvtXebaU54ONcql6ww9+0QIgRF+i3xRoXtOJBxhHcvitKUGHkfdWhU4
         01lM0LPTlnLga2GnUG4+R9oDlIazlCPVbBQcGtWVXS2JZmU9FwfZnNHaEYESJ1eVE7Bk
         So282UTqtZx3crvOL3Z7UwAdXSs86S3Il86sIXgIB0P8sJBArwxKItY8X0UC1WavogWU
         ku+JNF5ypYHqqMw1IOhSf5/HKdSgF7EaDtgHmwZhRJZxOWDnSi05cyXVwmcKs3hWEigD
         aeMw==
X-Gm-Message-State: APjAAAXIKAwnbcElgLGEp+s1q13KkTFxYw8f/OtLUQK4hDTxamW1nIdy
	6oQKt/joaNOWy/ywNnigwo6OK/qxvwfo1t2wDkMcdosV0xrwhcpIL3zlsB7bFxaIMNs30fztQ1K
	4YzMcmqlk/GRdEQywA42vVIHrSGFhcy01RXJhScSAJycYMUxGtWba1qwc+sWcz8kuIw==
X-Received: by 2002:a17:906:1856:: with SMTP id w22mr2026736eje.130.1556833456140;
        Thu, 02 May 2019 14:44:16 -0700 (PDT)
X-Received: by 2002:a17:906:1856:: with SMTP id w22mr2026686eje.130.1556833454865;
        Thu, 02 May 2019 14:44:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556833454; cv=none;
        d=google.com; s=arc-20160816;
        b=eI7L0a5QP3NnvUWALiV6073y6ujtbIelPWI359pEs/+ks475lyTlc8wVyCuy67OS9V
         QWxlBOSFhECMCGCq9LPV6tJKs5ovIrbyfcSMvB7w9u32pgpdz5NVufatfrB+cjr7bmns
         dBRI7nQUCvjFNlulmMkBiJoyr4CKUWxTs5hTAd+w8cDmPoVOhnqnGDs7vcrOIRAvFnVF
         NIClhAjR18RU3ou+K0AR7Dw1L8VA3g7qnEKWL3BVA66+RJwuUHj4m4yJifHTbbxPVEFg
         YCTOpWy1E+RXF0KPrDU/YYIwtALTdHR4RgijOFlnu9eVWkfXbgUyQlXoZ6OtnELWoBhp
         i6qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5M1sYxztvRbU0Fa/m7JfJ32dW4ShTmR9C1tXAmSl9NA=;
        b=vkrI3WGyLoKdMTMbUUpPeM5QUjrM+V3ehxv+FEpo4XaKiAciJvViLUIHlQR0qkfoKf
         TVk8OEq7iYTSzs7dSM+aVeeVzh2xFua92PtEzWXG/1xg7PXhaqLj/iS4iMY2OGWDifYB
         7GkFf4EuYritv6wONoIgkyKAX+yXaSMcoiyQ2v7hm4EU5xtnpZAAcIV9q+hTiX63iE9+
         xDeRi2oGFkwpIQmHK3RwvhRIlW9kTR3TJoSh5VXoP0yAejzpnVoOFAL8U0/bZdEBV7qi
         pnHBsOH1PQe2hDPlvvSmVfI2jn+KzvGqsvDRg8uT0otcokOXjsSHow1a8xudjM8pRYzY
         Hejg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FzpJluqE;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor105478ejp.25.2019.05.02.14.44.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 14:44:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FzpJluqE;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5M1sYxztvRbU0Fa/m7JfJ32dW4ShTmR9C1tXAmSl9NA=;
        b=FzpJluqE8MT8R7KzNDAA+VV7d4aWPXZhrp3K5YMAXZxxiZZ6fYFQ5zbU9NlBDKECes
         MWoiTAJCs+7sPBWpT1Rxuulv9jtTZbDJGiBhMB7lIm6G/KUczLlvveUmM1iPdFLYeexo
         IOU4qqWXmVSzD9ZxD+gW+iKULcqVfkEcBUjS1B6sC9kGbtPt2Dab6QVlZx8mt4g0/qoG
         5ZD1c338yDDUyweXNUvUG4S43Li/Iw+oLV96NwbU0qECbgkMP9TnBxdProYtCNL6jC2L
         wFl5cC1a9xlr4P4DDQ1D/fDnH1qxAIAIpw55J72hMWqnXG0jkAiGeOI9jNLyRjpObojc
         Im2g==
X-Google-Smtp-Source: APXvYqxeJH8VqaVL7Zjd6Rvf5LMww1Pe4MoQbjo+ebA5qkSTSmTih8DDTnyUTRRZHQUWg7xIsCSI2MUju1UEOzGkYxY=
X-Received: by 2002:a17:906:3fca:: with SMTP id k10mr3124739ejj.126.1556833454254;
 Thu, 02 May 2019 14:44:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com> <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
In-Reply-To: <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 17:44:03 -0400
Message-ID: <CA+CK2bA=E4zRFb0Qky=baOQi_LF4x4eu8KVdEkhPJo3wWr8dYQ@mail.gmail.com>
Subject: Re: [v5 0/3] "Hotremove" persistent memory
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "Williams, Dan J" <dan.j.williams@intel.com>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, 
	"Jiang, Dave" <dave.jiang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, 
	"Busch, Keith" <keith.busch@intel.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 4:50 PM Verma, Vishal L <vishal.l.verma@intel.com> wrote:
>
> On Thu, 2019-05-02 at 14:43 -0400, Pavel Tatashin wrote:
> > The series of operations look like this:
> >
> > 1. After boot restore /dev/pmem0 to ramdisk to be consumed by apps.
> >    and free ramdisk.
> > 2. Convert raw pmem0 to devdax
> >    ndctl create-namespace --mode devdax --map mem -e namespace0.0 -f
> > 3. Hotadd to System RAM
> >    echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> >    echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> >    echo online_movable > /sys/devices/system/memoryXXX/state
> > 4. Before reboot hotremove device-dax memory from System RAM
> >    echo offline > /sys/devices/system/memoryXXX/state
> >    echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
>
> Hi Pavel,
>
> I am working on adding this sort of a workflow into a new daxctl command
> (daxctl-reconfigure-device)- this will allow changing the 'mode' of a
> dax device to kmem, online the resulting memory, and with your patches,
> also attempt to offline the memory, and change back to device-dax.
>
> In running with these patches, and testing the offlining part, I ran
> into the following lockdep below.
>
> This is with just these three patches on top of -rc7.

Hi Verma,

Thank you for testing. I wonder if there is a command sequence that I
could run to reproduce it?
Also, could you please send your config and qemu arguments.

Thank you,
Pasha

>
>
> [  +0.004886] ======================================================
> [  +0.001576] WARNING: possible circular locking dependency detected
> [  +0.001506] 5.1.0-rc7+ #13 Tainted: G           O
> [  +0.000929] ------------------------------------------------------
> [  +0.000708] daxctl/22950 is trying to acquire lock:
> [  +0.000548] 00000000f4d397f7 (kn->count#424){++++}, at: kernfs_remove_by_name_ns+0x40/0x80
> [  +0.000922]
>               but task is already holding lock:
> [  +0.000657] 000000002aa52a9f (mem_sysfs_mutex){+.+.}, at: unregister_memory_section+0x22/0xa0
> [  +0.000960]
>               which lock already depends on the new lock.
>
> [  +0.001001]
>               the existing dependency chain (in reverse order) is:
> [  +0.000837]
>               -> #3 (mem_sysfs_mutex){+.+.}:
> [  +0.000631]        __mutex_lock+0x82/0x9a0
> [  +0.000477]        unregister_memory_section+0x22/0xa0
> [  +0.000582]        __remove_pages+0xe9/0x520
> [  +0.000489]        arch_remove_memory+0x81/0xc0
> [  +0.000510]        devm_memremap_pages_release+0x180/0x270
> [  +0.000633]        release_nodes+0x234/0x280
> [  +0.000483]        device_release_driver_internal+0xf4/0x1d0
> [  +0.000701]        bus_remove_device+0xfc/0x170
> [  +0.000529]        device_del+0x16a/0x380
> [  +0.000459]        unregister_dev_dax+0x23/0x50
> [  +0.000526]        release_nodes+0x234/0x280
> [  +0.000487]        device_release_driver_internal+0xf4/0x1d0
> [  +0.000646]        unbind_store+0x9b/0x130
> [  +0.000467]        kernfs_fop_write+0xf0/0x1a0
> [  +0.000510]        vfs_write+0xba/0x1c0
> [  +0.000438]        ksys_write+0x5a/0xe0
> [  +0.000521]        do_syscall_64+0x60/0x210
> [  +0.000489]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  +0.000637]
>               -> #2 (mem_hotplug_lock.rw_sem){++++}:
> [  +0.000717]        get_online_mems+0x3e/0x80
> [  +0.000491]        kmem_cache_create_usercopy+0x2e/0x270
> [  +0.000609]        kmem_cache_create+0x12/0x20
> [  +0.000507]        ptlock_cache_init+0x20/0x28
> [  +0.000506]        start_kernel+0x240/0x4d0
> [  +0.000480]        secondary_startup_64+0xa4/0xb0
> [  +0.000539]
>               -> #1 (cpu_hotplug_lock.rw_sem){++++}:
> [  +0.000784]        cpus_read_lock+0x3e/0x80
> [  +0.000511]        online_pages+0x37/0x310
> [  +0.000469]        memory_subsys_online+0x34/0x60
> [  +0.000611]        device_online+0x60/0x80
> [  +0.000611]        state_store+0x66/0xd0
> [  +0.000552]        kernfs_fop_write+0xf0/0x1a0
> [  +0.000649]        vfs_write+0xba/0x1c0
> [  +0.000487]        ksys_write+0x5a/0xe0
> [  +0.000459]        do_syscall_64+0x60/0x210
> [  +0.000482]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  +0.000646]
>               -> #0 (kn->count#424){++++}:
> [  +0.000669]        lock_acquire+0x9e/0x180
> [  +0.000471]        __kernfs_remove+0x26a/0x310
> [  +0.000518]        kernfs_remove_by_name_ns+0x40/0x80
> [  +0.000583]        remove_files.isra.1+0x30/0x70
> [  +0.000555]        sysfs_remove_group+0x3d/0x80
> [  +0.000524]        sysfs_remove_groups+0x29/0x40
> [  +0.000532]        device_remove_attrs+0x42/0x80
> [  +0.000522]        device_del+0x162/0x380
> [  +0.000464]        device_unregister+0x16/0x60
> [  +0.000505]        unregister_memory_section+0x6e/0xa0
> [  +0.000591]        __remove_pages+0xe9/0x520
> [  +0.000492]        arch_remove_memory+0x81/0xc0
> [  +0.000568]        try_remove_memory+0xba/0xd0
> [  +0.000510]        remove_memory+0x23/0x40
> [  +0.000483]        dev_dax_kmem_remove+0x29/0x57 [kmem]
> [  +0.000608]        device_release_driver_internal+0xe4/0x1d0
> [  +0.000637]        unbind_store+0x9b/0x130
> [  +0.000464]        kernfs_fop_write+0xf0/0x1a0
> [  +0.000685]        vfs_write+0xba/0x1c0
> [  +0.000594]        ksys_write+0x5a/0xe0
> [  +0.000449]        do_syscall_64+0x60/0x210
> [  +0.000481]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  +0.000619]
>               other info that might help us debug this:
>
> [  +0.000889] Chain exists of:
>                 kn->count#424 --> mem_hotplug_lock.rw_sem --> mem_sysfs_mutex
>
> [  +0.001269]  Possible unsafe locking scenario:
>
> [  +0.000652]        CPU0                    CPU1
> [  +0.000505]        ----                    ----
> [  +0.000523]   lock(mem_sysfs_mutex);
> [  +0.000422]                                lock(mem_hotplug_lock.rw_sem);
> [  +0.000905]                                lock(mem_sysfs_mutex);
> [  +0.000793]   lock(kn->count#424);
> [  +0.000394]
>                *** DEADLOCK ***
>
> [  +0.000665] 7 locks held by daxctl/22950:
> [  +0.000458]  #0: 000000005f6d3c13 (sb_writers#4){.+.+}, at: vfs_write+0x159/0x1c0
> [  +0.000943]  #1: 00000000e468825d (&of->mutex){+.+.}, at: kernfs_fop_write+0xbd/0x1a0
> [  +0.000895]  #2: 00000000caa17dbb (&dev->mutex){....}, at: device_release_driver_internal+0x1a/0x1d0
> [  +0.001019]  #3: 000000002119b22c (device_hotplug_lock){+.+.}, at: remove_memory+0x16/0x40
> [  +0.000942]  #4: 00000000150c8efe (cpu_hotplug_lock.rw_sem){++++}, at: try_remove_memory+0x2e/0xd0
> [  +0.001019]  #5: 000000003d6b2a0f (mem_hotplug_lock.rw_sem){++++}, at: percpu_down_write+0x25/0x120
> [  +0.001118]  #6: 000000002aa52a9f (mem_sysfs_mutex){+.+.}, at: unregister_memory_section+0x22/0xa0
> [  +0.001033]
>               stack backtrace:
> [  +0.000507] CPU: 5 PID: 22950 Comm: daxctl Tainted: G           O      5.1.0-rc7+ #13
> [  +0.000896] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.1-0-g0551a4be2c-prebuilt.qemu-project.org 04/01/2014
> [  +0.001360] Call Trace:
> [  +0.000293]  dump_stack+0x85/0xc0
> [  +0.000390]  print_circular_bug.isra.41.cold.60+0x15c/0x195
> [  +0.000651]  check_prev_add.constprop.50+0x5fd/0xbe0
> [  +0.000563]  ? call_rcu_zapped+0x80/0x80
> [  +0.000449]  __lock_acquire+0xcee/0xfd0
> [  +0.000437]  lock_acquire+0x9e/0x180
> [  +0.000428]  ? kernfs_remove_by_name_ns+0x40/0x80
> [  +0.000531]  __kernfs_remove+0x26a/0x310
> [  +0.000451]  ? kernfs_remove_by_name_ns+0x40/0x80
> [  +0.000529]  ? kernfs_name_hash+0x12/0x80
> [  +0.000462]  kernfs_remove_by_name_ns+0x40/0x80
> [  +0.000513]  remove_files.isra.1+0x30/0x70
> [  +0.000483]  sysfs_remove_group+0x3d/0x80
> [  +0.000458]  sysfs_remove_groups+0x29/0x40
> [  +0.000477]  device_remove_attrs+0x42/0x80
> [  +0.000461]  device_del+0x162/0x380
> [  +0.000399]  device_unregister+0x16/0x60
> [  +0.000442]  unregister_memory_section+0x6e/0xa0
> [  +0.001232]  __remove_pages+0xe9/0x520
> [  +0.000443]  arch_remove_memory+0x81/0xc0
> [  +0.000459]  try_remove_memory+0xba/0xd0
> [  +0.000460]  remove_memory+0x23/0x40
> [  +0.000461]  dev_dax_kmem_remove+0x29/0x57 [kmem]
> [  +0.000603]  device_release_driver_internal+0xe4/0x1d0
> [  +0.000590]  unbind_store+0x9b/0x130
> [  +0.000409]  kernfs_fop_write+0xf0/0x1a0
> [  +0.000448]  vfs_write+0xba/0x1c0
> [  +0.000395]  ksys_write+0x5a/0xe0
> [  +0.000382]  do_syscall_64+0x60/0x210
> [  +0.000418]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [  +0.000573] RIP: 0033:0x7fd1f7442fa8
> [  +0.000407] Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 8d 05 75 77 0d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49 89 d4 55
> [  +0.002119] RSP: 002b:00007ffd48f58e28 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> [  +0.000833] RAX: ffffffffffffffda RBX: 000000000210c817 RCX: 00007fd1f7442fa8
> [  +0.000795] RDX: 0000000000000007 RSI: 000000000210c817 RDI: 0000000000000003
> [  +0.000816] RBP: 0000000000000007 R08: 000000000210c7d0 R09: 00007fd1f74d4e80
> [  +0.000808] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000003
> [  +0.000819] R13: 00007fd1f72b9ce8 R14: 0000000000000000 R15: 00007ffd48f58e70

