Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id D80E16B0258
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 03:50:16 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so104068675ykd.2
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 00:50:16 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id g83si10177873ywc.125.2015.08.03.00.50.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 00:50:14 -0700 (PDT)
Received: by ykeo23 with SMTP id o23so7248823yke.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 00:50:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437159145-6548-6-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
	<1437159145-6548-6-git-send-email-jglisse@redhat.com>
Date: Mon, 3 Aug 2015 13:20:13 +0530
Message-ID: <CAKrE-Kf6e19-KfUkr9nLV1DFbGQCnzGZ49iEVUbm2LVbHFmLtg@mail.gmail.com>
Subject: Re: [PATCH 05/15] HMM: introduce heterogeneous memory management v4.
From: Girish KS <girishks2000@gmail.com>
Content-Type: multipart/alternative; boundary=001a113a346c6fbb6b051c636bb2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Christophe Harle <charle@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Dave Airlie <airlied@redhat.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, joro@8bytes.org, Greg Stoner <Greg.Stoner@amd.com>, akpm@linux-foundation.org, Cameron Buschardt <cabuschardt@nvidia.com>, Rik van Riel <riel@redhat.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Lucien Dunning <ldunning@nvidia.com>, Johannes Weiner <jweiner@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Michael Mantor <Michael.Mantor@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Larry Woodman <lwoodman@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Brendan Conoboy <blc@redhat.com>, John Bridgman <John.Bridgman@amd.com>, Subhash Gutti <sgutti@nvidia.com>, Roland Dreier <roland@purestorage.com>, Duncan Poole <dpoole@nvidia.com>, linux-mm@kvack.org, Alexander Deucher <Alexander.Deucher@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Sherry Cheung <SCheung@nvidia.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Ben Sander <ben.sander@amd.com>, Joe Donohue <jdonohue@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, ks.giri@samsung.com

