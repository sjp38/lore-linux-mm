Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C80C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E53822146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LwrR+O4m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53822146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 673A06B0003; Wed, 20 Mar 2019 10:51:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6243E6B0006; Wed, 20 Mar 2019 10:51:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ECF16B0007; Wed, 20 Mar 2019 10:51:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD6B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:51:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u78so2750362pfa.12
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:51:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=8Jdo8JXAaSFwkNi1nj9BpVJxrQC94cbMheqiTCFS7Yo=;
        b=IWWHoKNiLuJt2yUY123PxAjcEgSAz6I1AAAIC+p2b3FL2qxNe8fTtIkOA+eVqanEOy
         p1n6fxDG0kKFCVcgVstRe0iin+G7I2kZmGS/lWeVjqSde5cGIwBNBde3MW+C9R4MTGN9
         M6Oy+RUop04klKb2yPD8pDMeM/RzHYVeHIR8AIO5M1r33gg0HUCRVgehkJc9XwbVn7r2
         MVHyqVXy27U8bHXvk/K8M0Gj+f3aMVr9MwxmjVSzfiUwDTNm6Y1CI6AkP5kmyQwb3r9S
         hpnwtY04fW79YL7W1dMQ46QN/2Tb+XbcJVbeOUJdENJNi98ubQJrPYlN/hPUEd5DWAr+
         3M/Q==
X-Gm-Message-State: APjAAAVNQ2N241pvmxCtHMol2WbA9Sl+etHdxV1cJjn25MBRg+Nu9rpt
	Sqim5FbDnAeMR9IqsBmpDqKM9ZRkK6qz/rDA/T7588dn0Oi68dOSSS2MpE6Q/89erjoIGbqc5ww
	ixC4/eNM4Cs8Asyru5Ar5ENlw0YAsjdjSpmWg0Oe2vdP5hTuteHFbieZd4PDlM9qhOQ==
X-Received: by 2002:a62:1d0e:: with SMTP id d14mr7977724pfd.73.1553093505395;
        Wed, 20 Mar 2019 07:51:45 -0700 (PDT)
