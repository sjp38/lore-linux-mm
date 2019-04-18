Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26D90C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5E02218FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5E02218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B7F6B000E; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26E3F6B000C; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0DDF6B000E; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9116E6B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b186so99034wmd.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject;
        bh=V41xwhODxsnHamjhphNGskSJta+SghipD5A07/5lSHQ=;
        b=qOSBIFDcCPZH45q7xXP9UYAXYdwOTvnPfJKOzAgnWKZtDHzUYa7zOC6uIgvbkmXk7B
         avT11fJKXAmGogozvr/T33LD2OKZbIgFCzU4Vs2fqaprj96BKa0Szr5GlCrpOtY7vnN0
         4Y+78889aciL5v9stpRyAU55BrIuMzPVGDPMHgXNlayXXXrAQCQWuLXWqlYbVaA+XfGC
         ADhoM5E2bWUbazQNyY2Rb7mM3zVhDhoCR1DjdqIZebPFDj/eZQmY9Y9IYt8/T/0ozTqX
         KVoXOsQBFcYj6FQewr8U3E9lAB94MelbATJk26XhF1U9T4edors+PS901SOUGH644nc1
         N/yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVVYaJWr2QCjOmEcpvI3No5oIQP1tKituy1m44RHFewl/MdRdDi
	rYvpM2NMhMV7t59+vlfmfCDvQ09zy79wI41z+57SEyAReddRrVRMe6JveNFm/Pyg8VYKPkBKUUD
	eiA1Jl+F6NgLHF12muA7goDMpMpGrWcSI7uHWTF09S4biRQzu2YgUgdZ+hD+Cq//rmQ==
X-Received: by 2002:a1c:6c09:: with SMTP id h9mr2241501wmc.130.1555578370944;
        Thu, 18 Apr 2019 02:06:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpbjT7fM2f8MCOamqmSzMybGP5exlaEV0q7V82aEFA2eNV82UzEdUbjP9Be/ehInyaMADi
X-Received: by 2002:a1c:6c09:: with SMTP id h9mr2241424wmc.130.1555578369801;
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578369; cv=none;
        d=google.com; s=arc-20160816;
        b=mfaMAAnP8+0dVfMfCv/cIJ7TPg57ZtYyIlgIJl/SQ6indfmqbTKqXw0XOsB4TmwJ9+
         VEmVtwMlVyGXOlOnscDsbD8kvpafPQGJNcguEMcfS0O1jFdfHnIJlvvcrc4Zu70mH1+o
         I8bTA0Jo3K8Wz1vDGShtUDkxmXLRdHzDK9JetTI35tC0TPMB/F4GrkDRaCYmS0nU1MMn
         XWEdhoPF2FXL1BjPfqxdOgHtyP7KlHAmIjs/i8Ppatj/tdYj8j5vGhLwgDDybRBPI7eL
         f7ghG88hU6t6GDSfSaLKo0gB35FzjY4OHe20huibFcGjIAJI1ZUZuBtUTC/Vgmx+Z7lk
         SGFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:cc:to:from:date:user-agent:message-id;
        bh=V41xwhODxsnHamjhphNGskSJta+SghipD5A07/5lSHQ=;
        b=VxunHvhLRe1pt2l1WCQS5XQqWxh2XQnUwAZ8ERJsL2y/jK37Hsh76Nups3szTTcUHQ
         LyxMrh+amQJv7TrfzCmRMbJtUfMBK/6S3MuZKQzbNt0iBKZIfd67n2HAGF43BkTTmh3M
         lpXEBJihEfkg4tJWZcJvvOglEBosdwugP10PBejsIqX0D4ndkzZWwR0mEy81RABwtzC4
         rPPR/kY3sc6C4UQcJNmrG/Z516r/w+VqZbFDri3avZ7/3ZUX9zs1Jny+/vk/2sB1BKRw
         BFEtCLxHLihKX7200pDKUKu2/gIM96C1oJZsknZ3kxQ6qZe3OJ3xj1i/CNw9vcAltSGR
         LIdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y9si1239184wru.80.2019.04.18.02.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zW-0001ls-Ty; Thu, 18 Apr 2019 11:05:59 +0200
