Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81860C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC372075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tj71Gjmb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC372075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C5006B0005; Tue,  2 Apr 2019 12:25:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 773AB6B0269; Tue,  2 Apr 2019 12:25:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616E76B026A; Tue,  2 Apr 2019 12:25:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E79FB6B0005
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:25:42 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id z25so3634035ljb.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:25:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=AF88+rdJYZ1fihbYOPZU+DYFykFptNPiZ9Q6sC7f42M=;
        b=esG35LXFrIcWQNZMVG/7psHId7n+W4u4Bj/Cxf1KalBbwtzaITVfmYeaSqSkmt1Nw8
         yD8s6jVsY/laXw6j/IE0Tevoak8V3SPHDDIv0rDzZ/Ru/JtL+fbWNkllaP8k+n2DoFcF
         BepOrAj831lzWWCOltKjHmW/qxKekbnNVPQDrdys//Q+gU2ZlbNliA14fTexxJGlEwE2
         BkZkHTmwB0i/TV2ZRztKhV7dEVB6FqbdYA/drmJ+fE+7S8EsAew1SjfVtmvArhTcKV2o
         BkXzj5Xw5Zm3E+OhJnaZRwl6ArM7hHC3IvGt/yZjjoVsnzrA3IJVzHLx36ggBXPNP1Ho
         CPGQ==
X-Gm-Message-State: APjAAAU6MW3IvK1qBCuu0VJzPXD2rRtUAWp6oATzToQl7BMvA3Y6ey4P
	GxvpJ0XMXrKjbI9BE+1eaLEbCPD6ZwpaEBXRVlSMdPsNtGchGAmb840B2RKmwkdumcEUo5v11kG
	PlKkEubxHBAnSFXY4ODMJIQ9ratukvsVzBOTNrH81u26Uh77tfB1CBZ2K1vcaOst/AA==
X-Received: by 2002:ac2:4285:: with SMTP id m5mr9874446lfh.103.1554222342151;
        Tue, 02 Apr 2019 09:25:42 -0700 (PDT)
X-Received: by 2002:ac2:4285:: with SMTP id m5mr9874368lfh.103.1554222340659;
        Tue, 02 Apr 2019 09:25:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554222340; cv=none;
        d=google.com; s=arc-20160816;
        b=DLVg9HzcLHc3CYBUw1QJtLlZmIJvRBDMDzPDaR4IkXej0UWDmnq6mkIGGwMPmeeZ5E
         edV6B+vbYt2feCxFt4yyYCb+9ytAURgGbquUtn5mHbK6HeVTaFPagXSNNyYIcCu4qS2R
         vWAahovngyEUrdKU+Dtorlg5u84Y/L2khhsC8kLBVlsocZg1TPyl+f9QCcx3JJyCSmlV
         rJ2c9ttEh0olJLWDvZUQcKxIpjk3ROn13jcdgqgSGEWaoVJKjdtUKxogC9GFJdsLJ0fu
         muJbMBPgVIrxwsAMA7O9GUjWxfm5niGRLu+n9msVSS9e7hObNzUZ/A0hgvPYDOzdEqH1
         JtZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=AF88+rdJYZ1fihbYOPZU+DYFykFptNPiZ9Q6sC7f42M=;
        b=l1xBut+cG5boxqIpViPueFhFSCDEUjtrPKmjGvXOBHMbILBSzpAufOWiy/1qmv4WJg
         i3eSjM/21R+j429Hehe3wFGLxpxvfNlUqANpQ0JHquvlb8emi7h6tEdH1Vtd7PkXJXuq
         VDM0bq9CgNq+weoFAR9etBufxoTq71hxRckL+IlyDIgeVHppSF/NPcjo5ogmhhLRkgIM
         MjadXGb3fx0KwV2VauL5RMYi2f5dy4jiiC7WbRnv9Q7cqJeB4K5JFfRHBKXuAbXyRm0/
         iMx7mVgs0161kXnGGSDmxLdk8PUmjFJfhsDlnYUGznlk8JTvtQl0+qwxSnnUL3FKtzCS
         AJVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tj71Gjmb;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u25sor8564487ljj.11.2019.04.02.09.25.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:25:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tj71Gjmb;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=AF88+rdJYZ1fihbYOPZU+DYFykFptNPiZ9Q6sC7f42M=;
        b=tj71Gjmbqz4YdgK57AN3omXOJAzQIrsd8qB4Et9FVDH8yC0TVhu/YIf4o9KpJtiZrb
         Kt891LLMKH3hfrFYj0jChNFKTiiEjD4ajZQqE/BrjJN7/MdumBUhZxy1Ln58N1s1EAqI
         AbvJkOvzzQrYpE8FMyv4cAQ26HZJWQPr8BXDOUgqTahqR7zkvvws5BlNK9+4LOdcgwIU
         wpnVZpIQzCpf8YD3aU7GT9+U5bn4HX9vLj2Qi5CATLEUl6emO5UucXxf/UYyr3PEeNOY
         10OTq3PIIWj4p0qWGMDnebIrKn+o7zw6IVnQQk4qj8/yXnX8ImekbbPrHghvsPJVHA39
         bYag==
X-Google-Smtp-Source: APXvYqyMIfNruyy/R5DacJgv1TuSsHIJ3wvA0vVDedEGREPYQ3buwgXIRSqkR/dFHBXHUCpF2Y/P5Q==
X-Received: by 2002:a2e:4a09:: with SMTP id x9mr26929080lja.19.1554222340204;
        Tue, 02 Apr 2019 09:25:40 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id 13sm2550377lfy.2.2019.04.02.09.25.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:25:39 -0700 (PDT)
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
Subject: [RESEND PATCH 0/3] improve vmap allocation
Date: Tue,  2 Apr 2019 18:25:28 +0200
Message-Id: <20190402162531.10888-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

This is the v3.

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
 mm/vmalloc.c            | 1098 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 857 insertions(+), 247 deletions(-)

-- 
2.11.0

