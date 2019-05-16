Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DFF4C04E53
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 00:42:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91A072070D
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 00:42:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="U/Y22/bC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91A072070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92B66B0005; Wed, 15 May 2019 20:42:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C442E6B0006; Wed, 15 May 2019 20:42:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B32FA6B0007; Wed, 15 May 2019 20:42:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85F216B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 20:42:54 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id t17so872991otp.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 17:42:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4wF4B/XO+LFCzisDrNsMqmlSL+kOk21IiP/4p8K0X7U=;
        b=MgkEHZC/n78tSjbYHQ/24/5Az0ij2aH7dUlFZkGfVJTczw581QeVu1GrztK+WsYDy/
         lKk6L6SRtNpuL2scxZZFbm1NivPD66u53p4/wRj7ZMV0Go9L+kNralLSHsUicF7+fWPY
         yevvOPFdrtCcSoX3JJJn9Ygmjwe1ZbNIKXJjC7xLG7XSov+OmSZpDpyiOD3rXNghsPAA
         RdeOdEpywolpFc8J3rM929S9s/ka48W4MnoI3Jta0+8HFMaIPD+RDAnJnLuE9A9lzrSC
         Ekqg2g1aBudLOEW0Z+6aZyYwLpHoe7zzI9hQ/0A30+gQVGXAr/Zo8dmbFeMY+fvk7b6c
         IUcA==
X-Gm-Message-State: APjAAAVIoh4FUuDvzIDakar8JpGN14CxWUQlVHtmApj+QxLn72yqxFzk
	9qgG+8oSC4c+2QvJoNmHjQgYf7brMsvfX+85VaICGNyr7dsDCH3IRzsZFcnx7QmbnAkTPn47sZg
	XP1/RV0QevaMCm3p/Wv+7aI4x4XgmSIkflIe0YS/wjCyI5qfwqpjk1pzPmJBLrI0t/w==
X-Received: by 2002:aca:add3:: with SMTP id w202mr8775783oie.126.1557967374048;
        Wed, 15 May 2019 17:42:54 -0700 (PDT)
X-Received: by 2002:aca:add3:: with SMTP id w202mr8775760oie.126.1557967373230;
        Wed, 15 May 2019 17:42:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557967373; cv=none;
        d=google.com; s=arc-20160816;
        b=TR3byHAAK7Hxqp1rlQ1GsK0U2ny1AFCawmGBFs2Gqw+oAmJofhW5TYBCf2y8rRwnVI
         QJLHql6D8VlmBfiCFBua5cWqxus2O0lvugNbE8sjPzBhEhOc/+0qauENmmrNUukQXamF
         NGGCGiIl3EUHtWGrsniZbD2ZIMeRuDBIhc5zoOdjRY1QhKVqM6TMLz/81FJQFLoSiby4
         BwNqNo+s5jPrXASLTWMMF/RQpv7Tfy1X3+2bFTFqsqS0Ut7+jmN9i6vKJgs8rrZCXySY
         bv4gKAuW26j+DNWXrYv3j87IsmWjo9mwhjt2rdFcp8LvSdOCIohZ5lJsH9eiuo2iQ1gZ
         p/Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4wF4B/XO+LFCzisDrNsMqmlSL+kOk21IiP/4p8K0X7U=;
        b=KpXOJdk/zdwKe8z+uZ6Je8kcDbhtI2u6sZkxe/tVSd9XqiXhFsAt6KljdXyH9pM/qr
         E/DDgBmid0wUBSxqNT/TvdOpvjqWmFWMA3R5SHVPx3RfP4wgTthH1iA3S3rN/bGXScGx
         3IJSHBO8pi5pq0rBUltcpOg3t6YkcqAYl2YA/y5dhZrqzjFFJFrBaVxssbGXgWDcZ16C
         FbJdFRGyD7So3JyhJAodnK8l1jY0n/ve53X9hxK/UEnCVWNWMuGDaJVHQkm5QmrxeSOn
         fLACGoCP7GsZQhhxpMASaz8wfgI3NHCcpSW4h5emq6majHh9Ji1uZxcq5srUHPAasuCl
         lHjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="U/Y22/bC";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f32sor1823588otb.171.2019.05.15.17.42.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 17:42:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="U/Y22/bC";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4wF4B/XO+LFCzisDrNsMqmlSL+kOk21IiP/4p8K0X7U=;
        b=U/Y22/bCzRIzE1Xsqh5f3+RBvJUV1RMz+pVgOjqYlQhz4iQqdrUPBRWbWciAaasKQe
         vf8QyeNFoGsz8yqkGygyREx7lhw9HstPaMuVrr27/KyitIfiP0TnNsEbh+rsCCGBoUDY
         irfkr7iszBcaj4LIg2eFjALBbAw0LyVbqSAuaajKOP0NsaCv5sTe9zXHbxvKAFhfARk0
         7L4havjtTmMCm3Md5Y9rr5ig4PFYphhp95oMlWixzxiSkNqTP59gYvQk/rhziKM7Zrrm
         VAtwNZsGyNLgm0GA15nZVzk8++wQz8D0asXbsKwS3EQzV03FdRgsSypZRh/sKEIYDtVc
         9H7w==