X-Received: by 2002:a62:1d0e:: with SMTP id d14mr7977587pfd.73.1553093503347;
        Wed, 20 Mar 2019 07:51:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093503; cv=none;
        d=google.com; s=arc-20160816;
        b=IeiiqC8qVQeq0VLamJc1UMF+JZVlxYieiJfpXb7pQNWcWGXJc9tsVEOaWESOMY1nyY
         a0DJxktE6f8HanmgFKzM9CErwlncx51IVF5Bv3PCqu/IdbHJ//BPgKnxYWijLk9exX6j
         Kmv7W4wdA9NCp5u24ClDT78+530tY0s+N1uJDC6WH1Gyq8/s5V5r/LNpwI3kTrBQIHBu
         oZBP42THoAcBYN94pEmLRP1PjeV4v4e4YXzSeO+bLdcuvUTzi5jWP9TqJfkVHGaRuvEd
         Hou90ye1eekn1G2LyNWvkmujIjDYqqN/rwxomgTqNIzFCmWTJ04adsp15xy0ufxOGvPT
         +mqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=8Jdo8JXAaSFwkNi1nj9BpVJxrQC94cbMheqiTCFS7Yo=;
        b=m9F/mZFV+6FjYw9cvO7xNccEwiqZSgGWihOcPM5qZ/xw0918N9EpS3BOSbRyExXsiu
         Cb4ZeEfkS7ZAloHgvYjZP5viTjXXd/GfapxVNpJC+y4o+knDFZbuEnc6qizc45Sh6tuv
         YoC81Oyd5N/TDaEOOSiwcvN1FsEy/NvO3RH8UJB+cfWiE97Kl3xNWkSmStFI923Qkla3
         mcQwDYe0ua4NjDRRqOXe013WtLUP5tGjtn8lux98BReLmuqLVdFR7ecoeggamAXgPLvH
         k5f2omDOBmKv+uQFkU+XDAT3+eO/EMUvvJMHVTSotzAhqvnIDi7veuAPez9jDCRCO3cp
         3X7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LwrR+O4m;
       spf=pass (google.com: domain of 3flosxaokcfk1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3flOSXAoKCFk1E4I5PBEMC7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y67sor2486396pgy.46.2019.03.20.07.51.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3flosxaokcfk1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LwrR+O4m;
       spf=pass (google.com: domain of 3flosxaokcfk1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3flOSXAoKCFk1E4I5PBEMC7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=8Jdo8JXAaSFwkNi1nj9BpVJxrQC94cbMheqiTCFS7Yo=;
        b=LwrR+O4mkRsHnD5532/v8R2TtOFEGCFucq6n2WAmB8/MTIZDkWB4czsO5UyvLZyMy8
         V9C8miBrl6P+oU3otaEXyIg7FttsFbZQQiCV48aUO0Qixvw6E9T4l43BE6LFear6ZnSb
         R3HigLaVETA0cNwzL4zKG33qixnjLLvzovMdZvcZfhh+pWwlqHnsjrRMSxKy2zOdjGm4
         db6GqH2bdUMFyeLeSruqTz0jUeKZOiO3bm3TtKwSxxszbdJfdkFYQgx68jqsYcN2JJdf
         Zf7A0kFsGqdLSsLQtidsTYjg4dei+9xvZTELAQRj6WUfhpx/K6N7FKuMCgPKG5TGeEKt
         5Kgw==
X-Google-Smtp-Source: APXvYqwn0PbkydjPbcOK9WPl1CNLLuo9x/FvpAoGIQZB1xmpTwT4CYR3eIpMMr/6KpOWFNred/CURkkWRONRFUzj
X-Received: by 2002:a63:fe15:: with SMTP id p21mr364392pgh.52.1553093502567;
 Wed, 20 Mar 2019 07:51:42 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:14 +0100
Message-Id: <cover.1553093420.git.andreyknvl@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 00/20] arm64: untag user pointers passed to the kernel
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=== Overview

arm64 has a feature called Top Byte Ignore, which allows to embed pointer
tags into the top byte of each pointer. Userspace programs (such as
HWASan, a memory debugging tool [1]) might use this feature and pass
tagged user pointers to the kernel through syscalls or other interfaces.

Right now the kernel is already able to handle user faults with tagged
pointers, due to these patches:

1. 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on a
             tagged pointer")
2. 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged
	      pointers")
3. 276e9327 ("arm64: entry: improve data abort handling of tagged
	      pointers")

This patchset extends tagged pointer support to syscall arguments.

As per the proposed ABI change [3], tagged pointers are only allowed to be
passed to syscalls when they point to memory ranges obtained by anonymous
mmap() or sbrk() (see the patchset [3] for more details).

For non-memory syscalls this is done by untaging user pointers when the
kernel performs pointer checking to find out whether the pointer comes
from userspace (most notably in access_ok). The untagging is done only
when the pointer is being checked, the tag is preserved as the pointer
makes its way through the kernel and stays tagged when the kernel
dereferences the pointer when perfoming user memory accesses.

Memory syscalls (mmap, mprotect, etc.) don't do user memory accesses but
rather deal with memory ranges, and untagged pointers are better suited to
describe memory ranges internally. Thus for memory syscalls we untag
pointers completely when they enter the kernel.

=== Other approaches

One of the alternative approaches to untagging that was considered is to
completely strip the pointer tag as the pointer enters the kernel with
some kind of a syscall wrapper, but that won't work with the countless
number of different ioctl calls. With this approach we would need a custom
wrapper for each ioctl variation, which doesn't seem practical.

An alternative approach to untagging pointers in memory syscalls prologues
is to inspead allow tagged pointers to be passed to find_vma() (and other
vma related functions) and untag them there. Unfortunately, a lot of
find_vma() callers then compare or subtract the returned vma start and end
fields against the pointer that was being searched. Thus this approach
would still require changing all find_vma() callers.

=== Testing

The following testing approaches has been taken to find potential issues
with user pointer untagging:

1. Static testing (with sparse [2] and separately with a custom static
   analyzer based on Clang) to track casts of __user pointers to integer
   types to find places where untagging needs to be done.

2. Static testing with grep to find parts of the kernel that call
   find_vma() (and other similar functions) or directly compare against
   vm_start/vm_end fields of vma.

3. Static testing with grep to find parts of the kernel that compare
   user pointers with TASK_SIZE or other similar consts and macros.

4. Dynamic testing: adding BUG_ON(has_tag(addr)) to find_vma() and running
   a modified syzkaller version that passes tagged pointers to the kernel.

Based on the results of the testing the requried patches have been added
to the patchset.

=== Notes

This patchset is meant to be merged together with "arm64 relaxed ABI" [3].

This patchset is a prerequisite for ARM's memory tagging hardware feature
support [4].

This patchset has been merged into the Pixel 2 kernel tree and is now
being used to enable testing of Pixel 2 phones with HWASan.

Thanks!

[1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html

[2] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292

[3] https://lkml.org/lkml/2019/3/18/819

[4] https://community.arm.com/processors/b/blog/posts/arm-a-profile-architecture-2018-developments-armv85a

Changes in v13:
- Simplified untagging in tcp_zerocopy_receive().
- Looked at find_vma() callers in drivers/, which allowed to identify a
  few other places where untagging is needed.
- Added patch "mm, arm64: untag user pointers in get_vaddr_frames".
- Added patch "drm/amdgpu, arm64: untag user pointers in
  amdgpu_ttm_tt_get_user_pages".
- Added patch "drm/radeon, arm64: untag user pointers in
  radeon_ttm_tt_pin_userptr".
- Added patch "IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr".
- Added patch "media/v4l2-core, arm64: untag user pointers in
  videobuf_dma_contig_user_get".
- Added patch "tee/optee, arm64: untag user pointers in check_mem_type".
- Added patch "vfio/type1, arm64: untag user pointers".

Changes in v12:
- Changed untagging in tcp_zerocopy_receive() to also untag zc->address.
- Fixed untagging in prctl_set_mm* to only untag pointers for vma lookups
  and validity checks, but leave them as is for actual user space accesses.
- Updated the link to the v2 of the "arm64 relaxed ABI" patchset [3].
- Dropped the documentation patch, as the "arm64 relaxed ABI" patchset [3]
  handles that.

Changes in v11:
- Added "uprobes, arm64: untag user pointers in find_active_uprobe" patch.
- Added "bpf, arm64: untag user pointers in stack_map_get_build_id_offset"
  patch.
- Fixed "tracing, arm64: untag user pointers in seq_print_user_ip" to
  correctly perform subtration with a tagged addr.
- Moved untagged_addr() from SYSCALL_DEFINE3(mprotect) and
  SYSCALL_DEFINE4(pkey_mprotect) to do_mprotect_pkey().
- Moved untagged_addr() definition for other arches from
  include/linux/memory.h to include/linux/mm.h.
- Changed untagging in strn*_user() to perform userspace accesses through
  tagged pointers.
- Updated the documentation to mention that passing tagged pointers to
  memory syscalls is allowed.
- Updated the test to use malloc'ed memory instead of stack memory.

Changes in v10:
- Added "mm, arm64: untag user pointers passed to memory syscalls" back.
- New patch "fs, arm64: untag user pointers in fs/userfaultfd.c".
- New patch "net, arm64: untag user pointers in tcp_zerocopy_receive".
- New patch "kernel, arm64: untag user pointers in prctl_set_mm*".
- New patch "tracing, arm64: untag user pointers in seq_print_user_ip".

Changes in v9:
- Rebased onto 4.20-rc6.
- Used u64 instead of __u64 in type casts in the untagged_addr macro for
  arm64.
- Added braces around (addr) in the untagged_addr macro for other arches.

Changes in v8:
- Rebased onto 65102238 (4.20-rc1).
- Added a note to the cover letter on why syscall wrappers/shims that untag
  user pointers won't work.
- Added a note to the cover letter that this patchset has been merged into
  the Pixel 2 kernel tree.
- Documentation fixes, in particular added a list of syscalls that don't
  support tagged user pointers.

Changes in v7:
- Rebased onto 17b57b18 (4.19-rc6).
- Dropped the "arm64: untag user address in __do_user_fault" patch, since
  the existing patches already handle user faults properly.
- Dropped the "usb, arm64: untag user addresses in devio" patch, since the
  passed pointer must come from a vma and therefore be untagged.
- Dropped the "arm64: annotate user pointers casts detected by sparse"
  patch (see the discussion to the replies of the v6 of this patchset).
- Added more context to the cover letter.
- Updated Documentation/arm64/tagged-pointers.txt.

Changes in v6:
- Added annotations for user pointer casts found by sparse.
- Rebased onto 050cdc6c (4.19-rc1+).

Changes in v5:
- Added 3 new patches that add untagging to places found with static
  analysis.
- Rebased onto 44c929e1 (4.18-rc8).

Changes in v4:
- Added a selftest for checking that passing tagged pointers to the
  kernel succeeds.
- Rebased onto 81e97f013 (4.18-rc1+).

Changes in v3:
- Rebased onto e5c51f30 (4.17-rc6+).
- Added linux-arch@ to the list of recipients.

Changes in v2:
- Rebased onto 2d618bdf (4.17-rc3+).
- Removed excessive untagging in gup.c.
- Removed untagging pointers returned from __uaccess_mask_ptr.

Changes in v1:
- Rebased onto 4.17-rc1.

Changes in RFC v2:
- Added "#ifndef untagged_addr..." fallback in linux/uaccess.h instead of
  defining it for each arch individually.
- Updated Documentation/arm64/tagged-pointers.txt.
- Dropped "mm, arm64: untag user addresses in memory syscalls".
- Rebased onto 3eb2ce82 (4.16-rc7).

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Andrey Konovalov (20):
  uaccess: add untagged_addr definition for other arches
  arm64: untag user pointers in access_ok and __uaccess_mask_ptr
  lib, arm64: untag user pointers in strn*_user
  mm, arm64: untag user pointers passed to memory syscalls
  mm, arm64: untag user pointers in mm/gup.c
  mm, arm64: untag user pointers in get_vaddr_frames
  fs, arm64: untag user pointers in copy_mount_options
  fs, arm64: untag user pointers in fs/userfaultfd.c
  net, arm64: untag user pointers in tcp_zerocopy_receive
  kernel, arm64: untag user pointers in prctl_set_mm*
  tracing, arm64: untag user pointers in seq_print_user_ip
  uprobes, arm64: untag user pointers in find_active_uprobe
  bpf, arm64: untag user pointers in stack_map_get_build_id_offset
  drm/amdgpu, arm64: untag user pointers in amdgpu_ttm_tt_get_user_pages
  drm/radeon, arm64: untag user pointers in radeon_ttm_tt_pin_userptr
  IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr
  media/v4l2-core, arm64: untag user pointers in
    videobuf_dma_contig_user_get
  tee/optee, arm64: untag user pointers in check_mem_type
  vfio/type1, arm64: untag user pointers in vaddr_get_pfn
  selftests, arm64: add a selftest for passing tagged pointers to kernel

 arch/arm64/include/asm/uaccess.h              | 10 +++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c       |  5 ++-
 drivers/gpu/drm/radeon/radeon_ttm.c           |  5 ++-
 drivers/infiniband/hw/mlx4/mr.c               |  7 +--
 drivers/media/v4l2-core/videobuf-dma-contig.c |  9 ++--
 drivers/tee/optee/call.c                      |  1 +
 drivers/vfio/vfio_iommu_type1.c               |  2 +
 fs/namespace.c                                |  2 +-
 fs/userfaultfd.c                              |  5 +++
 include/linux/mm.h                            |  4 ++
 ipc/shm.c                                     |  2 +
 kernel/bpf/stackmap.c                         |  6 ++-
 kernel/events/uprobes.c                       |  2 +
 kernel/sys.c                                  | 44 +++++++++++++------
 kernel/trace/trace_output.c                   |  5 ++-
 lib/strncpy_from_user.c                       |  3 +-
 lib/strnlen_user.c                            |  3 +-
 mm/frame_vector.c                             |  2 +
 mm/gup.c                                      |  4 ++
 mm/madvise.c                                  |  2 +
 mm/mempolicy.c                                |  5 +++
 mm/migrate.c                                  |  1 +
 mm/mincore.c                                  |  2 +
 mm/mlock.c                                    |  5 +++
 mm/mmap.c                                     |  7 +++
 mm/mprotect.c                                 |  1 +
 mm/mremap.c                                   |  2 +
 mm/msync.c                                    |  2 +
 net/ipv4/tcp.c                                |  2 +
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 +++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 +++++
 tools/testing/selftests/arm64/tags_test.c     | 21 +++++++++
 33 files changed, 159 insertions(+), 36 deletions(-)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

-- 
2.21.0.225.g810b269d1ac-goog

