Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70D77C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0CD62070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Tu5banMR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0CD62070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C8548E00E0; Fri, 22 Feb 2019 07:53:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 451B78E00D4; Fri, 22 Feb 2019 07:53:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CAFF8E00E0; Fri, 22 Feb 2019 07:53:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4B028E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:32 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f5so974987wrt.13
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=yTdyE4OiJcihsaiN1kttL78b5ay8J+Duvtcy07EGUfk=;
        b=Bxf+hJYez0R8iVOjGMMJbMmki58L3qU0F0KiTokDXq0zsr7LN5qQ/mCU+31qQvdGGs
         CPweN1rSv4ZK9i+qpdeIUPbYrGbWsIftfLr+Uv8r98XJErBfvLznSbnZrqUmNVLsIVbQ
         UZgEeifxEPvrNQBxyf5130xdcT6VJA4fsQk17kPZP0ROSEvrjyZYTuwzfrmI9oUb9Qqb
         HYgs/o2l6ZyFduvvq92xoWwnTE764Jbt2LDJIk/QAY2R534crAvN2463kl3Ux1V9KwIq
         mLAE9vdwZflm75ufJxVI26Ls4skTSIW/7W2WmNgpoRUyO8OeZRseQvGv4GITxq3JtPcH
         R9VA==
X-Gm-Message-State: AHQUAuY8Q7tl59EZ5yCghAPA9/NPkBPZX98EMC6HOyl9tIIH3O+xGnQm
	/rWdui4hyHRWWlqXpTOGu0OW1aja5GV91SRqNlGVvtrJ7CUu80Hp4j9Ebogrr9VeOV0IM05asmK
	oBd1kL1Xdf9pj4PtlR9LeR6IlFj4kGQQeJXNMeLgZAQPCVCiMBInBUSaKV3+7/smpD3AEQKEeDv
	O+uvlzcgsjVJDuGhYr+p1fKtuDSmDMaND2kbPyIgg2/NFNNtIrDkOzXfW5UvDE1/zukkiwsuzSq
	Wn+gSiboh89pbLgyNSnr7Hhr8ikbMRYmnUtlSyNDR7Jen85AqHpVR/0gTomP5GSlAmWSdriVSJs
	PENBfCYbt8GaKpYPxlgxfYk+RTZQMRXAF1WlREIIUHt0O2drWY0PLpZVe2IDNpRd+pxE/WdL2Q5
	u
X-Received: by 2002:a7b:c766:: with SMTP id x6mr2430132wmk.15.1550840011997;
        Fri, 22 Feb 2019 04:53:31 -0800 (PST)
X-Received: by 2002:a7b:c766:: with SMTP id x6mr2430059wmk.15.1550840010345;
        Fri, 22 Feb 2019 04:53:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840010; cv=none;
        d=google.com; s=arc-20160816;
        b=I0MtahjQMxyoHPfgsqwaROxMBZzXccHyIZZHVMcDy9cIia3/eR2YNLAmD2rdKBZ4nV
         vIHzZPoufp+rDv3wE919n2IXyd85D7Z+X7euXEYZCjGbDdiMbnp9BRTQKS4SrVBo2c4v
         UsHtJ5tWqEJ61l8OvqPrCwuU1BRjA27bfXDgGLUZ01Pm9VngGgFJLa/6XHfRQTULoUl8
         3UrxHNz9/pPnUPeZDrvcJVZ5m0aofk7igeq+gNrXOm/hTs4Qz0kzbq82VXL3YxmPsKXX
         s9lemwcxqUcHP1zNpsyREh48uoPosnO5ZRws3uF+IJuGzc5xrxxkeWSlbYBWmn7gsWvp
         aRGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=yTdyE4OiJcihsaiN1kttL78b5ay8J+Duvtcy07EGUfk=;
        b=T89GcXwbvfLxl6Wy9ULJ6iqnX1Qv0S7ml1grjT2xG0fvt8hrIdZJGqLUWvYv2aqPUQ
         is1D+RZ0N4xXHQrJSLA84b1RQcqearzvnpUaFTIhi4M8caDoJAURZdCmikxxp3lGQHjN
         s44zMxHAEkxZcN2U0c5iBbPA+lfRBx+wrCng/QkZqe2PhtyAt2MhXdv362GFTMXYHUEa
         KevW0YXnw/GPvBjfOV+KeG0ILsyNMLr/K1bW7STPAMx8CBNU+DvOAboj59H+MchzwCN5
         xZmfhpLxMHtu5V7eS48NzwGLIwU7tGHBBN6JtS7K9zc7H0fpor+8XXIMi0xIKDU512bA
         KpJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tu5banMR;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor1100656wrt.25.2019.02.22.04.53.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:30 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tu5banMR;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=yTdyE4OiJcihsaiN1kttL78b5ay8J+Duvtcy07EGUfk=;
        b=Tu5banMRDDtlPyLWe88p9yIWwYonsz5x0mYsSuA17N5WBoGiRj1vrkMv/zOaZ8mbiY
         K5tP2hOpcPEdYPXLSmWECNR7PTwSOQJAnmXujZrViJWAnOLPZxMYFi1HCrfE2HJLLv/4
         KHQrhosGOdc+4DPZjNnIIfoS0ZeQ6bFOZbBkgN6SlrhRbttfOj+1c4VCuRH69TyJNfQX
         s3S+22nyCABj203DAdHMQ3iCdDg2oMQlAy98Q5kaYOLq3A8gouMm2kQXOrD3Y/zw9YU6
         1lwD/RF8vFGrC99MDVI5o36hoNcd03at/AjZeRp4exwegENG/KYluvN3VLtX3DYPtSB2
         c3Sw==
