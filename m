From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 0/4] Cpu alloc V5: Replace percpu allocator in modules.c
Date: Fri, 19 Sep 2008 07:58:59 -0700
Message-ID: <20080919145859.062069850@quilx.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754609AbYISPBG@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Just do the bare mininum to establish a per cpu allocator. Later patchsets
will gradually build out the functionality.

The most critical issue that came up on the last round is how to configure
the size of the percpu area. Here we simply use a kernel parameter and use
the static size of the existing percpu allocator for modules as a default.

The effect of this patchset is to make the size of percpu data for modules
configurable. Its no longer fixed at 8000 bytes.

Changes:
V4->V5:
- Fix various things pointed out by Pekka.
- Remove page alignment check from module.c and put it into cpu_alloc.c

V3->V4:
- Gut patches to the bare essentials: Only replace modules.c percpu alloocator
- Make percpu reserve area configurable via a kernel parameter


-- 
