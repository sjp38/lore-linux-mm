Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD7A6B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 21:06:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c4-v6so5172930pfg.22
        for <linux-mm@kvack.org>; Sat, 26 May 2018 18:06:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o1-v6si26601141pld.424.2018.05.26.18.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 May 2018 18:06:45 -0700 (PDT)
Subject: [PATCH 0/2] x86/numa_emulation: Introduce uniform split capability
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 26 May 2018 17:56:47 -0700
Message-ID: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: Wei Yang <richard.weiyang@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgx86@kernel.org

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
 arch/x86/mm/numa_emulation.c              |   98 +++++++++++++++++++++++------
 2 files changed, 82 insertions(+), 20 deletions(-)