--001a113a346c6fbb6b051c636bb2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 18-Jul-2015 12:47 am, "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com> wro=
te:
>
> This patch only introduce core HMM functions for registering a new
> mirror and stopping a mirror as well as HMM device registering and
> unregistering.
>
> The lifecycle of HMM object is handled differently then the one of
> mmu_notifier because unlike mmu_notifier there can be concurrent
> call from both mm code to HMM code and/or from device driver code
> to HMM code. Moreover lifetime of HMM can be uncorrelated from the
> lifetime of the process that is being mirror (GPU might take longer
> time to cleanup).
>
> Changed since v1:
>   - Updated comment of hmm_device_register().
>
> Changed since v2:
>   - Expose struct hmm for easy access to mm struct.
>   - Simplify hmm_mirror_register() arguments.
>   - Removed the device name.
>   - Refcount the mirror struct internaly to HMM allowing to get
>     rid of the srcu and making the device driver callback error
>     handling simpler.
>   - Safe to call several time hmm_mirror_unregister().
>   - Rework the mmu_notifier unregistration and release callback.
>
> Changed since v3:
>   - Rework hmm_mirror lifetime rules.
>   - Synchronize with mmu_notifier srcu before droping mirror last
>     reference in hmm_mirror_unregister()
>   - Use spinlock for device's mirror list.
>   - Export mirror ref/unref functions.
>   - English syntax fixes.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---
>  MAINTAINERS              |   7 +
>  include/linux/hmm.h      | 173 +++++++++++++++++++++
>  include/linux/mm.h       |  11 ++
>  include/linux/mm_types.h |  14 ++
>  kernel/fork.c            |   2 +
>  mm/Kconfig               |  14 ++
>  mm/Makefile              |   1 +
>  mm/hmm.c                 | 381
+++++++++++++++++++++++++++++++++++++++++++++++
>  8 files changed, 603 insertions(+)
>  create mode 100644 include/linux/hmm.h
>  create mode 100644 mm/hmm.c
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2d3d55c..8ebdc17 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4870,6 +4870,13 @@ F:       include/uapi/linux/if_hippi.h
>  F:     net/802/hippi.c
>  F:     drivers/net/hippi/
>
> +HMM - Heterogeneous Memory Management
> +M:     J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> +L:     linux-mm@kvack.org
> +S:     Maintained
> +F:     mm/hmm.c
> +F:     include/linux/hmm.h
> +
>  HOST AP DRIVER
>  M:     Jouni Malinen <j@w1.fi>
>  L:     hostap@shmoo.com (subscribers-only)
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> new file mode 100644
> index 0000000..b559c0b
> --- /dev/null
> +++ b/include/linux/hmm.h
> @@ -0,0 +1,173 @@
> +/*
> + * Copyright 2013 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> + */
> +/* This is a heterogeneous memory management (hmm). In a nutshell this
provide
> + * an API to mirror a process address on a device which has its own mmu
using
> + * its own page table for the process. It supports everything except
special
> + * vma.
> + *
> + * Mandatory hardware features :
> + *   - An mmu with pagetable.
> + *   - Read only flag per cpu page.
> + *   - Page fault ie hardware must stop and wait for kernel to service
fault.
> + *
> + * Optional hardware features :
> + *   - Dirty bit per cpu page.
> + *   - Access bit per cpu page.
> + *
> + * The hmm code handle all the interfacing with the core kernel mm code
and
> + * provide a simple API. It does support migrating system memory to
device
> + * memory and handle migration back to system memory on cpu page fault.
> + *
> + * Migrated memory is considered as swaped from cpu and core mm code
point of
> + * view.
> + */
> +#ifndef _HMM_H
> +#define _HMM_H
> +
> +#ifdef CONFIG_HMM
> +
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/atomic.h>
> +#include <linux/mm_types.h>
> +#include <linux/mmu_notifier.h>
> +#include <linux/workqueue.h>
> +#include <linux/mman.h>
> +
> +
> +struct hmm_device;
> +struct hmm_mirror;
> +struct hmm;
> +
> +
> +/* hmm_device - Each device must register one and only one hmm_device.
> + *
> + * The hmm_device is the link btw HMM and each device driver.
> + */
> +
> +/* struct hmm_device_operations - HMM device operation callback
> + */
> +struct hmm_device_ops {
> +       /* release() - mirror must stop using the address space.
> +        *
> +        * @mirror: The mirror that link process address space with the
device.
> +        *
> +        * When this is called, device driver must kill all device thread
using
> +        * this mirror. It is call either from :
> +        *   - mm dying (all process using this mm exiting).
> +        *   - hmm_mirror_unregister() (if no other thread holds a
reference)
> +        *   - outcome of some device error reported by any of the device
> +        *     callback against that mirror.
> +        */
> +       void (*release)(struct hmm_mirror *mirror);
> +
> +       /* free() - mirror can be freed.
> +        *
> +        * @mirror: The mirror that link process address space with the
device.
> +        *
> +        * When this is called, device driver can free the underlying
memory
> +        * associated with that mirror. Note this is call from atomic
context
> +        * so device driver callback can not sleep.
> +        */
> +       void (*free)(struct hmm_mirror *mirror);
> +};
> +
> +
> +/* struct hmm - per mm_struct HMM states.
> + *
> + * @mm: The mm struct this hmm is associated with.
> + * @mirrors: List of all mirror for this mm (one per device).
> + * @vm_end: Last valid address for this mm (exclusive).
> + * @kref: Reference counter.
> + * @rwsem: Serialize the mirror list modifications.
> + * @mmu_notifier: The mmu_notifier of this mm.
> + * @rcu: For delayed cleanup call from mmu_notifier.release() callback.
> + *
> + * For each process address space (mm_struct) there is one and only one
hmm
> + * struct. hmm functions will redispatch to each devices the change made
to
> + * the process address space.
> + *
> + * Device driver must not access this structure other than for getting
the
> + * mm pointer.
> + */
> +struct hmm {
> +       struct mm_struct        *mm;
> +       struct hlist_head       mirrors;
> +       unsigned long           vm_end;
> +       struct kref             kref;
> +       struct rw_semaphore     rwsem;
> +       struct mmu_notifier     mmu_notifier;
> +       struct rcu_head         rcu;
> +};
> +
> +
> +/* struct hmm_device - per device HMM structure
> + *
> + * @dev: Linux device structure pointer.
> + * @ops: The hmm operations callback.
> + * @mirrors: List of all active mirrors for the device.
> + * @lock: Lock protecting mirrors list.
> + *
> + * Each device that want to mirror an address space must register one of
this
> + * struct (only once per linux device).
> + */
> +struct hmm_device {
> +       struct device                   *dev;
> +       const struct hmm_device_ops     *ops;
> +       struct list_head                mirrors;
> +       spinlock_t                      lock;
> +};
> +
> +int hmm_device_register(struct hmm_device *device);
> +int hmm_device_unregister(struct hmm_device *device);
> +
> +
> +/* hmm_mirror - device specific mirroring functions.
> + *
> + * Each device that mirror a process has a uniq hmm_mirror struct
associating
> + * the process address space with the device. Same process can be
mirrored by
> + * several different devices at the same time.
> + */
> +
> +/* struct hmm_mirror - per device and per mm HMM structure
> + *
> + * @device: The hmm_device struct this hmm_mirror is associated to.
> + * @hmm: The hmm struct this hmm_mirror is associated to.
> + * @kref: Reference counter (private to HMM do not use).
> + * @dlist: List of all hmm_mirror for same device.
> + * @mlist: List of all hmm_mirror for same process.
> + *
> + * Each device that want to mirror an address space must register one of
this
> + * struct for each of the address space it wants to mirror. Same device
can
> + * mirror several different address space. As well same address space
can be
> + * mirror by different devices.
> + */
> +struct hmm_mirror {
> +       struct hmm_device       *device;
> +       struct hmm              *hmm;
> +       struct kref             kref;
> +       struct list_head        dlist;
> +       struct hlist_node       mlist;
> +};
> +
> +int hmm_mirror_register(struct hmm_mirror *mirror);
> +void hmm_mirror_unregister(struct hmm_mirror *mirror);
> +struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
> +void hmm_mirror_unref(struct hmm_mirror **mirror);
> +
> +
> +#endif /* CONFIG_HMM */
> +#endif
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2e872f9..b5bf210 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2243,5 +2243,16 @@ void __init setup_nr_node_ids(void);
>  static inline void setup_nr_node_ids(void) {}
>  #endif
>
> +#ifdef CONFIG_HMM
> +static inline void hmm_mm_init(struct mm_struct *mm)
> +{
> +       mm->hmm =3D NULL;
> +}
> +#else /* !CONFIG_HMM */
> +static inline void hmm_mm_init(struct mm_struct *mm)
> +{
> +}
> +#endif /* !CONFIG_HMM */
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 0038ac7..fa05917 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -15,6 +15,10 @@
>  #include <asm/page.h>
>  #include <asm/mmu.h>
>
> +#ifdef CONFIG_HMM
> +struct hmm;
> +#endif
> +
>  #ifndef AT_VECTOR_SIZE_ARCH
>  #define AT_VECTOR_SIZE_ARCH 0
>  #endif
> @@ -451,6 +455,16 @@ struct mm_struct {
>  #ifdef CONFIG_MMU_NOTIFIER
>         struct mmu_notifier_mm *mmu_notifier_mm;
>  #endif
> +#ifdef CONFIG_HMM
> +       /*
> +        * hmm always register an mmu_notifier we rely on mmu notifier to
keep
> +        * refcount on mm struct as well as forbiding registering hmm on =
a
> +        * dying mm
> +        *
> +        * This field is set with mmap_sem held in write mode.
> +        */
> +       struct hmm *hmm;
> +#endif
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>         pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>  #endif
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 1bfefc6..0d1f446 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -27,6 +27,7 @@
>  #include <linux/binfmts.h>
>  #include <linux/mman.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/hmm.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/vmacache.h>
> @@ -597,6 +598,7 @@ static struct mm_struct *mm_init(struct mm_struct
*mm, struct task_struct *p)
>         mm_init_aio(mm);
>         mm_init_owner(mm, p);
>         mmu_notifier_mm_init(mm);
> +       hmm_mm_init(mm);
>         clear_tlb_flush_pending(mm);
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>         mm->pmd_huge_pte =3D NULL;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e79de2b..e1e0a82 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -654,3 +654,17 @@ config DEFERRED_STRUCT_PAGE_INIT
>           when kswapd starts. This has a potential performance impact on
>           processes running early in the lifetime of the systemm until
kswapd
>           finishes the initialisation.
> +
> +if STAGING
> +config HMM
> +       bool "Enable heterogeneous memory management (HMM)"
> +       depends on MMU
> +       select MMU_NOTIFIER
> +       default n
> +       help
> +         Heterogeneous memory management provide infrastructure for a
device
> +         to mirror a process address space into an hardware mmu or into
any
> +         things supporting pagefault like event.
> +
> +         If unsure, say N to disable hmm.
> +endif # STAGING
> diff --git a/mm/Makefile b/mm/Makefile
> index 98c4eae..90ca9c4 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)     +=3D cma.o
>  obj-$(CONFIG_MEMORY_BALLOON) +=3D balloon_compaction.o
>  obj-$(CONFIG_PAGE_EXTENSION) +=3D page_ext.o
>  obj-$(CONFIG_CMA_DEBUGFS) +=3D cma_debug.o
> +obj-$(CONFIG_HMM) +=3D hmm.o
> diff --git a/mm/hmm.c b/mm/hmm.c
> new file mode 100644
> index 0000000..198fe37
> --- /dev/null
> +++ b/mm/hmm.c
> @@ -0,0 +1,381 @@
> +/*
> + * Copyright 2013 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> + */
> +/* This is the core code for heterogeneous memory management (HMM). HMM
intend
> + * to provide helper for mirroring a process address space on a device
as well
> + * as allowing migration of data between system memory and device memory
refer
> + * as remote memory from here on out.
> + *
> + * Refer to include/linux/hmm.h for further information on general
design.
> + */
> +#include <linux/export.h>
> +#include <linux/bitmap.h>
> +#include <linux/list.h>
> +#include <linux/rculist.h>
> +#include <linux/slab.h>
> +#include <linux/mmu_notifier.h>
> +#include <linux/mm.h>
> +#include <linux/hugetlb.h>
> +#include <linux/fs.h>
> +#include <linux/file.h>
> +#include <linux/ksm.h>
> +#include <linux/rmap.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/mmu_context.h>
> +#include <linux/memcontrol.h>
> +#include <linux/hmm.h>
> +#include <linux/wait.h>
> +#include <linux/mman.h>
> +#include <linux/delay.h>
> +#include <linux/workqueue.h>
> +
> +#include "internal.h"
> +
> +static struct mmu_notifier_ops hmm_notifier_ops;
> +
> +
> +/* hmm - core HMM functions.
> + *
> + * Core HMM functions that deal with all the process mm activities.
> + */
> +
> +static int hmm_init(struct hmm *hmm)
> +{
> +       hmm->mm =3D current->mm;
> +       hmm->vm_end =3D TASK_SIZE;
> +       kref_init(&hmm->kref);
> +       INIT_HLIST_HEAD(&hmm->mirrors);
> +       init_rwsem(&hmm->rwsem);
> +
> +       /* register notifier */
> +       hmm->mmu_notifier.ops =3D &hmm_notifier_ops;
> +       return __mmu_notifier_register(&hmm->mmu_notifier, current->mm);
> +}
> +
> +static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror)
> +{
> +       struct hmm_mirror *tmp;
> +
> +       down_write(&hmm->rwsem);
> +       hlist_for_each_entry(tmp, &hmm->mirrors, mlist)
> +               if (tmp->device =3D=3D mirror->device) {
> +                       /* Same device can mirror only once. */
> +                       up_write(&hmm->rwsem);
> +                       return -EINVAL;
> +               }
> +       hlist_add_head(&mirror->mlist, &hmm->mirrors);
> +       hmm_mirror_ref(mirror);
> +       up_write(&hmm->rwsem);
> +
> +       return 0;
> +}
> +
> +static inline struct hmm *hmm_ref(struct hmm *hmm)
> +{
> +       if (!hmm || !kref_get_unless_zero(&hmm->kref))

> +               return NULL;
> +       return hmm;
> +}
> +
> +static void hmm_destroy_delayed(struct rcu_head *rcu)
> +
> +       struct hmm *hmm;
> +
> +       hmm =3D container_of(rcu, struct hmm, rcu);
> +       kfree(hmm);
> +}
> +
> +static void hmm_destroy(struct kref *kref)
> +{
> +       struct hmm *hmm;
> +
> +       hmm =3D container_of(kref, struct hmm, kref);
> +       BUG_ON(!hlist_empty(&hmm->mirrors));
> +
> +       down_write(&hmm->mm->mmap_sem);
> +       /* A new hmm might have been register before reaching that point.
*/
> +       if (hmm->mm->hmm =3D=3D hmm)
> +               hmm->mm->hmm =3D NULL;
> +       up_write(&hmm->mm->mmap_sem);
> +
> +       mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
> +
> +       mmu_notifier_call_srcu(&hmm->rcu, &hmm_destroy_delayed);
> +}
> +
> +static inline struct hmm *hmm_unref(struct hmm *hmm)
> +{
> +       if (hmm)
> +               kref_put(&hmm->kref, hmm_destroy);
> +       return NULL;
> +}
> +
> +
> +/* hmm_notifier - HMM callback for mmu_notifier tracking change to
process mm.
> + *
> + * HMM use use mmu notifier to track change made to process address
space.
> + */
> +static void hmm_notifier_release(struct mmu_notifier *mn, struct
mm_struct *mm)
> +{
> +       struct hmm *hmm;
> +
> +       hmm =3D hmm_ref(container_of(mn, struct hmm, mmu_notifier));
> +       if (!hmm)
> +               return;
> +
> +       down_write(&hmm->rwsem);
> +       while (hmm->mirrors.first) {
> +               struct hmm_mirror *mirror;
> +
> +               /*
> +                * Here we are holding the mirror reference from the
mirror
> +                * list. As list removal is synchronized through rwsem, n=
o
> +                * other thread can assume it holds that reference.
> +                */
> +               mirror =3D hlist_entry(hmm->mirrors.first,
> +                                    struct hmm_mirror,
> +                                    mlist);
> +               hlist_del_init(&mirror->mlist);
> +               up_write(&hmm->rwsem);
> +
> +               mirror->device->ops->release(mirror);
> +               hmm_mirror_unref(&mirror);
> +
> +               down_write(&hmm->rwsem);
> +       }
> +       up_write(&hmm->rwsem);
> +
> +       hmm_unref(hmm);
> +}
> +
> +static struct mmu_notifier_ops hmm_notifier_ops =3D {
> +       .release                =3D hmm_notifier_release,
> +};
> +
> +
> +/* hmm_mirror - per device mirroring functions.
> + *
> + * Each device that mirror a process has a uniq hmm_mirror struct. A
process
> + * can be mirror by several devices at the same time.
> + *
> + * Below are all the functions and their helpers use by device driver to
mirror
> + * the process address space. Those functions either deals with updating
the
> + * device page table (through hmm callback). Or provide helper functions
use by
> + * the device driver to fault in range of memory in the device page
table.
> + */
> +struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror)
> +{
> +       if (!mirror || !kref_get_unless_zero(&mirror->kref))
> +               return NULL;
> +       return mirror;
> +}
> +EXPORT_SYMBOL(hmm_mirror_ref);
> +
> +static void hmm_mirror_destroy(struct kref *kref)
> +{
> +       struct hmm_device *device;
> +       struct hmm_mirror *mirror;
> +
> +       mirror =3D container_of(kref, struct hmm_mirror, kref);
> +       device =3D mirror->device;
> +
> +       hmm_unref(mirror->hmm);
> +
> +       spin_lock(&device->lock);
> +       list_del_init(&mirror->dlist);
> +       device->ops->free(mirror);
> +       spin_unlock(&device->lock);
> +}
> +
> +void hmm_mirror_unref(struct hmm_mirror **mirror)
> +{
> +       struct hmm_mirror *tmp =3D mirror ? *mirror : NULL;
> +
> +       if (tmp) {
> +               *mirror =3D NULL;
> +               kref_put(&tmp->kref, hmm_mirror_destroy);
> +       }
> +}
> +EXPORT_SYMBOL(hmm_mirror_unref);
> +
> +/* hmm_mirror_register() - register mirror against current process for a
device.
> + *
> + * @mirror: The mirror struct being registered.
> + * Returns: 0 on success or -ENOMEM, -EINVAL on error.
> + *
> + * Call when device driver want to start mirroring a process address
space. The
> + * HMM shim will register mmu_notifier and start monitoring process
address
> + * space changes. Hence callback to device driver might happen even
before this
> + * function return.
> + *
> + * The task device driver want to mirror must be current !
> + *
> + * Only one mirror per mm and hmm_device can be created, it will return
NULL if
> + * the hmm_device already has an hmm_mirror for the the mm.
> + */
> +int hmm_mirror_register(struct hmm_mirror *mirror)
> +{
> +       struct mm_struct *mm =3D current->mm;
> +       struct hmm *hmm =3D NULL;
> +       int ret =3D 0;
> +
> +       /* Sanity checks. */
> +       BUG_ON(!mirror);
> +       BUG_ON(!mirror->device);
> +       BUG_ON(!mm);
> +
> +       /*
> +        * Initialize the mirror struct fields, the mlist init and del
dance is
> +        * necessary to make the error path easier for driver and for hmm=
.
> +        */
> +       kref_init(&mirror->kref);
> +       INIT_HLIST_NODE(&mirror->mlist);
> +       INIT_LIST_HEAD(&mirror->dlist);
> +       spin_lock(&mirror->device->lock);
> +       list_add(&mirror->dlist, &mirror->device->mirrors);
> +       spin_unlock(&mirror->device->lock);
> +
> +       down_write(&mm->mmap_sem);
> +
> +       hmm =3D mm->hmm ? hmm_ref(hmm) : NULL;

Instead of hmm mm->hmm would be the right param to be passed.  Here even
though mm->hmm is true hmm_ref returns NULL. Because hmm is not updated
after initialization in the beginning.

> +       if (hmm =3D=3D NULL) {

General practice for NULL check in drivers is if(!hmm).

> +               /* no hmm registered yet so register one */
> +               hmm =3D kzalloc(sizeof(*mm->hmm), GFP_KERNEL);
> +               if (hmm =3D=3D NULL) {
> +                       up_write(&mm->mmap_sem);
> +                       ret =3D -ENOMEM;
> +                       goto error;
> +               }
> +
> +               ret =3D hmm_init(hmm);
> +               if (ret) {
> +                       up_write(&mm->mmap_sem);
> +                       kfree(hmm);
> +                       goto error;
> +               }
> +
> +               mm->hmm =3D hmm;
> +       }
> +
> +       mirror->hmm =3D hmm;
> +       ret =3D hmm_add_mirror(hmm, mirror);
> +       up_write(&mm->mmap_sem);
> +       if (ret) {
> +               mirror->hmm =3D NULL;
> +               hmm_unref(hmm);
> +               goto error;
> +       }
> +       return 0;
> +
> +error:
> +       spin_lock(&mirror->device->lock);
> +       list_del_init(&mirror->dlist);
> +       spin_unlock(&mirror->device->lock);
> +       return ret;
> +}
> +EXPORT_SYMBOL(hmm_mirror_register);
> +
> +static void hmm_mirror_kill(struct hmm_mirror *mirror)
> +{
> +       struct hmm_device *device =3D mirror->device;
> +       struct hmm *hmm =3D hmm_ref(mirror->hmm);
> +
> +       if (!hmm)
> +               return;
> +
> +       down_write(&hmm->rwsem);
> +       if (!hlist_unhashed(&mirror->mlist)) {
> +               hlist_del_init(&mirror->mlist);
> +               up_write(&hmm->rwsem);
> +               device->ops->release(mirror);
> +               hmm_mirror_unref(&mirror);
> +       } else
> +               up_write(&hmm->rwsem);
> +
> +       hmm_unref(hmm);
> +}
> +
> +/* hmm_mirror_unregister() - unregister a mirror.
> + *
> + * @mirror: The mirror that link process address space with the device.
> + *
> + * Driver can call this function when it wants to stop mirroring a
process.
> + * This will trigger a call to the ->release() callback if it did not
aleady
> + * happen.
> + *
> + * Note that caller must hold a reference on the mirror.
> + *
> + * THIS CAN NOT BE CALL FROM device->release() CALLBACK OR IT WILL
DEADLOCK.
> + */
> +void hmm_mirror_unregister(struct hmm_mirror *mirror)
> +{
> +       if (mirror =3D=3D NULL)
> +               return;
> +
> +       hmm_mirror_kill(mirror);
> +       mmu_notifier_synchronize();
> +       hmm_mirror_unref(&mirror);
> +}
> +EXPORT_SYMBOL(hmm_mirror_unregister);
> +
> +
> +/* hmm_device - Each device driver must register one and only one
hmm_device
> + *
> + * The hmm_device is the link btw HMM and each device driver.
> + */
> +
> +/* hmm_device_register() - register a device with HMM.
> + *
> + * @device: The hmm_device struct.
> + * Returns: 0 on success or -EINVAL otherwise.
> + *
> + *
> + * Call when device driver want to register itself with HMM. Device
driver must
> + * only register once.
> + */
> +int hmm_device_register(struct hmm_device *device)
> +{
> +       /* sanity check */
> +       BUG_ON(!device);
> +       BUG_ON(!device->ops);
> +       BUG_ON(!device->ops->release);
> +
> +       spin_lock_init(&device->lock);
> +       INIT_LIST_HEAD(&device->mirrors);
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(hmm_device_register);
> +
> +/* hmm_device_unregister() - unregister a device with HMM.
> + *
> + * @device: The hmm_device struct.
> + * Returns: 0 on success or -EBUSY otherwise.
> + *
> + * Call when device driver want to unregister itself with HMM. This will
check
> + * that there is no any active mirror and returns -EBUSY if so.
> + */
> +int hmm_device_unregister(struct hmm_device *device)
> +{
> +       spin_lock(&device->lock);
> +       if (!list_empty(&device->mirrors)) {
> +               spin_unlock(&device->lock);
> +               return -EBUSY;
> +       }
> +       spin_unlock(&device->lock);
> +       return 0;
> +}
> +EXPORT_SYMBOL(hmm_device_unregister);
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--001a113a346c6fbb6b051c636bb2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On 18-Jul-2015 12:47 am, &quot;J=C3=A9r=C3=B4me Glisse&quot; &lt;<a href=3D=
"mailto:jglisse@redhat.com">jglisse@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; This patch only introduce core HMM functions for registering a new<br>
&gt; mirror and stopping a mirror as well as HMM device registering and<br>
&gt; unregistering.<br>
&gt;<br>
&gt; The lifecycle of HMM object is handled differently then the one of<br>
&gt; mmu_notifier because unlike mmu_notifier there can be concurrent<br>
&gt; call from both mm code to HMM code and/or from device driver code<br>
&gt; to HMM code. Moreover lifetime of HMM can be uncorrelated from the<br>
&gt; lifetime of the process that is being mirror (GPU might take longer<br=
>
&gt; time to cleanup).<br>
&gt;<br>
&gt; Changed since v1:<br>
&gt; =C2=A0 - Updated comment of hmm_device_register().<br>
&gt;<br>
&gt; Changed since v2:<br>
&gt; =C2=A0 - Expose struct hmm for easy access to mm struct.<br>
&gt; =C2=A0 - Simplify hmm_mirror_register() arguments.<br>
&gt; =C2=A0 - Removed the device name.<br>
&gt; =C2=A0 - Refcount the mirror struct internaly to HMM allowing to get<b=
r>
&gt; =C2=A0 =C2=A0 rid of the srcu and making the device driver callback er=
ror<br>
&gt; =C2=A0 =C2=A0 handling simpler.<br>
&gt; =C2=A0 - Safe to call several time hmm_mirror_unregister().<br>
&gt; =C2=A0 - Rework the mmu_notifier unregistration and release callback.<=
br>
&gt;<br>
&gt; Changed since v3:<br>
&gt; =C2=A0 - Rework hmm_mirror lifetime rules.<br>
&gt; =C2=A0 - Synchronize with mmu_notifier srcu before droping mirror last=
<br>
&gt; =C2=A0 =C2=A0 reference in hmm_mirror_unregister()<br>
&gt; =C2=A0 - Use spinlock for device&#39;s mirror list.<br>
&gt; =C2=A0 - Export mirror ref/unref functions.<br>
&gt; =C2=A0 - English syntax fixes.<br>
&gt;<br>
&gt; Signed-off-by: J=C3=A9r=C3=B4me Glisse &lt;<a href=3D"mailto:jglisse@r=
edhat.com">jglisse@redhat.com</a>&gt;<br>
&gt; Signed-off-by: Sherry Cheung &lt;<a href=3D"mailto:SCheung@nvidia.com"=
>SCheung@nvidia.com</a>&gt;<br>
&gt; Signed-off-by: Subhash Gutti &lt;<a href=3D"mailto:sgutti@nvidia.com">=
sgutti@nvidia.com</a>&gt;<br>
&gt; Signed-off-by: Mark Hairgrove &lt;<a href=3D"mailto:mhairgrove@nvidia.=
com">mhairgrove@nvidia.com</a>&gt;<br>
&gt; Signed-off-by: John Hubbard &lt;<a href=3D"mailto:jhubbard@nvidia.com"=
>jhubbard@nvidia.com</a>&gt;<br>
&gt; Signed-off-by: Jatin Kumar &lt;<a href=3D"mailto:jakumar@nvidia.com">j=
akumar@nvidia.com</a>&gt;<br>
&gt; ---<br>
&gt; =C2=A0MAINTAINERS=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 =C2=A07 +<br>
&gt; =C2=A0include/linux/hmm.h=C2=A0 =C2=A0 =C2=A0 | 173 ++++++++++++++++++=
+++<br>
&gt; =C2=A0include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 11 ++<br>
&gt; =C2=A0include/linux/mm_types.h |=C2=A0 14 ++<br>
&gt; =C2=A0kernel/fork.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =
=C2=A02 +<br>
&gt; =C2=A0mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 14 ++<br>
&gt; =C2=A0mm/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 =C2=A01 +<br>
&gt; =C2=A0mm/hmm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| 381 +++++++++++++++++++++++++++++++++++++++++++++++<br>
&gt; =C2=A08 files changed, 603 insertions(+)<br>
&gt; =C2=A0create mode 100644 include/linux/hmm.h<br>
&gt; =C2=A0create mode 100644 mm/hmm.c<br>
&gt;<br>
&gt; diff --git a/MAINTAINERS b/MAINTAINERS<br>
&gt; index 2d3d55c..8ebdc17 100644<br>
&gt; --- a/MAINTAINERS<br>
&gt; +++ b/MAINTAINERS<br>
&gt; @@ -4870,6 +4870,13 @@ F:=C2=A0 =C2=A0 =C2=A0 =C2=A0include/uapi/linux=
/if_hippi.h<br>
&gt; =C2=A0F:=C2=A0 =C2=A0 =C2=A0net/802/hippi.c<br>
&gt; =C2=A0F:=C2=A0 =C2=A0 =C2=A0drivers/net/hippi/<br>
&gt;<br>
&gt; +HMM - Heterogeneous Memory Management<br>
&gt; +M:=C2=A0 =C2=A0 =C2=A0J=C3=A9r=C3=B4me Glisse &lt;<a href=3D"mailto:j=
glisse@redhat.com">jglisse@redhat.com</a>&gt;<br>
&gt; +L:=C2=A0 =C2=A0 =C2=A0<a href=3D"mailto:linux-mm@kvack.org">linux-mm@=
kvack.org</a><br>
&gt; +S:=C2=A0 =C2=A0 =C2=A0Maintained<br>
&gt; +F:=C2=A0 =C2=A0 =C2=A0mm/hmm.c<br>
&gt; +F:=C2=A0 =C2=A0 =C2=A0include/linux/hmm.h<br>
&gt; +<br>
&gt; =C2=A0HOST AP DRIVER<br>
&gt; =C2=A0M:=C2=A0 =C2=A0 =C2=A0Jouni Malinen &lt;<a href=3D"mailto:j@w1.f=
i">j@w1.fi</a>&gt;<br>
&gt; =C2=A0L:=C2=A0 =C2=A0 =C2=A0<a href=3D"mailto:hostap@shmoo.com">hostap=
@shmoo.com</a> (subscribers-only)<br>
&gt; diff --git a/include/linux/hmm.h b/include/linux/hmm.h<br>
&gt; new file mode 100644<br>
&gt; index 0000000..b559c0b<br>
&gt; --- /dev/null<br>
&gt; +++ b/include/linux/hmm.h<br>
&gt; @@ -0,0 +1,173 @@<br>
&gt; +/*<br>
&gt; + * Copyright 2013 Red Hat Inc.<br>
&gt; + *<br>
&gt; + * This program is free software; you can redistribute it and/or modi=
fy<br>
&gt; + * it under the terms of the GNU General Public License as published =
by<br>
&gt; + * the Free Software Foundation; either version 2 of the License, or<=
br>
&gt; + * (at your option) any later version.<br>
&gt; + *<br>
&gt; + * This program is distributed in the hope that it will be useful,<br=
>
&gt; + * but WITHOUT ANY WARRANTY; without even the implied warranty of<br>
&gt; + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.=C2=A0 See the=
<br>
&gt; + * GNU General Public License for more details.<br>
&gt; + *<br>
&gt; + * Authors: J=C3=A9r=C3=B4me Glisse &lt;<a href=3D"mailto:jglisse@red=
hat.com">jglisse@redhat.com</a>&gt;<br>
&gt; + */<br>
&gt; +/* This is a heterogeneous memory management (hmm). In a nutshell thi=
s provide<br>
&gt; + * an API to mirror a process address on a device which has its own m=
mu using<br>
&gt; + * its own page table for the process. It supports everything except =
special<br>
&gt; + * vma.<br>
&gt; + *<br>
&gt; + * Mandatory hardware features :<br>
&gt; + *=C2=A0 =C2=A0- An mmu with pagetable.<br>
&gt; + *=C2=A0 =C2=A0- Read only flag per cpu page.<br>
&gt; + *=C2=A0 =C2=A0- Page fault ie hardware must stop and wait for kernel=
 to service fault.<br>
&gt; + *<br>
&gt; + * Optional hardware features :<br>
&gt; + *=C2=A0 =C2=A0- Dirty bit per cpu page.<br>
&gt; + *=C2=A0 =C2=A0- Access bit per cpu page.<br>
&gt; + *<br>
&gt; + * The hmm code handle all the interfacing with the core kernel mm co=
de and<br>
&gt; + * provide a simple API. It does support migrating system memory to d=
evice<br>
&gt; + * memory and handle migration back to system memory on cpu page faul=
t.<br>
&gt; + *<br>
&gt; + * Migrated memory is considered as swaped from cpu and core mm code =
point of<br>
&gt; + * view.<br>
&gt; + */<br>
&gt; +#ifndef _HMM_H<br>
&gt; +#define _HMM_H<br>
&gt; +<br>
&gt; +#ifdef CONFIG_HMM<br>
&gt; +<br>
&gt; +#include &lt;linux/list.h&gt;<br>
&gt; +#include &lt;linux/spinlock.h&gt;<br>
&gt; +#include &lt;linux/atomic.h&gt;<br>
&gt; +#include &lt;linux/mm_types.h&gt;<br>
&gt; +#include &lt;linux/mmu_notifier.h&gt;<br>
&gt; +#include &lt;linux/workqueue.h&gt;<br>
&gt; +#include &lt;linux/mman.h&gt;<br>
&gt; +<br>
&gt; +<br>
&gt; +struct hmm_device;<br>
&gt; +struct hmm_mirror;<br>
&gt; +struct hmm;<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm_device - Each device must register one and only one hmm_device=
.<br>
&gt; + *<br>
&gt; + * The hmm_device is the link btw HMM and each device driver.<br>
&gt; + */<br>
&gt; +<br>
&gt; +/* struct hmm_device_operations - HMM device operation callback<br>
&gt; + */<br>
&gt; +struct hmm_device_ops {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* release() - mirror must stop using the =
address space.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * @mirror: The mirror that link process a=
ddress space with the device.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * When this is called, device driver must=
 kill all device thread using<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * this mirror. It is call either from :<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *=C2=A0 =C2=A0- mm dying (all process usi=
ng this mm exiting).<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *=C2=A0 =C2=A0- hmm_mirror_unregister() (=
if no other thread holds a reference)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *=C2=A0 =C2=A0- outcome of some device er=
ror reported by any of the device<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *=C2=A0 =C2=A0 =C2=A0callback against tha=
t mirror.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0void (*release)(struct hmm_mirror *mirror)=
;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* free() - mirror can be freed.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * @mirror: The mirror that link process a=
ddress space with the device.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * When this is called, device driver can =
free the underlying memory<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * associated with that mirror. Note this =
is call from atomic context<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * so device driver callback can not sleep=
.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0void (*free)(struct hmm_mirror *mirror);<b=
r>
&gt; +};<br>
&gt; +<br>
&gt; +<br>
&gt; +/* struct hmm - per mm_struct HMM states.<br>
&gt; + *<br>
&gt; + * @mm: The mm struct this hmm is associated with.<br>
&gt; + * @mirrors: List of all mirror for this mm (one per device).<br>
&gt; + * @vm_end: Last valid address for this mm (exclusive).<br>
&gt; + * @kref: Reference counter.<br>
&gt; + * @rwsem: Serialize the mirror list modifications.<br>
&gt; + * @mmu_notifier: The mmu_notifier of this mm.<br>
&gt; + * @rcu: For delayed cleanup call from mmu_notifier.release() callbac=
k.<br>
&gt; + *<br>
&gt; + * For each process address space (mm_struct) there is one and only o=
ne hmm<br>
&gt; + * struct. hmm functions will redispatch to each devices the change m=
ade to<br>
&gt; + * the process address space.<br>
&gt; + *<br>
&gt; + * Device driver must not access this structure other than for gettin=
g the<br>
&gt; + * mm pointer.<br>
&gt; + */<br>
&gt; +struct hmm {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 *mm;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hlist_head=C2=A0 =C2=A0 =C2=A0 =C2=
=A0mirrors;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0vm_end;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct kref=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0kref;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct rw_semaphore=C2=A0 =C2=A0 =C2=A0rws=
em;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mmu_notifier=C2=A0 =C2=A0 =C2=A0mmu=
_notifier;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct rcu_head=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0rcu;<br>
&gt; +};<br>
&gt; +<br>
&gt; +<br>
&gt; +/* struct hmm_device - per device HMM structure<br>
&gt; + *<br>
&gt; + * @dev: Linux device structure pointer.<br>
&gt; + * @ops: The hmm operations callback.<br>
&gt; + * @mirrors: List of all active mirrors for the device.<br>
&gt; + * @lock: Lock protecting mirrors list.<br>
&gt; + *<br>
&gt; + * Each device that want to mirror an address space must register one=
 of this<br>
&gt; + * struct (only once per linux device).<br>
&gt; + */<br>
&gt; +struct hmm_device {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct device=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*dev;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0const struct hmm_device_ops=C2=A0 =C2=A0 =
=C2=A0*ops;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mirrors;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock;<br>
&gt; +};<br>
&gt; +<br>
&gt; +int hmm_device_register(struct hmm_device *device);<br>
&gt; +int hmm_device_unregister(struct hmm_device *device);<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm_mirror - device specific mirroring functions.<br>
&gt; + *<br>
&gt; + * Each device that mirror a process has a uniq hmm_mirror struct ass=
ociating<br>
&gt; + * the process address space with the device. Same process can be mir=
rored by<br>
&gt; + * several different devices at the same time.<br>
&gt; + */<br>
&gt; +<br>
&gt; +/* struct hmm_mirror - per device and per mm HMM structure<br>
&gt; + *<br>
&gt; + * @device: The hmm_device struct this hmm_mirror is associated to.<b=
r>
&gt; + * @hmm: The hmm struct this hmm_mirror is associated to.<br>
&gt; + * @kref: Reference counter (private to HMM do not use).<br>
&gt; + * @dlist: List of all hmm_mirror for same device.<br>
&gt; + * @mlist: List of all hmm_mirror for same process.<br>
&gt; + *<br>
&gt; + * Each device that want to mirror an address space must register one=
 of this<br>
&gt; + * struct for each of the address space it wants to mirror. Same devi=
ce can<br>
&gt; + * mirror several different address space. As well same address space=
 can be<br>
&gt; + * mirror by different devices.<br>
&gt; + */<br>
&gt; +struct hmm_mirror {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_device=C2=A0 =C2=A0 =C2=A0 =C2=
=A0*device;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 *hmm;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct kref=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0kref;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 dlist;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hlist_node=C2=A0 =C2=A0 =C2=A0 =C2=
=A0mlist;<br>
&gt; +};<br>
&gt; +<br>
&gt; +int hmm_mirror_register(struct hmm_mirror *mirror);<br>
&gt; +void hmm_mirror_unregister(struct hmm_mirror *mirror);<br>
&gt; +struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);<br>
&gt; +void hmm_mirror_unref(struct hmm_mirror **mirror);<br>
&gt; +<br>
&gt; +<br>
&gt; +#endif /* CONFIG_HMM */<br>
&gt; +#endif<br>
&gt; diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
&gt; index 2e872f9..b5bf210 100644<br>
&gt; --- a/include/linux/mm.h<br>
&gt; +++ b/include/linux/mm.h<br>
&gt; @@ -2243,5 +2243,16 @@ void __init setup_nr_node_ids(void);<br>
&gt; =C2=A0static inline void setup_nr_node_ids(void) {}<br>
&gt; =C2=A0#endif<br>
&gt;<br>
&gt; +#ifdef CONFIG_HMM<br>
&gt; +static inline void hmm_mm_init(struct mm_struct *mm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mm-&gt;hmm =3D NULL;<br>
&gt; +}<br>
&gt; +#else /* !CONFIG_HMM */<br>
&gt; +static inline void hmm_mm_init(struct mm_struct *mm)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +#endif /* !CONFIG_HMM */<br>
&gt; +<br>
&gt; =C2=A0#endif /* __KERNEL__ */<br>
&gt; =C2=A0#endif /* _LINUX_MM_H */<br>
&gt; diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h<br>
&gt; index 0038ac7..fa05917 100644<br>
&gt; --- a/include/linux/mm_types.h<br>
&gt; +++ b/include/linux/mm_types.h<br>
&gt; @@ -15,6 +15,10 @@<br>
&gt; =C2=A0#include &lt;asm/page.h&gt;<br>
&gt; =C2=A0#include &lt;asm/mmu.h&gt;<br>
&gt;<br>
&gt; +#ifdef CONFIG_HMM<br>
&gt; +struct hmm;<br>
&gt; +#endif<br>
&gt; +<br>
&gt; =C2=A0#ifndef AT_VECTOR_SIZE_ARCH<br>
&gt; =C2=A0#define AT_VECTOR_SIZE_ARCH 0<br>
&gt; =C2=A0#endif<br>
&gt; @@ -451,6 +455,16 @@ struct mm_struct {<br>
&gt; =C2=A0#ifdef CONFIG_MMU_NOTIFIER<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mmu_notifier_mm *mmu_notifier_mm;<b=
r>
&gt; =C2=A0#endif<br>
&gt; +#ifdef CONFIG_HMM<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * hmm always register an mmu_notifier we =
rely on mmu notifier to keep<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * refcount on mm struct as well as forbid=
ing registering hmm on a<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * dying mm<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * This field is set with mmap_sem held in=
 write mode.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm;<br>
&gt; +#endif<br>
&gt; =C2=A0#if defined(CONFIG_TRANSPARENT_HUGEPAGE) &amp;&amp; !USE_SPLIT_P=
MD_PTLOCKS<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgtable_t pmd_huge_pte; /* protected by pa=
ge_table_lock */<br>
&gt; =C2=A0#endif<br>
&gt; diff --git a/kernel/fork.c b/kernel/fork.c<br>
&gt; index 1bfefc6..0d1f446 100644<br>
&gt; --- a/kernel/fork.c<br>
&gt; +++ b/kernel/fork.c<br>
&gt; @@ -27,6 +27,7 @@<br>
&gt; =C2=A0#include &lt;linux/binfmts.h&gt;<br>
&gt; =C2=A0#include &lt;linux/mman.h&gt;<br>
&gt; =C2=A0#include &lt;linux/mmu_notifier.h&gt;<br>
&gt; +#include &lt;linux/hmm.h&gt;<br>
&gt; =C2=A0#include &lt;linux/fs.h&gt;<br>
&gt; =C2=A0#include &lt;linux/mm.h&gt;<br>
&gt; =C2=A0#include &lt;linux/vmacache.h&gt;<br>
&gt; @@ -597,6 +598,7 @@ static struct mm_struct *mm_init(struct mm_struct =
*mm, struct task_struct *p)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm_init_aio(mm);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm_init_owner(mm, p);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 mmu_notifier_mm_init(mm);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mm_init(mm);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 clear_tlb_flush_pending(mm);<br>
&gt; =C2=A0#if defined(CONFIG_TRANSPARENT_HUGEPAGE) &amp;&amp; !USE_SPLIT_P=
MD_PTLOCKS<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm-&gt;pmd_huge_pte =3D NULL;<br>
&gt; diff --git a/mm/Kconfig b/mm/Kconfig<br>
&gt; index e79de2b..e1e0a82 100644<br>
&gt; --- a/mm/Kconfig<br>
&gt; +++ b/mm/Kconfig<br>
&gt; @@ -654,3 +654,17 @@ config DEFERRED_STRUCT_PAGE_INIT<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 when kswapd starts. This has a pote=
ntial performance impact on<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 processes running early in the life=
time of the systemm until kswapd<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 finishes the initialisation.<br>
&gt; +<br>
&gt; +if STAGING<br>
&gt; +config HMM<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0bool &quot;Enable heterogeneous memory man=
agement (HMM)&quot;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0depends on MMU<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0select MMU_NOTIFIER<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0default n<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Heterogeneous memory management pro=
vide infrastructure for a device<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0to mirror a process address space i=
nto an hardware mmu or into any<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0things supporting pagefault like ev=
ent.<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0If unsure, say N to disable hmm.<br=
>
&gt; +endif # STAGING<br>
&gt; diff --git a/mm/Makefile b/mm/Makefile<br>
&gt; index 98c4eae..90ca9c4 100644<br>
&gt; --- a/mm/Makefile<br>
&gt; +++ b/mm/Makefile<br>
&gt; @@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)=C2=A0 =C2=A0 =C2=A0+=3D cma.o<br>
&gt; =C2=A0obj-$(CONFIG_MEMORY_BALLOON) +=3D balloon_compaction.o<br>
&gt; =C2=A0obj-$(CONFIG_PAGE_EXTENSION) +=3D page_ext.o<br>
&gt; =C2=A0obj-$(CONFIG_CMA_DEBUGFS) +=3D cma_debug.o<br>
&gt; +obj-$(CONFIG_HMM) +=3D hmm.o<br>
&gt; diff --git a/mm/hmm.c b/mm/hmm.c<br>
&gt; new file mode 100644<br>
&gt; index 0000000..198fe37<br>
&gt; --- /dev/null<br>
&gt; +++ b/mm/hmm.c<br>
&gt; @@ -0,0 +1,381 @@<br>
&gt; +/*<br>
&gt; + * Copyright 2013 Red Hat Inc.<br>
&gt; + *<br>
&gt; + * This program is free software; you can redistribute it and/or modi=
fy<br>
&gt; + * it under the terms of the GNU General Public License as published =
by<br>
&gt; + * the Free Software Foundation; either version 2 of the License, or<=
br>
&gt; + * (at your option) any later version.<br>
&gt; + *<br>
&gt; + * This program is distributed in the hope that it will be useful,<br=
>
&gt; + * but WITHOUT ANY WARRANTY; without even the implied warranty of<br>
&gt; + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.=C2=A0 See the=
<br>
&gt; + * GNU General Public License for more details.<br>
&gt; + *<br>
&gt; + * Authors: J=C3=A9r=C3=B4me Glisse &lt;<a href=3D"mailto:jglisse@red=
hat.com">jglisse@redhat.com</a>&gt;<br>
&gt; + */<br>
&gt; +/* This is the core code for heterogeneous memory management (HMM). H=
MM intend<br>
&gt; + * to provide helper for mirroring a process address space on a devic=
e as well<br>
&gt; + * as allowing migration of data between system memory and device mem=
ory refer<br>
&gt; + * as remote memory from here on out.<br>
&gt; + *<br>
&gt; + * Refer to include/linux/hmm.h for further information on general de=
sign.<br>
&gt; + */<br>
&gt; +#include &lt;linux/export.h&gt;<br>
&gt; +#include &lt;linux/bitmap.h&gt;<br>
&gt; +#include &lt;linux/list.h&gt;<br>
&gt; +#include &lt;linux/rculist.h&gt;<br>
&gt; +#include &lt;linux/slab.h&gt;<br>
&gt; +#include &lt;linux/mmu_notifier.h&gt;<br>
&gt; +#include &lt;linux/mm.h&gt;<br>
&gt; +#include &lt;linux/hugetlb.h&gt;<br>
&gt; +#include &lt;linux/fs.h&gt;<br>
&gt; +#include &lt;linux/file.h&gt;<br>
&gt; +#include &lt;linux/ksm.h&gt;<br>
&gt; +#include &lt;linux/rmap.h&gt;<br>
&gt; +#include &lt;linux/swap.h&gt;<br>
&gt; +#include &lt;linux/swapops.h&gt;<br>
&gt; +#include &lt;linux/mmu_context.h&gt;<br>
&gt; +#include &lt;linux/memcontrol.h&gt;<br>
&gt; +#include &lt;linux/hmm.h&gt;<br>
&gt; +#include &lt;linux/wait.h&gt;<br>
&gt; +#include &lt;linux/mman.h&gt;<br>
&gt; +#include &lt;linux/delay.h&gt;<br>
&gt; +#include &lt;linux/workqueue.h&gt;<br>
&gt; +<br>
&gt; +#include &quot;internal.h&quot;<br>
&gt; +<br>
&gt; +static struct mmu_notifier_ops hmm_notifier_ops;<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm - core HMM functions.<br>
&gt; + *<br>
&gt; + * Core HMM functions that deal with all the process mm activities.<b=
r>
&gt; + */<br>
&gt; +<br>
&gt; +static int hmm_init(struct hmm *hmm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm-&gt;mm =3D current-&gt;mm;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm-&gt;vm_end =3D TASK_SIZE;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kref_init(&amp;hmm-&gt;kref);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_HLIST_HEAD(&amp;hmm-&gt;mirrors);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0init_rwsem(&amp;hmm-&gt;rwsem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* register notifier */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm-&gt;mmu_notifier.ops =3D &amp;hmm_noti=
fier_ops;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return __mmu_notifier_register(&amp;hmm-&g=
t;mmu_notifier, current-&gt;mm);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror)=
<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_mirror *tmp;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&amp;hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hlist_for_each_entry(tmp, &amp;hmm-&gt;mir=
rors, mlist)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (tmp-&gt;de=
vice =3D=3D mirror-&gt;device) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Same device can mirror only once. */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0up_write(&amp;hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EINVAL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hlist_add_head(&amp;mirror-&gt;mlist, &amp=
;hmm-&gt;mirrors);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mirror_ref(mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;hmm-&gt;rwsem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline struct hmm *hmm_ref(struct hmm *hmm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!hmm || !kref_get_unless_zero(&amp;hmm=
-&gt;kref))</p>
<p dir=3D"ltr">&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0return NULL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return hmm;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static void hmm_destroy_delayed(struct rcu_head *rcu)<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm =3D container_of(rcu, struct hmm, rcu)=
;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kfree(hmm);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static void hmm_destroy(struct kref *kref)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm =3D container_of(kref, struct hmm, kre=
f);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!hlist_empty(&amp;hmm-&gt;mirrors))=
;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&amp;hmm-&gt;mm-&gt;mmap_sem);<=
br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* A new hmm might have been register befo=
re reaching that point. */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (hmm-&gt;mm-&gt;hmm =3D=3D hmm)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hmm-&gt;mm-&gt=
;hmm =3D NULL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;hmm-&gt;mm-&gt;mmap_sem);<br=
>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mmu_notifier_unregister_no_release(&amp;hm=
m-&gt;mmu_notifier, hmm-&gt;mm);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mmu_notifier_call_srcu(&amp;hmm-&gt;rcu, &=
amp;hmm_destroy_delayed);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline struct hmm *hmm_unref(struct hmm *hmm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (hmm)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kref_put(&amp;=
hmm-&gt;kref, hmm_destroy);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
&gt; +}<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm_notifier - HMM callback for mmu_notifier tracking change to pr=
ocess mm.<br>
&gt; + *<br>
&gt; + * HMM use use mmu notifier to track change made to process address s=
pace.<br>
&gt; + */<br>
&gt; +static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_s=
truct *mm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm =3D hmm_ref(container_of(mn, struct hm=
m, mmu_notifier));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!hmm)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&amp;hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0while (hmm-&gt;mirrors.first) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_mir=
ror *mirror;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Here we are=
 holding the mirror reference from the mirror<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * list. As li=
