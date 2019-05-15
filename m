Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81192C04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:12:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 368C72087E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:12:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="oeDGU3G/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 368C72087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0B5A6B0005; Wed, 15 May 2019 14:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBC3D6B0006; Wed, 15 May 2019 14:12:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAAD66B0007; Wed, 15 May 2019 14:12:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCB26B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:12:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so1239764eds.5
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:12:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cRze2NwhKxUmrX+tzMEVzIsVCeW3eu3pdWGyD6SSofc=;
        b=pl5/7UcnZeC4KY3PrhXKrGqd/54NMVwg9TSK4/mlmSHNDDG949i6ucfMQ4YIJ/Aon0
         QeBPcERhmPQ5ZSRWJISWNnjjuQU5OlInmJLW/0kl406BDT8+7mCr25WAwUk5NEl5VraZ
         LO1jePBft72qkJJYpJO4dY1U13Y3uxecQn/IbuLCyhMnRyNijjimjuC2sl+YrewuJaEI
         lLWP3hvAC+uEYHmUoCpvrNgO3tYKUjmFXfbB/YK1IgS6CFwf+69Ak50hmdFzxTucwHjm
         6Wq9VrWQvV9MRC3cAap3XZWq85QMMwZl6ukvJ5iUq7mHGUANz2s9SSYGvjVX5HJH3ns1
         DOKA==
X-Gm-Message-State: APjAAAWRr2ncS0HEiXuL7zA5AwS9P3Cf84EYfDEXA7qptbjxLsvKIUiM
	B3PxtzDHzkwQqjCKT77nZVS3l7gXNv/whFeuYSlYLtlsp8N+YuKXJKtzYEosPgK+ps0kOE3Nbn8
	zwwrFaKbBe9M9+R2Bh3p6UsqPB5Mofsvpt3+D7Joz/EJbEdCw3KNrnX4/F6ZvnaQNGw==
X-Received: by 2002:a17:906:261b:: with SMTP id h27mr19522506ejc.97.1557943930952;
        Wed, 15 May 2019 11:12:10 -0700 (PDT)
X-Received: by 2002:a17:906:261b:: with SMTP id h27mr19522403ejc.97.1557943929773;
        Wed, 15 May 2019 11:12:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557943929; cv=none;
        d=google.com; s=arc-20160816;
        b=MsmmOzJPAjsX7ogrYwJ2DsHId09xMt+EgeuJvezUfdPHap7TxevmTnJLkSTqAa4ksn
         t6jSYU3QWKWQauy52EPOTq0zyD7hvotfYLcgiJipIgVB3mYWoywj48+iiqQ7imZKqbMB
         YeOQ970guQ8RIDYVg/uijBASLkjXNaoiGF/ua8wUSw2VyyjtOe6RuXk+mGVSVoOf/NWK
         igLq9m2vBeJjZ3o4dUMhSTu6vUWOdrJhsaGXyAPsoK49oJOF1XUER9w7mhuQNxxD1gn4
         StfflX8LdRUN+v8sRUAJwpXfZR/wo0N0T8/NIdAkfQ6jm/HaNaYua6dcBporFG4CO0Sj
         Kncg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cRze2NwhKxUmrX+tzMEVzIsVCeW3eu3pdWGyD6SSofc=;
        b=qQgbl8QFecg659iyVsdw21fEFWF63/RWwXnYP+BshxeutX53mFeaRj5LA1VNhxcZ/g
         +YpO1Ynn9xQa40YD3Z9kdb/0XSNCloIl+U4dTaFCNn7Tgz1ZItFKgaDXZvmZLT+QeCFX
         wvBEO0cocU/edlHXEtph8ZaaAU+uK78GXu7z2TQjsIEYi0JM+nNYcuAarPh19vVvcrBX
         A9XmSCLtPmgcm3xiI6CucnKQyvBz4k6SdCC2UqGvtLj+ny9O0caApA+mSTbIQVt/0qMp
         acgU7EXVFY/oChSx1BhSSH/VrmEMonrnJwZ1niAY+sZ83Inze27k2P5s73DhpxFcY6ov
         7InQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="oeDGU3G/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor1064852ejx.18.2019.05.15.11.12.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 11:12:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="oeDGU3G/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cRze2NwhKxUmrX+tzMEVzIsVCeW3eu3pdWGyD6SSofc=;
        b=oeDGU3G/EXvFp7MfI+JKrqpXLbgsT6KAvUNZwN8SvRY8NFh8phZ9eN40SJQs3yP2fF
         xQNVjFfygUwrlQzRAqlFFs3367XKy6ATqv70WcrTiffrGv7U/o3QoC81OUCvJzdZRG8p
         fqksNru7bvmonPrCDmNwVrVxLr0kycm3ve3KadWmE1UFyAX2ZtlcSctN9f0/UTLoaQED
         uqdMTABej7gKmQzFPgmWzXufN8r0wCE/82Oi8MK3COsE69Q3aMhsB5hZM2JLeEJBuvHb
         A5JnLn4InCloW4LPV1lgyTA4tT/OifK8s0UGspOPwh+TZm33S8DDhDFfnfUf5QC8KTZX
         SCiw==
X-Google-Smtp-Source: APXvYqziaXhGwhi8bJ4LWNTeRpPXVwzEAL199XnjwVbC6ahkOtixM/ml3bxeFuTijrrGJ9mfac3GS9qVcSia6Y2UUt0=
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr34389391ejq.151.1557943929264;
 Wed, 15 May 2019 11:12:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com> <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
In-Reply-To: <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 15 May 2019 14:11:58 -0400
Message-ID: <CA+CK2bCKcJjXo7BGAVxvbQNYQFSDVLH5aB=S9yTmZWEfexOvtg@mail.gmail.com>
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

I have studied this issue, and now have a clear understanding why it
happens, I am not yet sure how to fix it, so suggestions are welcomed
:)

Here is the problem:

When we offline pages we have the following call stack:

# echo offline > /sys/devices/system/memory/memory8/state
ksys_write
 vfs_write
  __vfs_write
   kernfs_fop_write
    kernfs_get_active
     lock_acquire                       kn->count#122 (lock for
"memory8/state" kn)
    sysfs_kf_write
     dev_attr_store
      state_store
       device_offline
        memory_subsys_offline
         memory_block_action
          offline_pages
           __offline_pages
            percpu_down_write
             down_write
              lock_acquire              mem_hotplug_lock.rw_sem

When we unbind dax0.0 we have the following  stack:
# echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
drv_attr_store
 unbind_store
  device_driver_detach
   device_release_driver_internal
    dev_dax_kmem_remove
     remove_memory                      device_hotplug_lock
      try_remove_memory                 mem_hotplug_lock.rw_sem
       arch_remove_memory
        __remove_pages
         __remove_section
          unregister_memory_section
           remove_memory_section        mem_sysfs_mutex
            unregister_memory
             device_unregister
              device_del
               device_remove_attrs
                sysfs_remove_groups
                 sysfs_remove_group
                  remove_files
                   kernfs_remove_by_name
                    kernfs_remove_by_name_ns
                     __kernfs_remove    kn->count#122

So, lockdep found the ordering issue with the above two stacks:

1. kn->count#122 -> mem_hotplug_lock.rw_sem
2. mem_hotplug_lock.rw_sem -> kn->count#122

