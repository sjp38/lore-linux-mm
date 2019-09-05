Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF249C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:57:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2C2B20825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:57:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="db5moETJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2C2B20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4436B0003; Thu,  5 Sep 2019 17:57:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A40E6B0005; Thu,  5 Sep 2019 17:57:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BAFE6B0007; Thu,  5 Sep 2019 17:57:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id EF1286B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:57:34 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7E9534FEC
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:57:34 +0000 (UTC)
X-FDA: 75902229228.09.fork31_5f2be91f20753
X-HE-Tag: fork31_5f2be91f20753
X-Filterd-Recvd-Size: 8920
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:57:33 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85Lhr2t032677
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=6+x6B4MHxrLYAe7QaNtIURxgkLbofTz5KDyctfNFi2k=;
 b=db5moETJTxmxMRmjEX8PmSCqZrcoPN29twcu753JN6vBw9lTsZ31xABBo5BmhovG2T41
 8IRdwcqmL0YQbc2DwiBsRg8qUCUgF4TFsxjm6pXLUzt1U9ErhqQxPpb3AqIEDodUnUuT
 jGMlB46e5cWUrEmvUhPJoEbNVNAQqxK1cNc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2utksg62eu-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:09 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:08 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id A051F17229DF6; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH RFC 00/14] The new slab memory controller
Date: Thu, 5 Sep 2019 14:45:44 -0700
Message-ID: <20190905214553.1643060-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 malwarescore=0
 clxscore=1015 impostorscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 priorityscore=1501 suspectscore=0 phishscore=0
 adultscore=0 bulkscore=0 spamscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The existing slab memory controller is based on the idea of replicating
slab allocator internals for each memory cgroup. This approach promises
a low memory overhead (one pointer per page), and isn't adding too much
code on hot allocation and release paths. But is has a very serious flaw:
it leads to a low slab utilization.

Using a drgn* script I've got an estimation of slab utilization on
a number of machines running different production workloads. In most
cases it was between 45% and 65%, and the best number I've seen was
around 85%. Turning kmem accounting off brings it to high 90s. Also
it brings back 30-50% of slab memory. It means that the real price
of the existing slab memory controller is way bigger than a pointer
per page.

The real reason why the existing design leads to a low slab utilization
is simple: slab pages are used exclusively by one memory cgroup.
If there are only few allocations of certain size made by a cgroup,
or if some active objects (e.g. dentries) are left after the cgroup is
deleted, or the cgroup contains a single-threaded application which is
barely allocating any kernel objects, but does it every time on a new CPU:
in all these cases the resulting slab utilization is very low.
If kmem accounting is off, the kernel is able to use free space
on slab pages for other allocations.

Arguably it wasn't an issue back to days when the kmem controller was
introduced and was an opt-in feature, which had to be turned on
individually for each memory cgroup. But now it's turned on by default
on both cgroup v1 and v2. And modern systemd-based systems tend to
create a large number of cgroups.

This patchset provides a new implementation of the slab memory controller,
which aims to reach a much better slab utilization by sharing slab pages
between multiple memory cgroups. Below is the short description of the new
design (more details in commit messages).

Accounting is performed per-object instead of per-page. Slab-related
vmstat counters are converted to bytes. Charging is performed on page-basis,
with rounding up and remembering leftovers.

Memcg ownership data is stored in a per-slab-page vector: for each slab page
a vector of corresponding size is allocated. To keep slab memory reparenting
working, instead of saving a pointer to the memory cgroup directly an
intermediate object is used. It's simply a pointer to a memcg (which can be
easily changed to the parent) with a built-in reference counter. This scheme
allows to reparent all allocated objects without walking them over and changing
memcg pointer to the parent.

Instead of creating an individual set of kmem_caches for each memory cgroup,
two global sets are used: the root set for non-accounted and root-cgroup
allocations and the second set for all other allocations. This allows to
simplify the lifetime management of individual kmem_caches: they are destroyed
with root counterparts. It allows to remove a good amount of code and make
things generally simpler.

The patchset contains a couple of semi-independent parts, which can find their
usage outside of the slab memory controller too:
1) subpage charging API, which can be used in the future for accounting of
   other non-page-sized objects, e.g. percpu allocations.
2) mem_cgroup_ptr API (refcounted pointers to a memcg, can be reused
   for the efficient reparenting of other objects, e.g. pagecache.

The patchset has been tested on a number of different workloads in our
production. In all cases, it saved hefty amounts of memory:
1) web frontend, 650-700 Mb, ~42% of slab memory
2) database cache, 750-800 Mb, ~35% of slab memory
3) dns server, 700 Mb, ~36% of slab memory

So far I haven't found any regression on all tested workloads, but
potential CPU regression caused by more precise accounting is a concern.

Obviously the amount of saved memory depend on the number of memory cgroups,
uptime and specific workloads, but overall it feels like the new controller
saves 30-40% of slab memory, sometimes more. Additionally, it should lead
to a lower memory fragmentation, just because of a smaller number of
non-movable pages and also because there is no more need to move all
slab objects to a new set of pages when a workload is restarted in a new
memory cgroup.

* https://github.com/osandov/drgn


Roman Gushchin (14):
  mm: memcg: subpage charging API
  mm: memcg: introduce mem_cgroup_ptr
  mm: vmstat: use s32 for vm_node_stat_diff in struct per_cpu_nodestat
  mm: vmstat: convert slab vmstat counter to bytes
  mm: memcg/slab: allocate space for memcg ownership data for non-root
    slabs
  mm: slub: implement SLUB version of obj_to_index()
  mm: memcg/slab: save memcg ownership data for non-root slab objects
  mm: memcg: move memcg_kmem_bypass() to memcontrol.h
  mm: memcg: introduce __mod_lruvec_memcg_state()
  mm: memcg/slab: charge individual slab objects instead of pages
  mm: memcg: move get_mem_cgroup_from_current() to memcontrol.h
  mm: memcg/slab: replace memcg_from_slab_page() with
    memcg_from_slab_obj()
  mm: memcg/slab: use one set of kmem_caches for all memory cgroups
  mm: slab: remove redundant check in memcg_accumulate_slabinfo()

 drivers/base/node.c        |  11 +-
 fs/proc/meminfo.c          |   4 +-
 include/linux/memcontrol.h | 102 ++++++++-
 include/linux/mm_types.h   |   5 +-
 include/linux/mmzone.h     |  12 +-
 include/linux/slab.h       |   3 +-
 include/linux/slub_def.h   |   9 +
 include/linux/vmstat.h     |   8 +
 kernel/power/snapshot.c    |   2 +-
 mm/list_lru.c              |  12 +-
 mm/memcontrol.c            | 431 +++++++++++++++++++++--------------
 mm/oom_kill.c              |   2 +-
 mm/page_alloc.c            |   8 +-
 mm/slab.c                  |  37 ++-
 mm/slab.h                  | 300 +++++++++++++------------
 mm/slab_common.c           | 449 ++++---------------------------------
 mm/slob.c                  |  12 +-
 mm/slub.c                  |  63 ++----
 mm/vmscan.c                |   3 +-
 mm/vmstat.c                |  38 +++-
 mm/workingset.c            |   6 +-
 21 files changed, 683 insertions(+), 834 deletions(-)

-- 
2.21.0