st removal is synchronized through rwsem, no<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * other threa=
d can assume it holds that reference.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mirror =3D hli=
st_entry(hmm-&gt;mirrors.first,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hmm_mirror,=
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hlist_del_init=
(&amp;mirror-&gt;mlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;=
hmm-&gt;rwsem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mirror-&gt;dev=
ice-&gt;ops-&gt;release(mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mirror_unr=
ef(&amp;mirror);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&am=
p;hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;hmm-&gt;rwsem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_unref(hmm);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static struct mmu_notifier_ops hmm_notifier_ops =3D {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0.release=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =3D hmm_notifier_release,<br>
&gt; +};<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm_mirror - per device mirroring functions.<br>
&gt; + *<br>
&gt; + * Each device that mirror a process has a uniq hmm_mirror struct. A =
process<br>
&gt; + * can be mirror by several devices at the same time.<br>
&gt; + *<br>
&gt; + * Below are all the functions and their helpers use by device driver=
 to mirror<br>
&gt; + * the process address space. Those functions either deals with updat=
ing the<br>
&gt; + * device page table (through hmm callback). Or provide helper functi=
ons use by<br>
&gt; + * the device driver to fault in range of memory in the device page t=
able.<br>
&gt; + */<br>
&gt; +struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mirror || !kref_get_unless_zero(&amp;=
mirror-&gt;kref))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return mirror;<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_mirror_ref);<br>
&gt; +<br>
&gt; +static void hmm_mirror_destroy(struct kref *kref)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_device *device;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_mirror *mirror;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mirror =3D container_of(kref, struct hmm_m=
irror, kref);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0device =3D mirror-&gt;device;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_unref(mirror-&gt;hmm);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;device-&gt;lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0list_del_init(&amp;mirror-&gt;dlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0device-&gt;ops-&gt;free(mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;device-&gt;lock);<br>
&gt; +}<br>
&gt; +<br>
&gt; +void hmm_mirror_unref(struct hmm_mirror **mirror)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_mirror *tmp =3D mirror ? *mirro=
r : NULL;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tmp) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*mirror =3D NU=
LL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kref_put(&amp;=
tmp-&gt;kref, hmm_mirror_destroy);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_mirror_unref);<br>
&gt; +<br>
&gt; +/* hmm_mirror_register() - register mirror against current process fo=
r a device.<br>
&gt; + *<br>
&gt; + * @mirror: The mirror struct being registered.<br>
&gt; + * Returns: 0 on success or -ENOMEM, -EINVAL on error.<br>
&gt; + *<br>
&gt; + * Call when device driver want to start mirroring a process address =
space. The<br>
&gt; + * HMM shim will register mmu_notifier and start monitoring process a=
ddress<br>
&gt; + * space changes. Hence callback to device driver might happen even b=
efore this<br>
&gt; + * function return.<br>
&gt; + *<br>
&gt; + * The task device driver want to mirror must be current !<br>
&gt; + *<br>
&gt; + * Only one mirror per mm and hmm_device can be created, it will retu=
rn NULL if<br>
&gt; + * the hmm_device already has an hmm_mirror for the the mm.<br>
&gt; + */<br>
&gt; +int hmm_mirror_register(struct hmm_mirror *mirror)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D current-&gt;mm;<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm =3D NULL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sanity checks. */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!mirror-&gt;device);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!mm);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Initialize the mirror struct fields, th=
e mlist init and del dance is<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * necessary to make the error path easier=
 for driver and for hmm.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0kref_init(&amp;mirror-&gt;kref);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_HLIST_NODE(&amp;mirror-&gt;mlist);<br=