Message-Id: <20190418084119.056416939@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:19 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 00/29] stacktrace: Consolidate stack trace usage
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an update to V1:

 https://lkml.kernel.org/r/20190410102754.387743324@linutronix.de

Struct stack_trace is a sinkhole for input and output parameters which is
largely pointless for most usage sites. In fact if embedded into other data
structures it creates indirections and extra storage overhead for no
benefit.

Looking at all usage sites makes it clear that they just require an
interface which is based on a storage array. That array is either on stack,
global or embedded into some other data structure.

Some of the stack depot usage sites are outright wrong, but fortunately the
wrongness just causes more stack being used for nothing and does not have
functional impact.

Fix this up by:

  1) Providing plain storage array based interfaces for stacktrace and
     stackdepot.

  2) Cleaning up the mess at the callsites including some related
     cleanups.

  3) Removing the struct stack_trace based interfaces

  This is not yet changing the struct stack_trace interfaces at the
  architecture level, but it removes the exposure to the usage sites.

The last two patches are extending the cleanup to the architecture level by
replacing the various save_stack_trace.* architecture interfaces with a
more unified arch_stack_walk() interface. x86 is converted, but I have
worked through all architectures already and it removes lots of duplicated
code and allows consolidation across the board. The rest of the
architecture patches are not included in this posting as I want to get
feedback on the approach itself. The diffstat of cleaning up the remaining
architectures is currently on top of the current lot is:

   47 files changed, 402 insertions(+), 1196 deletions(-)

Once this has settled, the core interfaces can be improved by adding
features, which allow to get rid of the imprecise 'skip number of entries'
approach which tries to remove the stack tracer and the callsites themself
from the trace. That's error prone due to inlining and other issues. Having
e.g. a _RET_IP_ based filter allows to do that far more reliable.

The series is based on:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git core/stacktrace

which contains the removal of the inconsistent and pointless ULONG_MAX
termination of stacktraces.

It's also available from git:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.core/stacktrace

   up to:  131038eb3e2f ("x86/stacktrace: Use common infrastructure")

Changes vs. V1:

   - Applied the ULONG_MAX termination cleanup in tip

   - Addressed the review comments

   - Fixed up the last users of struct stack_trace outside the stacktrace
     core and architecture code (livepatch, tracing)

   - Added the new arch_stack_walk() model and converted x86 to it

Thanks,

	tglx

---
 arch/x86/Kconfig                              |    1 
 arch/x86/kernel/stacktrace.c                  |  116 +--------
 drivers/gpu/drm/drm_mm.c                      |   22 -
 drivers/gpu/drm/i915/i915_vma.c               |   11 
 drivers/gpu/drm/i915/intel_runtime_pm.c       |   21 -
 drivers/md/dm-bufio.c                         |   15 -
 drivers/md/persistent-data/dm-block-manager.c |   19 -
 fs/btrfs/ref-verify.c                         |   15 -
 fs/proc/base.c                                |   14 -
 include/linux/ftrace.h                        |   18 -
 include/linux/lockdep.h                       |    9 
 include/linux/stackdepot.h                    |    8 
 include/linux/stacktrace.h                    |   80 +++++-
 kernel/backtracetest.c                        |   11 
 kernel/dma/debug.c                            |   13 -
 kernel/latencytop.c                           |   17 -
 kernel/livepatch/transition.c                 |   22 -
 kernel/locking/lockdep.c                      |   81 ++----
 kernel/stacktrace.c                           |  323 ++++++++++++++++++++++++--
 kernel/trace/trace.c                          |  105 +++-----
 kernel/trace/trace.h                          |    8 
 kernel/trace/trace_events_hist.c              |   12 
 kernel/trace/trace_stack.c                    |   76 ++----
 lib/Kconfig                                   |    4 
 lib/fault-inject.c                            |   12 
 lib/stackdepot.c                              |   50 ++--
 mm/kasan/common.c                             |   30 --
 mm/kasan/report.c                             |    7 
 mm/kmemleak.c                                 |   24 -
 mm/page_owner.c                               |   79 ++----
 mm/slub.c                                     |   12 
 31 files changed, 664 insertions(+), 571 deletions(-)



