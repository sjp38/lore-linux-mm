Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA366B025E
	for <linux-mm@kvack.org>; Sat, 23 Sep 2017 04:36:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b195so3309453wmb.6
        for <linux-mm@kvack.org>; Sat, 23 Sep 2017 01:36:24 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id d4si1213835wrf.511.2017.09.23.01.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Sep 2017 01:36:23 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170922173252.10137-3-matthew.auld@intel.com>
References: <20170922173252.10137-1-matthew.auld@intel.com>
 <20170922173252.10137-3-matthew.auld@intel.com>
Message-ID: <150615577925.24071.17558835162953494919@mail.alporthouse.com>
Subject: Re: [PATCH 02/21] drm/i915: introduce simple gemfs
Date: Sat, 23 Sep 2017 09:36:19 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Quoting Matthew Auld (2017-09-22 18:32:33)
> +static int i915_gem_object_create_shmem(struct drm_device *dev,
> +                                       struct drm_gem_object *obj,
> +                                       size_t size)
> +{
> +       struct drm_i915_private *i915 =3D to_i915(dev);
> +       struct file *filp;
> +
> +       drm_gem_private_object_init(dev, obj, size);
> +
> +       if (i915->mm.gemfs)
> +               filp =3D shmem_file_setup_with_mnt(i915->mm.gemfs, "i915"=
, size,
> +                                                VM_NORESERVE);
> +       else
> +               filp =3D shmem_file_setup("i915", size, VM_NORESERVE);

Smells like the shmem_file_setup() is fishy.

This supports my argument that you should just expand shmem_file_setup()
to always take the vfsmount, passing #define TMPFS_MNT NULL.
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