X-Google-Smtp-Source: APXvYqxHHdBhJkGMx5fiIIlPrJsnSR6+qYmBOEInSq5ilrexTUGafywN2clUkUaBI+pWKFUlTJBtGXaBRq9YnBc8yJ0=
X-Received: by 2002:a9d:d09:: with SMTP id 9mr28295683oti.82.1557967372879;
 Wed, 15 May 2019 17:42:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com> <CA+CK2bCKcJjXo7BGAVxvbQNYQFSDVLH5aB=S9yTmZWEfexOvtg@mail.gmail.com>
In-Reply-To: <CA+CK2bCKcJjXo7BGAVxvbQNYQFSDVLH5aB=S9yTmZWEfexOvtg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 May 2019 17:42:42 -0700
Message-ID: <CAPcyv4jj557QNNwyQ7ez+=PnURsnXk9cGZ11Mmihmtem2bJ-3A@mail.gmail.com>
Subject: Re: [v5 0/3] "Hotremove" persistent memory
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
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

On Wed, May 15, 2019 at 11:12 AM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> > Hi Pavel,
> >
> > I am working on adding this sort of a workflow into a new daxctl command
> > (daxctl-reconfigure-device)- this will allow changing the 'mode' of a
> > dax device to kmem, online the resulting memory, and with your patches,
> > also attempt to offline the memory, and change back to device-dax.
> >
> > In running with these patches, and testing the offlining part, I ran
> > into the following lockdep below.
> >
> > This is with just these three patches on top of -rc7.
> >
> >
> > [  +0.004886] ======================================================
> > [  +0.001576] WARNING: possible circular locking dependency detected
> > [  +0.001506] 5.1.0-rc7+ #13 Tainted: G           O
> > [  +0.000929] ------------------------------------------------------
> > [  +0.000708] daxctl/22950 is trying to acquire lock:
> > [  +0.000548] 00000000f4d397f7 (kn->count#424){++++}, at: kernfs_remove_by_name_ns+0x40/0x80
> > [  +0.000922]
> >               but task is already holding lock:
> > [  +0.000657] 000000002aa52a9f (mem_sysfs_mutex){+.+.}, at: unregister_memory_section+0x22/0xa0
>
> I have studied this issue, and now have a clear understanding why it
> happens, I am not yet sure how to fix it, so suggestions are welcomed
> :)

I would think that ACPI hotplug would have a similar problem, but it does this:

                acpi_unbind_memory_blocks(info);
                __remove_memory(nid, info->start_addr, info->length);

I wonder if that ordering prevents going too deep into the
device_unregister() call stack that you highlighted below.


>
> Here is the problem:
>
> When we offline pages we have the following call stack:
>
> # echo offline > /sys/devices/system/memory/memory8/state
> ksys_write
>  vfs_write
>   __vfs_write
>    kernfs_fop_write
>     kernfs_get_active
>      lock_acquire                       kn->count#122 (lock for
> "memory8/state" kn)
>     sysfs_kf_write
>      dev_attr_store
>       state_store
>        device_offline
>         memory_subsys_offline
>          memory_block_action
>           offline_pages
>            __offline_pages
>             percpu_down_write
>              down_write
>               lock_acquire              mem_hotplug_lock.rw_sem
>
> When we unbind dax0.0 we have the following  stack:
> # echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> drv_attr_store
>  unbind_store
>   device_driver_detach
>    device_release_driver_internal
>     dev_dax_kmem_remove
>      remove_memory                      device_hotplug_lock
>       try_remove_memory                 mem_hotplug_lock.rw_sem
>        arch_remove_memory
>         __remove_pages
>          __remove_section
>           unregister_memory_section
>            remove_memory_section        mem_sysfs_mutex
>             unregister_memory
>              device_unregister
>               device_del
>                device_remove_attrs
>                 sysfs_remove_groups
>                  sysfs_remove_group
>                   remove_files
>                    kernfs_remove_by_name
>                     kernfs_remove_by_name_ns
>                      __kernfs_remove    kn->count#122
>
> So, lockdep found the ordering issue with the above two stacks:
>
> 1. kn->count#122 -> mem_hotplug_lock.rw_sem
> 2. mem_hotplug_lock.rw_sem -> kn->count#122

