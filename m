Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Gushchin <guroan@gmail.com>
Subject: [PATCH 0/3] vmalloc enhancements
Date: Wed, 19 Dec 2018 09:37:48 -0800
Message-Id: <20181219173751.28056-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>
List-ID: <linux-mm.kvack.org>

The patchset contains few changes to the vmalloc code, which are
leading to some performance gains and code simplification.

Also, it exports a number of pages, used by vmalloc(),
in /proc/meminfo.

Patch (1) removes some redundancy on __vunmap().
Patch (2) separates memory allocation and data initialization
  in alloc_vmap_area()
Patch (3) adds vmalloc counter to /proc/meminfo.

RFC->v1:
  - removed bogus empty lines (suggested by Matthew Wilcox)
  - made nr_vmalloc_pages static (suggested by Matthew Wilcox)
  - dropped patch 3 from RFC patchset, will post later with
  some other changes
  - dropped RFC

Roman Gushchin (3):
  mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
  mm: separate memory allocation and actual work in alloc_vmap_area()
  mm: show number of vmalloc pages in /proc/meminfo

 fs/proc/meminfo.c       |   2 +-
 include/linux/vmalloc.h |   2 +
 mm/vmalloc.c            | 107 ++++++++++++++++++++++++++--------------
 3 files changed, 73 insertions(+), 38 deletions(-)

-- 
2.19.2
