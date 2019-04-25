Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39DBBC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:22:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21E712084F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:22:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21E712084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=linux.microsoft.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961C26B0006; Thu, 25 Apr 2019 16:22:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EAFF6B0008; Thu, 25 Apr 2019 16:22:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BEF6B000A; Thu, 25 Apr 2019 16:22:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE1A6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:22:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j12so442532pgl.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:22:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=H84sJGSYcVA4QSsIl9VFD8eBt+eS5ggVUcs2wVWKjTU=;
        b=cuMBhqMqSDKu+NGBLRUhO7mZcuPJC7xx3rZIpFaeMnu0H9niIbHMX0AQ6K+W4ZufyB
         Xd3CA87gZsazpQpw+BozH0FAkG85UoYtO7NxVDHXSYMzI9+S1LtWP6Ezl/O/akQKS3kF
         +lIQmNXlpMHwNwQDiO/Uvyf/lKc8MDIxwfYYfmD5Pc+6iAVhc20GU0TBrnsb+9pXWUg3
         Lj24fcCh+k9McOxXsycN8s7GSlk/AH5twYJqr1mXX2PtV6OmW8Elg2MYu28QEXe4x4zq
         lbkhsYCbucgnh/vXKfxfvm+kCUghK/NKBcYOaRWEkxSVEqIfGpFhzSelvFIkYKunh5Ee
         FoiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
X-Gm-Message-State: APjAAAVOBeDKcHq79jQL3r5nUsFOY6vKYO6ho0lgf5Le3l8cfhKAtqnH
	eCuxk5DeGObPbOr/hXTvwbMaY0EQOML4Zdx/1vziVI63vHA+zt7S9/lqBq2ibdASX8LpVgm9syd
	BjEv7jIBuMyEW6rJrttEmBQzwZb+eJ6F8GJ5MYdfrzg+40dxc1VSMq7AY+ItbAkRJ3g==
X-Received: by 2002:a63:360c:: with SMTP id d12mr38764158pga.404.1556223723844;
        Thu, 25 Apr 2019 13:22:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5w/zkNU99Xko0JuqzaBjXSD2HV4VRME5KG96ZN1/96WQWtyVyjaFP4zum43oRBQgC0K1V
X-Received: by 2002:a63:360c:: with SMTP id d12mr38764088pga.404.1556223723055;
        Thu, 25 Apr 2019 13:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556223723; cv=none;
        d=google.com; s=arc-20160816;
        b=Rj1AsA3Uw5ERV/phFIHV79EFX9ijlmXnhN1eGtIVWfzP+V/gbnaxHrVAfUBnDDigbV
         expSBAx1wnOB1bC0vMdzAfCbUOob+WYo3IEf+ven4TfDxLfOzKeRhPlzGGgzaQIrSNsO
         NXPb9m3raHxDLx9fcm66lsPiq/th9EsmH7MGf+xcZZMnMueY+uxbM3JkSXxyLxGC9wl2
         ozcsCc0aNIMUpAj5KJrLBTbB/EZE+jNXJU5T1hUJPDV8Kzq6oLt9BpHY8wtd5HhS0b2p
         2G3oUXIXFpyu5513DgTUNUu0iRTalRguARD5C8cdW5kin+3TCWUauirbIdzc59IOaNW/
         W88Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=H84sJGSYcVA4QSsIl9VFD8eBt+eS5ggVUcs2wVWKjTU=;
        b=YROrnXN3dAaoM7JyFXo4cbtsz+HR+XliSx0tXHVYB/H78ImgWHW2N2flvz2Bp2RASA
         aCKqMOKyuPsfM8sCTCZPCWohy3gzjvuGVoq+qJ+hfq/GRuvzzm0lECr4TuFh06JKyXYk
         D8u/Q3taEDdraVxYcJnmzniRJFhnzG4ERkChzDNrb87Y3GaBnhX/SOHeETVahbHkaQu8
         OjG/S61zCoAp6y/FERASvQtfWHuClciNMkbMWOrF9qhPOByQKWMuR+H/tnwNObN8nB+/
         Ka3QNY+18bi1+lCqBojCsL8hlwuRL0/uXZ3Ufsit73wKTTVMssiv2L9fKwl97MFwMP3M
         IJVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from linux.microsoft.com (linux.microsoft.com. [13.77.154.182])
        by mx.google.com with ESMTP id l11si24222612plb.370.2019.04.25.13.22.02
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 13:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) client-ip=13.77.154.182;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from mail-ed1-f49.google.com (mail-ed1-f49.google.com [209.85.208.49])
	by linux.microsoft.com (Postfix) with ESMTPSA id 2D3C03052D08
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:22:02 -0700 (PDT)
Received: by mail-ed1-f49.google.com with SMTP id k45so1097163edb.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:22:02 -0700 (PDT)
X-Received: by 2002:a17:906:5586:: with SMTP id y6mr12040782ejp.48.1556223720560;
 Thu, 25 Apr 2019 13:22:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190425175440.9354-1-pasha.tatashin@soleen.com>
 <20190425175440.9354-3-pasha.tatashin@soleen.com> <77c286e3-8708-6e64-94a1-fb44b6bbff3f@intel.com>
