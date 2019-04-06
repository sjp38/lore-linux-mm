Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDF25C282DC
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 18:35:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6833721855
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 18:35:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XnOAXGA/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6833721855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C06286B000C; Sat,  6 Apr 2019 14:35:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBA0A6B000D; Sat,  6 Apr 2019 14:35:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F266B000E; Sat,  6 Apr 2019 14:35:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C12A6B000C
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 14:35:22 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id z25so2711234ljb.13
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 11:35:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=t04JSRqmhl4L/mJGwJDFU3su+DvHP7RPStBYcuTtTOY=;
        b=fH/C8r5x1hdrYk737+pvmwPwCoISbDB0cwkJjCCCmAszpP0pWSiflyXDJaWNEZaZGb
         rnf5lPpapF0unQm7ZrpxV89RwmNzCX3eT4dzwA+AYLeU/Qn8XZFX3L4Ksy45tF5EJa0d
         VF0061hUcqYdg8qeNld5okaW9ThidcWjmLNQFp6wBUHJ4tsY8jJ9tRPlYosJIGJzPyj7
         Q05cTTWJmKRnwE0J+DsDyMuGnGOGbg/wePH6FydfgF/pGePJ57aGXZHeyLQFInD/z/A5
         /ZXDwZ9aWp5bmOv306wAj8qMa+hv6BGoxbNjegvQDUcS92ozvKgunFp+qALvxFLbIj9J
         oTBA==
X-Gm-Message-State: APjAAAUqZsEiwBsiiGahrMbfAByCbjgzc2TGphTqOwZxHpTHfPku/Pob
	ShKZ5/u6z8MSU8gc/8CFaiR+zUoWw8CODPXEHqewtNTP5VB/d6Ib1kaEdh2sZLjBro07aeyHvuj
	z7R2NQ76LE4TK/18HrVeXhPChW07IN9KlaWL1fbv68IimAUgE2uChZZhHo5U0KZxyaA==
X-Received: by 2002:a05:651c:10f:: with SMTP id a15mr5444307ljb.30.1554575721035;
        Sat, 06 Apr 2019 11:35:21 -0700 (PDT)
X-Received: by 2002:a05:651c:10f:: with SMTP id a15mr5444251ljb.30.1554575718849;
        Sat, 06 Apr 2019 11:35:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554575718; cv=none;
        d=google.com; s=arc-20160816;
        b=OnUR0rZIuOrJFDz9TSr1SHK8c9D58lK3yacFJHsyRHUaPXfMaX8d/05O/ruECReq1E
         y3YFgjcdXY+MJ2h3WwBwmkhg2wZRWxFb5xl3skg4xvJ/6kcBXgApxDg2bfMuEk4WxKS5
         A2PUueluRvJOsGf5xBsveN5CKcfyTdYoVPenPCXwevPL/duUuLHcVHUTWUnn2Qc/HZM0
         7iV19X/2DQDRooldqzf3TLa9MKdl39dcGBPq3Ip11nm5C8gcoz+kBe3EYtvEnTULiCY3
         +pkj2QTsM/hu8jXKxNSk85wTlKd6Hn24jVNtIQmSE4YrBucZ5ob5B5n8IsaKIdzMhl7m
         /xhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=t04JSRqmhl4L/mJGwJDFU3su+DvHP7RPStBYcuTtTOY=;
        b=eEdaRQAeEMog0ukoP/HTH2TIxa8Mah6yv1rTS//78UCDja6jWzkkJH9BvhOXp3cGMr
         1xc5hCtbLgvH31O7ouz4AfXl/89DyQsRnWjeh/PoNOFZ7QBtTekO6x1m1KNASKmnISwL
         69Pav/d1Z7+POVEIrs9uoFWYlmrjxAQmVRaO7E0iCya4ATGPNZcvRHJUI2/4O8CSwDhr
         niyuxFE3axQUgEAFHNzaTChAyEOD/cdWXxDPaHEh7vSZ7O32dlmBgKHNPh4cjn5ou4v3
         6mwwWlPv+1R0r+oNSII1HqXFO+8ofNjQUB+zerQ+0JL0ARXZHNqQwSdNYYf+SQ7rdqNw
         /CRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XnOAXGA/";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor16503477ljh.32.2019.04.06.11.35.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Apr 2019 11:35:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XnOAXGA/";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=t04JSRqmhl4L/mJGwJDFU3su+DvHP7RPStBYcuTtTOY=;
        b=XnOAXGA/5DdyydAlBcje4Si4YDzddbQSBwRNImBL4bw1/cJp2+D5AOylaOE8ddGjmR
         zxEZcZp5lSKa0l48rRrITmRPjhoien1AGiKSpTybSplAtH+UbG8WRkgm8Bij3SBrU5qm
         uVjD31HJtNVzZMUCRgNCtK45C6DJG2qQVq4vjbZebiXeyKKKHnVa8Hgctl9dDg++xw8f
         mEuKaIFgAA11LUyijzM0aClGl57YEDWs2eEtvxxYnAoPKB9btStVUIDGmEP39exiJIh5
         3dljJwWAo3qMOdj86LZraf/Gs1CAd28H/d+OLp8THY/K+JN5m11pYdxqxYY/qdIBv80u
         P7ow==
