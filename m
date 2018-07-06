Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF2A6B000D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 12:18:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l21-v6so3036579pff.3
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 09:18:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e1-v6si8988867pfg.257.2018.07.06.09.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 09:18:24 -0700 (PDT)
Subject: [PATCH v2 0/2] x86/numa_emulation: Introduce uniform split
 capability
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Jul 2018 09:07:55 -0700
Message-ID: <153089327581.27680.11402583130804677094.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: Wei Yang <richard.weiyang@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgx86@kernel.org

Changes since v1 [1]:
* Fix a pair of compile errors in 32-bit builds for 64-bit divides.

[1]: https://lkml.org/lkml/2018/5/26/190

---

The current numa emulation capabilities for splitting System RAM by a
fixed size or by a set number of nodes may result in some nodes being
larger than others. The implementation prioritizes establishing a
minimum usable memory size over satisfying the requested number of numa
nodes.

Introduce a uniform split capability that evenly partitions each
physical numa node into N emulated nodes. For example numa=fake=3U
creates 6 emulated nodes total on a system that has 2 physical nodes.

This capability is useful for debugging and evaluating platform
memory-side-cache capabilities as described by the ACPI HMAT (see
5.2.27.5 Memory Side Cache Information Structure in ACPI 6.2a)

See more details in patch2.

---

Dan Williams (2):
      x86/numa_emulation: Fix emulated-to-physical node mapping
      x86/numa_emulation: Introduce uniform split capability


 Documentation/x86/x86_64/boot-options.txt |    4 +
 arch/x86/mm/numa_emulation.c              |  107 ++++++++++++++++++++++++-----
 2 files changed, 91 insertions(+), 20 deletions(-)