X-Google-Smtp-Source: AHgI3IYgvJEuUDeO3E9Up8/xaWGBXG29t1gzrvf/Z2pkqz38LV7bpaiegSpkMtPPtktz3keuogX01w==
X-Received: by 2002:a05:6000:92:: with SMTP id m18mr2858642wrx.258.1550840009608;
        Fri, 22 Feb 2019 04:53:29 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:28 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
Date: Fri, 22 Feb 2019 13:53:12 +0100
Message-Id: <cover.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is meant to be merged together with "arm64 relaxed ABI" [1].

arm64 has a feature called Top Byte Ignore, which allows to embed pointer
tags into the top byte of each pointer. Userspace programs (such as
HWASan, a memory debugging tool [2]) might use this feature and pass
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

For non-memory syscalls this is done by untaging user pointers when the
kernel performs pointer checking to find out whether the pointer comes
from userspace (most notably in access_ok). The untagging is done only
when the pointer is being checked, the tag is preserved as the pointer
makes its way through the kernel.

Since memory syscalls (mmap, mprotect, etc.) don't do memory accesses but
rather deal with memory ranges, untagged pointers are better suited to
describe memory ranges internally. Thus for memory syscalls we untag
pointers completely when they enter the kernel.

One of the alternative approaches to untagging that was considered is to
completely strip the pointer tag as the pointer enters the kernel with
some kind of a syscall wrapper, but that won't work with the countless
number of different ioctl calls. With this approach we would need a custom
wrapper for each ioctl variation, which doesn't seem practical.

The following testing approaches has been taken to find potential issues
with user pointer untagging:

1. Static testing (with sparse [3] and separately with a custom static
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

This patchset has been merged into the Pixel 2 kernel tree and is now
being used to enable testing of Pixel 2 phones with HWASan.

This patchset is a prerequisite for ARM's memory tagging hardware feature
support [4].

Thanks!

[1] https://lkml.org/lkml/2018/12/10/402

[2] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html

[3] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292

[4] https://community.arm.com/processors/b/blog/posts/arm-a-profile-architecture-2018-developments-armv85a

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

Reviewed-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Andrey Konovalov (12):
  uaccess: add untagged_addr definition for other arches
  arm64: untag user pointers in access_ok and __uaccess_mask_ptr
  lib, arm64: untag user pointers in strn*_user
  mm, arm64: untag user pointers passed to memory syscalls
  mm, arm64: untag user pointers in mm/gup.c
  fs, arm64: untag user pointers in copy_mount_options
  fs, arm64: untag user pointers in fs/userfaultfd.c
  net, arm64: untag user pointers in tcp_zerocopy_receive
  kernel, arm64: untag user pointers in prctl_set_mm*
  tracing, arm64: untag user pointers in seq_print_user_ip
  arm64: update Documentation/arm64/tagged-pointers.txt
  selftests, arm64: add a selftest for passing tagged pointers to kernel

 Documentation/arm64/tagged-pointers.txt       | 25 +++++++++++--------
 arch/arm64/include/asm/uaccess.h              | 10 +++++---
 fs/namespace.c                                |  2 +-
 fs/userfaultfd.c                              |  5 ++++
 include/linux/memory.h                        |  4 +++
 ipc/shm.c                                     |  2 ++
 kernel/sys.c                                  | 14 +++++++++++
 kernel/trace/trace_output.c                   |  2 +-
 lib/strncpy_from_user.c                       |  2 ++
 lib/strnlen_user.c                            |  2 ++
 mm/gup.c                                      |  4 +++
 mm/madvise.c                                  |  2 ++
 mm/mempolicy.c                                |  5 ++++
 mm/migrate.c                                  |  1 +
 mm/mincore.c                                  |  2 ++
 mm/mlock.c                                    |  5 ++++
 mm/mmap.c                                     |  7 ++++++
 mm/mprotect.c                                 |  2 ++
 mm/mremap.c                                   |  2 ++
 mm/msync.c                                    |  2 ++
 net/ipv4/tcp.c                                |  2 ++
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 ++++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 +++++++++
 tools/testing/selftests/arm64/tags_test.c     | 19 ++++++++++++++
 25 files changed, 129 insertions(+), 16 deletions(-)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

-- 
2.21.0.rc0.258.g878e2cd30e-goog