X-Google-Smtp-Source: APXvYqxA2PArygfkyMvbS7e3I5M4emcQ1Vd3tM1BP1i+m+Y7NlOkJzIl780ePTztdj615GKm/Bz8bQ==
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr10544970lja.49.1554575718188;
        Sat, 06 Apr 2019 11:35:18 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id m1sm5119622lfb.78.2019.04.06.11.35.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 11:35:17 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH v4 0/3] improve vmap allocation
Date: Sat,  6 Apr 2019 20:35:05 +0200
Message-Id: <20190406183508.25273-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

This is the v4.

Objective
---------
Please have a look for the description at: https://lkml.org/lkml/2018/10/19/786
But let me also summarize it a bit here as well. The current implementation has O(N)
complexity. Requests with different permissive parameters can lead to long allocation
time. When i say "long" i mean milliseconds. 

Description
-----------
This approach organizes the KVA memory layout into free areas of the 1-ULONG_MAX
range, i.e. an allocation is done over free areas lookups, instead of finding
a hole between two busy blocks. It allows to have lower number of objects which
represent the free space, therefore to have less fragmented memory allocator.
Because free blocks are always as large as possible.

It uses the augment tree where all free areas are sorted in ascending order of
va->va_start address in pair with linked list that provides O(1) access to
prev/next elements.

Since the tree is augment, we also maintain the "subtree_max_size" of VA that
reflects a maximum available free block in its left or right sub-tree. Knowing
that, we can easily traversal toward the lowest(left most path) free area.

Allocation: ~O(log(N)) complexity. It is sequential allocation method therefore
tends to maximize locality. The search is done until a first suitable block is
large enough to encompass the requested parameters. Bigger areas are split.

I copy paste here the description of how the area is split, since i described
it in https://lkml.org/lkml/2018/10/19/786

<snip>
A free block can be split by three different ways. Their names are FL_FIT_TYPE,
LE_FIT_TYPE/RE_FIT_TYPE and NE_FIT_TYPE, i.e. they correspond to how requested
size and alignment fit to a free block.

FL_FIT_TYPE - in this case a free block is just removed from the free list/tree
because it fully fits. Comparing with current design there is an extra work with
rb-tree updating.

LE_FIT_TYPE/RE_FIT_TYPE - left/right edges fit. In this case what we do is
just cutting a free block. It is as fast as a current design. Most of the vmalloc
allocations just end up with this case, because the edge is always aligned to 1.

NE_FIT_TYPE - Is much less common case. Basically it happens when requested size
and alignment does not fit left nor right edges, i.e. it is between them. In this
case during splitting we have to build a remaining left free area and place it
back to the free list/tree.

Comparing with current design there are two extra steps. First one is we have to
allocate a new vmap_area structure. Second one we have to insert that remaining 
free block to the address sorted list/tree.

In order to optimize a first case there is a cache with free_vmap objects. Instead
of allocating from slab we just take an object from the cache and reuse it.

Second one is pretty optimized. Since we know a start point in the tree we do not
do a search from the top. Instead a traversal begins from a rb-tree node we split.
<snip>

De-allocation. ~O(log(N)) complexity. An area is not inserted straight away to the
tree/list, instead we identify the spot first, checking if it can be merged around
neighbors. The list provides O(1) access to prev/next, so it is pretty fast to check
it. Summarizing. If merged then large coalesced areas are created, if not the area
is just linked making more fragments.

There is one more thing that i should mention here. After modification of VA node,
its subtree_max_size is updated if it was/is the biggest area in its left or right
sub-tree. Apart of that it can also be populated back to upper levels to fix the tree.
For more details please have a look at the __augment_tree_propagate_from() function
and the description.