>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&amp;mirror-&gt;dlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;mirror-&gt;device-&gt;lock)=
;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&amp;mirror-&gt;dlist, &amp;mirro=
r-&gt;device-&gt;mirrors);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;mirror-&gt;device-&gt;loc=
k);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&amp;mm-&gt;mmap_sem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm =3D mm-&gt;hmm ? hmm_ref(hmm) : NULL;<=
/p>
<p dir=3D"ltr">Instead of hmm mm-&gt;hmm would be the right param to be pas=
sed.=C2=A0 Here even though mm-&gt;hmm is true hmm_ref returns NULL. Becaus=
e hmm is not updated after initialization in the beginning.</p>
<p dir=3D"ltr">&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (hmm =3D=3D NULL) {</p>
<p dir=3D"ltr">General practice for NULL check in drivers is if(!hmm).=C2=
=A0</p>
<p dir=3D"ltr">&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* no hmm registered yet so register one */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hmm =3D kzallo=
c(sizeof(*mm-&gt;hmm), GFP_KERNEL);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (hmm =3D=3D=
 NULL) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0up_write(&amp;mm-&gt;mmap_sem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0ret =3D -ENOMEM;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto error;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D hmm_in=
it(hmm);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0up_write(&amp;mm-&gt;mmap_sem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0kfree(hmm);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto error;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mm-&gt;hmm =3D=
 hmm;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mirror-&gt;hmm =3D hmm;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D hmm_add_mirror(hmm, mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;mm-&gt;mmap_sem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mirror-&gt;hmm=
 =3D NULL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_unref(hmm)=
;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto error;<br=
>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
&gt; +<br>
&gt; +error:<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;mirror-&gt;device-&gt;lock)=
;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0list_del_init(&amp;mirror-&gt;dlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;mirror-&gt;device-&gt;loc=
k);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_mirror_register);<br>
&gt; +<br>
&gt; +static void hmm_mirror_kill(struct hmm_mirror *mirror)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm_device *device =3D mirror-&gt;d=
evice;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct hmm *hmm =3D hmm_ref(mirror-&gt;hmm=
);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!hmm)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&amp;hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!hlist_unhashed(&amp;mirror-&gt;mlist)=
) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hlist_del_init=
(&amp;mirror-&gt;mlist);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;=
hmm-&gt;rwsem);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0device-&gt;ops=
-&gt;release(mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mirror_unr=
ef(&amp;mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0} else<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&amp;=
hmm-&gt;rwsem);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_unref(hmm);<br>
&gt; +}<br>
&gt; +<br>
&gt; +/* hmm_mirror_unregister() - unregister a mirror.<br>
&gt; + *<br>
&gt; + * @mirror: The mirror that link process address space with the devic=
e.<br>
&gt; + *<br>
&gt; + * Driver can call this function when it wants to stop mirroring a pr=
ocess.<br>
&gt; + * This will trigger a call to the -&gt;release() callback if it did =
not aleady<br>
&gt; + * happen.<br>
&gt; + *<br>
&gt; + * Note that caller must hold a reference on the mirror.<br>
&gt; + *<br>
&gt; + * THIS CAN NOT BE CALL FROM device-&gt;release() CALLBACK OR IT WILL=
 DEADLOCK.<br>
&gt; + */<br>
&gt; +void hmm_mirror_unregister(struct hmm_mirror *mirror)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mirror =3D=3D NULL)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mirror_kill(mirror);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0mmu_notifier_synchronize();<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0hmm_mirror_unref(&amp;mirror);<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_mirror_unregister);<br>
&gt; +<br>
&gt; +<br>
&gt; +/* hmm_device - Each device driver must register one and only one hmm=
_device<br>
&gt; + *<br>
&gt; + * The hmm_device is the link btw HMM and each device driver.<br>
&gt; + */<br>
&gt; +<br>
&gt; +/* hmm_device_register() - register a device with HMM.<br>
&gt; + *<br>
&gt; + * @device: The hmm_device struct.<br>
&gt; + * Returns: 0 on success or -EINVAL otherwise.<br>
&gt; + *<br>
&gt; + *<br>
&gt; + * Call when device driver want to register itself with HMM. Device d=
river must<br>
&gt; + * only register once.<br>
&gt; + */<br>
&gt; +int hmm_device_register(struct hmm_device *device)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0/* sanity check */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!device);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!device-&gt;ops);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!device-&gt;ops-&gt;release);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&amp;device-&gt;lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&amp;device-&gt;mirrors);<b=
r>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_device_register);<br>
&gt; +<br>
&gt; +/* hmm_device_unregister() - unregister a device with HMM.<br>
&gt; + *<br>
&gt; + * @device: The hmm_device struct.<br>
&gt; + * Returns: 0 on success or -EBUSY otherwise.<br>
&gt; + *<br>
&gt; + * Call when device driver want to unregister itself with HMM. This w=
ill check<br>
&gt; + * that there is no any active mirror and returns -EBUSY if so.<br>
&gt; + */<br>
&gt; +int hmm_device_unregister(struct hmm_device *device)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;device-&gt;lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empty(&amp;device-&gt;mirrors)) =
{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&a=
mp;device-&gt;lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EBUSY;=
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;device-&gt;lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
&gt; +}<br>
&gt; +EXPORT_SYMBOL(hmm_device_unregister);<br>
&gt; --<br>
&gt; 1.9.3<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-k=
ernel&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>
&gt; More majordomo info at=C2=A0 <a href=3D"http://vger.kernel.org/majordo=
mo-info.html">http://vger.kernel.org/majordomo-info.html</a><br>
&gt; Please read the FAQ at=C2=A0 <a href=3D"http://www.tux.org/lkml/">http=
://www.tux.org/lkml/</a><br>
</p>

--001a113a346c6fbb6b051c636bb2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