In-Reply-To: <77c286e3-8708-6e64-94a1-fb44b6bbff3f@intel.com>
From: Pavel Tatashin <patatash@linux.microsoft.com>
Date: Thu, 25 Apr 2019 16:21:49 -0400
X-Gmail-Original-Message-ID: <CA+CK2bA=t2U51-Zoii1RWEDbXwvQ_ZALtJyQVZ392b8f7H+sew@mail.gmail.com>
Message-ID: <CA+CK2bA=t2U51-Zoii1RWEDbXwvQ_ZALtJyQVZ392b8f7H+sew@mail.gmail.com>
Subject: Re: [v3 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dave Hansen <dave.hansen@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 3:01 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> Hi Pavel,
>
> Thanks for doing this!  I knew we'd have to get to it eventually, but
> sounds like you needed it sooner rather than later.

Hi Dave,

Thank you for taking time reviewing this work, my comments below:

> >
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
>
> Instead of this #ifdef, is there any downside to doing
>
>         if (!IS_ENABLED(CONFIG_MEMORY_HOTREMOVE)) {
>                 /*
>                  * Without hotremove, purposely leak ...
>                  */
>                 return 0;
>         }

Your method relies that compiler will optimize out all the code that
is not needed, and that dependencies such as __remove_memory() have
empty stubs. So, I prefer that way it is currently implemented.

>
>
> > +/*
> > + * Check that device-dax's memory_blocks are offline. If a memory_block is not
> > + * offline a warning is printed and an error is returned. dax hotremove can
> > + * succeed only when every memory_block is offlined beforehand.
> > + */
>
> I'd much rather see comments inline with the code than all piled at the
> top of a function like this.

OK

>
> One thing that would be helpful, though, is a reminder about needing the
> device hotplug lock.

OK

>
> > +static int
> > +check_memblock_offlined_cb(struct memory_block *mem, void *arg)
> > +{
> > +     struct device *mem_dev = &mem->dev;
> > +     bool is_offline;
> > +
> > +     device_lock(mem_dev);
> > +     is_offline = mem_dev->offline;
> > +     device_unlock(mem_dev);
> > +
> > +     if (!is_offline) {
> > +             struct device *dev = (struct device *)arg;
>
> The two devices confused me for a bit here.  Seems worth a comment to
> remind the reader what this device _is_ versus 'mem_dev'.

OK

>
> > +             unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> > +             unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
> > +             phys_addr_t spa = spfn << PAGE_SHIFT;
> > +             phys_addr_t epa = epfn << PAGE_SHIFT;
> > +
> > +             dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
> > +                      &spa, &epa);
>
> I thought we had a magic resource printk %something.  Could we just
> print one of the device resources here to save all the section/pfn/paddr
> calculations?

There is no resource for each memory block device, only for system
ram. Since here we inform admin about a particular memory block that
is not offlined, I do not see how to do it differently.

>
> Also, should we consider a slightly scarier message?  This path has a
> permanent, user-visible effect (we can never try to unbind again).

hm, how about:
dev_err(
"DAX region %pR cannot be hotremoved until next reboot because memory
block [%pa-%pa] is not offline"
)

>
> > +             return -EBUSY;
> > +     }
> > +
> > +     return 0;
> > +}
>
> Even though they're static, I'd prefer that we not create two versions
> of check_memblock_offlined_cb() in the kernel.  Can we give this a
> better, non-conflicting name?

how about check_devdax_mem_offlined_cb ?

>
> > +static int dev_dax_kmem_remove(struct device *dev)
> > +{
> > +     struct dev_dax *dev_dax = to_dev_dax(dev);
> > +     struct resource *res = dev_dax->dax_kmem_res;
> > +     resource_size_t kmem_start;
> > +     resource_size_t kmem_size;
> > +     unsigned long start_pfn;
> > +     unsigned long end_pfn;
> > +     int rc;
> > +
> > +     /*
> > +      * dax kmem resource does not exist, means memory was never hotplugged.
> > +      * So, nothing to do here.
> > +      */
> > +     if (!res)
> > +             return 0;
>
> How could that happen?  I can't think of any obvious scenarios.

Yes, I do not think this is possible. I can remove this check. Just
feels safer to have it though.

>
> > +     kmem_start = res->start;
> > +     kmem_size = resource_size(res);
> > +     start_pfn = kmem_start >> PAGE_SHIFT;
> > +     end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
> > +
> > +     /*
> > +      * Walk and check that every singe memory_block of dax region is
> > +      * offline
> > +      */
> > +     lock_device_hotplug();
> > +     rc = walk_memory_range(start_pfn, end_pfn, dev,
> > +                            check_memblock_offlined_cb);
>
> Does lock_device_hotplug() also lock memory online/offline?  Otherwise,
> isn't this offline check racy?  If not, can you please spell that out in
> a comment?

Yes, it locks memory online/offline via sysfs: online_store(), as that
one also takes this lock lock_device_hotplug(). If someone else wants
to offline/online the memory they also need to take this lock.

>
> Also, could you compare this a bit to the walk_memory_range() use in
> __remove_memory()?  Why do we need two walks looking for offline blocks?

It is basically doing the same thing, but I do not really see a way
around this. Because __remove_memory() assumes that pages are
offlined, checks, and panics if they are not. Here, we do not panic,
but inform admin of consequences.

Thank you,
Pasha