Tests and stressing
-------------------
I use the "test_vmalloc.sh" test driver available under "tools/testing/selftests/vm/"
since 5.1-rc1 kernel. Just trigger "sudo ./test_vmalloc.sh" to find out how to deal
with it.

Tested on different platforms including x86_64/i686/ARM64/x86_64_NUMA. Regarding last
one, i do not have any physical access to NUMA system, therefore i emulated it. The
time of stressing is days.

If you run the test driver in "stress mode", you also need the patch that is in
Andrew's tree but not in Linux 5.1-rc1. So, please apply it:

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/commit/?id=e0cf7749bade6da318e98e934a24d8b62fab512c

After massive testing, i have not identified any problems like memory leaks, crashes
or kernel panics. I find it stable, but more testing would be good.

Performance analysis
--------------------
I have used two systems to test. One is i5-3320M CPU @ 2.60GHz and another
is HiKey960(arm64) board. i5-3320M runs on 4.20 kernel, whereas Hikey960
uses 4.15 kernel. I have both system which could run on 5.1-rc1 as well, but
the results have not been ready by time i an writing this.

Currently it consist of 8 tests. There are three of them which correspond to different
types of splitting(to compare with default). We have 3 ones(see above). Another 5 do
allocations in different conditions.

a) sudo ./test_vmalloc.sh performance
When the test driver is run in "performance" mode, it runs all available tests pinned
to first online CPU with sequential execution test order. We do it in order to get stable
and repeatable results. Take a look at time difference in "long_busy_list_alloc_test".
It is not surprising because the worst case is O(N).

# i5-3320M
How many cycles all tests took:
CPU0=646919905370(default) cycles vs CPU0=193290498550(patched) cycles

# See detailed table with results here:
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/i5-3320M_performance_default.txt
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/i5-3320M_performance_patched.txt

# Hikey960 8x CPUs
How many cycles all tests took:
CPU0=3478683207 cycles vs CPU0=463767978 cycles

# See detailed table with results here:
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/HiKey960_performance_default.txt
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/HiKey960_performance_patched.txt

b) time sudo ./test_vmalloc.sh test_repeat_count=1
With this configuration, all tests are run on all available online CPUs. Before running
each CPU shuffles its tests execution order. It gives random allocation behaviour. So
it is rough comparison, but it puts in the picture for sure.

# i5-3320M
<default>            vs            <patched>
real    101m22.813s                real    0m56.805s
user    0m0.011s                   user    0m0.015s
sys     0m5.076s                   sys     0m0.023s

# See detailed table with results here:
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/i5-3320M_test_repeat_count_1_default.txt
ftp://vps418301.ovh.net/incoming/vmap_test_results_v2/i5-3320M_test_repeat_count_1_patched.txt

# Hikey960 8x CPUs
<default>            vs            <patched>
real    unknown                    real    4m25.214s
user    unknown                    user    0m0.011s
sys     unknown                    sys     0m0.670s

I did not manage to complete this test on "default Hikey960" kernel version.
After 24 hours it was still running, therefore i had to cancel it. That is why
real/user/sys are "unknown".

Changes in v4
-------------
- updated the commit message of [1] patch;
- simplify te compute_subtree_max_size() function by using max3() macro;
- added more explanation to find_va_links() function;
- reworked the function names;
- replace u8 type by using enum fit_type;
- when init the vmap free space, trigger WARN_ON_ONCE() if kmem_cache* fails;
- reworked a bit the pvm_determine_end_from_reverse() function;
- invert "if" condition in __get_va_next_sibling();
- removed intermediate function in [2] patch.

Changes in v3
-------------
- simplify the __get_va_next_sibling() and __find_va_links() functions;
- remove "unlikely". Place the WARN_ON_ONCE directly to the "if" condition;
- replace inline to __always_inline;
- move the debug code to separate patches;

Changes in v2
-------------
- do not distinguish vmalloc and other vmap allocations;
- use kmem_cache for vmap_area objects instead of own implementation;
- remove vmap cache globals;
- fix pcpu allocator on NUMA systems;
- now complexity is ~O(log(N)).

Uladzislau Rezki (Sony) (3):
  mm/vmap: keep track of free blocks for vmap allocation
  mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK macro
  mm/vmap: add DEBUG_AUGMENT_LOWEST_MATCH_CHECK macro

 include/linux/vmalloc.h |    6 +-
 mm/vmalloc.c            | 1095 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 854 insertions(+), 247 deletions(-)

-- 
2.11.0

