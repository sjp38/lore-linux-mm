Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDAD6B0374
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:02:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 23so61486569qks.12
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:02:10 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id a129si2562449qkd.180.2017.05.16.03.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:02:09 -0700 (PDT)
Received: by mail-qk0-x236.google.com with SMTP id a72so122802945qkj.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:02:08 -0700 (PDT)
Date: Tue, 16 May 2017 13:02:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/17] mm/shmem: expose driver overridable huge option
Message-ID: <20170516100206.f6rtpl2uv3whemkp@node.shutemov.name>
References: <20170516082948.28090-1-matthew.auld@intel.com>
 <20170516082948.28090-7-matthew.auld@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516082948.28090-7-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Daniel Vetter <daniel@ffwll.ch>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, May 16, 2017 at 09:29:37AM +0100, Matthew Auld wrote:
> In i915 we are aiming to support huge GTT pages for the GPU, and to
> complement this we also want to enable THP for our shmem backed objects.
> Even though THP is supported in shmemfs it can only be enabled through
> the huge= mount option, but for users of the kernel mounted shm_mnt like
> i915, we are a little stuck. There is the sysfs knob shmem_enabled to
> either forcefully enable/disable the feature, but that seems to only be
> useful for testing purposes. What we propose is to expose a driver
> overridable huge option as part of shmem_inode_info to control the use
> of THP for a given mapping.

I don't like this. It's kinda hacky.

Is there a reason why i915 cannot mount a new tmpfs for own use?

Or other option would be to change default to SHMEM_HUGE_ADVISE and wire
up fadvise handle to control per-file allocation policy.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
