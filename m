Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1896B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:06:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r74so9371345wme.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:06:31 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id k2si17010wmi.26.2017.09.25.11.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 11:06:29 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170922173252.10137-3-matthew.auld@intel.com>
References: <20170922173252.10137-1-matthew.auld@intel.com>
 <20170922173252.10137-3-matthew.auld@intel.com>
Message-ID: <150636278551.18819.5948205678578148677@mail.alporthouse.com>
Subject: Re: [PATCH 02/21] drm/i915: introduce simple gemfs
Date: Mon, 25 Sep 2017 19:06:25 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Quoting Matthew Auld (2017-09-22 18:32:33)
> @@ -4914,6 +4938,8 @@ i915_gem_load_init(struct drm_i915_private *dev_pri=
v)
>  =

>         spin_lock_init(&dev_priv->fb_tracking.lock);
>  =

> +       WARN_ON(i915_gemfs_init(dev_priv));

Make this kinder, the driver will happily continue without a special
gemfs mounting. (For mock, maybe WARN and bail for the tests that need gemf=
s?)

if (i915_gemfs_init(dev_priv)))
	DRM_NOTE("Unable to create a private tmpfs mountpoint, hugepage support wi=
ll be disabled.\n");
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
