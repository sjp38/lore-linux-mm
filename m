Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E37C10F03
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 19:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FE46205C9
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 19:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SnRvf29k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FE46205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AC6B8E0004; Sun, 10 Mar 2019 15:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15DFD8E0002; Sun, 10 Mar 2019 15:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025AD8E0004; Sun, 10 Mar 2019 15:54:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C53F68E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 15:54:16 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h10so1731762otl.20
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 12:54:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=FlUXFEns5UtJwRic4qH/JXwTb0drcGEOPbRmIE5r6vY=;
        b=nwVB3qm2NvwdR1pOa90x54Eiyivdrxw3BwVMcG5kMBlgjpbJeRdf5vtASTeMchYejX
         5quCsfywJ/4Z1HTY+ILiCq8uaOsnk+L0wcbgs9fscem2aY0wWO7QTsfttFyCT9HlJrCV
         Ip2PC64Ygx4MLWpO88sk4B3sq97ckaKpg+AGYo8wPvvOdcmgQ3pKShjX15gkx0FmMLIp
         9dEQxn+M+GHoxNgsazY45hrF0TFF6+UriaWt/JC6xiEKvQ2oelWth8IcgA4Gt/pI9Zd5
         DvaxxRiwi67wVpgPUgjlKqSriUy1RbwL/1ARtD5PV6fuqA4xntls0MAEbE9XBRGg8c6R
         6wmQ==
X-Gm-Message-State: APjAAAUDs6R0psk3GMRYedm8WHfY0uAKz3x89Je/hdRQ18qOpI5VkpFg
	b+BMf275k21OkVTEa6S0ZvCbE6g5X6JvKKeB2F7qyZcrP87td1dkOZGdQ6vsuAhJ+/ClVjyijRE
	q9EI8jDEONtJD3AtU5RdhK1O9t4QOkXoU+qCwsSZpaPtrkILW8Xqsj/LyHt+zWlA6sb/TBr0Z1p
	iPpf7TC8/H47UniIo97QQa6OSHKCS6MdGsWHmHwcOGbOQ+RpUJm1HlV8/+wL0FLz8Yj4OcsMBt5
	QhsUvXXMKBjQ8ANGtLEW8vNgZRwSrl7ZeHG/z/WlyeCCV/R69pbEghOG0DwmXXTFGxNcZz0W8x3
	VQ2NTL8O6oj5/tAGWxcIHbgBUusBaUbGliSxvopPFrTcNMcW+qs12YUVnOyKBjwdQMFCMrLRHzd
	3
X-Received: by 2002:a9d:5f1a:: with SMTP id f26mr17339174oti.95.1552247656340;
        Sun, 10 Mar 2019 12:54:16 -0700 (PDT)
X-Received: by 2002:a9d:5f1a:: with SMTP id f26mr17339113oti.95.1552247654953;
        Sun, 10 Mar 2019 12:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552247654; cv=none;
        d=google.com; s=arc-20160816;
        b=Su1E4pjMd+YTV3FRuUdRVJmTHsHJBGRCk3vyo/Xo/KkeHZZj0s7qg0saTKLEPFLMfU
         krsIK0qTN/rLPxyzfCzE6mY3XB2uukvzdmwam1SF/0nU9Qyee5058bBc2xFLKMEmtMmv
         AwWReMnBMdBnFhb3shSC7vBUWACMPj6sXOroPyy5iKPTtVTahlWT/vpDbFbtOlOxsmh4
         5VHbKVIuMe7Y67ibLoF1DhXiwbshPwvLoWBTZ4W6KGmy1qt1hRhs+Kx/xODwnUt+SFh/
         0jgjiJ2hYNsKujiaes7RK2jD3utaLPV1oS7mEB3/JTXudPubFpy+1i42oGy9jMjZmXvC
         Siiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=FlUXFEns5UtJwRic4qH/JXwTb0drcGEOPbRmIE5r6vY=;
        b=ANQdtP3/rI/3SpFwIuYRcYMsA6mtoryHTsHDEN9t6fxDN08Ref8iTKIQkqCoanE62v
         mDdBMCjTUx0nONhgiGHjhUphZtuGx92+7XXdP+urqwRnuS0oEIIzT+sPQtw6O/CBR67j
         HW6gX/l7rTVIFVI39opSRn+H/HgVT2ak95jkIJ3XhYlEEhG35dlKgyD6vdUqGT3ptXmu
         w1BqjBiu0KzyrbB3atbg/i41J8SQ9DA4ZAp1RBXBRxYD4pD9eQUnwFNMRtLl0KsRHDTB
         hqWLcAn77uySEnWOFJjseerBFmet5WyQOXoDrInkU54C/kTcORTkfy+tH/dN5VUq4HHC
         2/2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SnRvf29k;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t67sor2217764otb.138.2019.03.10.12.54.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 12:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SnRvf29k;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=FlUXFEns5UtJwRic4qH/JXwTb0drcGEOPbRmIE5r6vY=;
        b=SnRvf29kXXovTvKK/X3pnvWp1mej2HF1z7WjLwENt/nkJizzzEW1WIot6dv48Feyja
         xpH1rmQbhzL94vZMprrYweqOBiY93RDXXvkSKvzoHc8jzZ88kL5HZV4U3e1vb0ZTPmCX
         0ZYjEfZBeiMyuN4rS4QKekhR22FqgVaOiZ2/OtukiCAZs1IiVt3D9balwM0TK1gwg79o
         8eo32jbYAJzmo+tbcFvt1fwX1ck93GEzZlNUjVqLsRGKbUfdXe9VSsySjO9kiUkp0DLn
         kGo13SQOeKUorzodN8+PGn/nS7KY0VsycPK2QY+zN89NZE+juuHPEj3dyMRc6kC7jwc6
         dciA==
X-Google-Smtp-Source: APXvYqzpMq+w+S3vTSGCvE8igAd0nxHnEpWSZ87yTQo1MeS/03fV3Uk5EpQsak5+CzSvbi39K6DnTeAmr268o31ZdTQ=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr5709060ota.214.1552247653800;
 Sun, 10 Mar 2019 12:54:13 -0700 (PDT)
MIME-Version: 1.0
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 10 Mar 2019 12:54:01 -0700
Message-ID: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
Subject: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus, please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
tags/devdax-for-5.1

...to receive new device-dax infrastructure to allow persistent memory
and other "reserved" / performance differentiated memories, to be
assigned to the core-mm as "System RAM".

While it has soaked in -next with only a simple conflict reported, and
Michal looked at this and said "overall design of this feature makes a
lot of sense to me" [1], it's lacking non-Intel review/ack tags. For
that reason, here's some more commentary on the motivation and
implications:

[1]: https://lore.kernel.org/lkml/20190123170518.GC4087@dhcp22.suse.cz/

Some users want to use persistent memory as additional volatile
memory. They are willing to cope with potential performance
differences, for example between DRAM and 3D Xpoint, and want to use
typical Linux memory management apis rather than a userspace memory
allocator layered over an mmap() of a dax file. The administration
model is to decide how much Persistent Memory (pmem) to use as System
RAM, create a device-dax-mode namespace of that size, and then assign
it to the core-mm. The rationale for device-dax is that it is a
generic memory-mapping driver that can be layered over any "special
purpose" memory, not just pmem. On subsequent boots udev rules can be
used to restore the memory assignment.

One implication of using pmem as RAM is that mlock() no longer keeps
data off persistent media. For this reason it is recommended to enable
NVDIMM Security (previously merged for 5.0) to encrypt pmem contents
at rest. We considered making this recommendation an actively enforced
requirement, but in the end decided to leave it as a distribution /
administrator policy to allow for emulation and test environments that
lack security capable NVDIMMs.

Here is the resolution for the aforementioned conflict:

diff --cc mm/memory_hotplug.c
index a9d5787044e1,b37f3a5c4833..c4f59ac21014
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@@ -102,28 -99,21 +102,24 @@@ u64 max_mem_size = U64_MAX
  /* add this memory to iomem resource */
  static struct resource *register_memory_resource(u64 start, u64 size)
  {
-       struct resource *res, *conflict;
+       struct resource *res;
+       unsigned long flags =  IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
+       char *resource_name = "System RAM";

 +      if (start + size > max_mem_size)
 +              return ERR_PTR(-E2BIG);
 +
-       res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-       if (!res)
-               return ERR_PTR(-ENOMEM);
-
-       res->name = "System RAM";
-       res->start = start;
-       res->end = start + size - 1;
-       res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
-       conflict =  request_resource_conflict(&iomem_resource, res);
-       if (conflict) {
-               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-                       pr_debug("Device unaddressable memory block "
-                                "memory hotplug at %#010llx !\n",
-                                (unsigned long long)start);
-               }
-               pr_debug("System RAM resource %pR cannot be added\n", res);
-               kfree(res);
+       /*
+        * Request ownership of the new memory range.  This might be
+        * a child of an existing resource that was present but
+        * not marked as busy.
+        */
+       res = __request_region(&iomem_resource, start, size,
+                              resource_name, flags);
+
+       if (!res) {
+               pr_debug("Unable to reserve System RAM region:
%016llx->%016llx\n",
+                               start, start + size);
                return ERR_PTR(-EEXIST);
        }
        return res;


* Note, I'm sending this with Gmail rather than Evolution (which goes
through my local Exchange server) as the latter mangles the message
into something the pr-tracker-bot decides to ignore. As a result,
please forgive white-space damage.

---

The following changes since commit bfeffd155283772bbe78c6a05dec7c0128ee500c:

  Linux 5.0-rc1 (2019-01-06 17:08:20 -0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
tags/devdax-for-5.1

for you to fetch changes up to c221c0b0308fd01d9fb33a16f64d2fd95f8830a4:

  device-dax: "Hotplug" persistent memory for use like normal RAM
(2019-02-28 10:41:23 -0800)

----------------------------------------------------------------
device-dax for 5.1
* Replace the /sys/class/dax device model with /sys/bus/dax, and include
  a compat driver so distributions can opt-in to the new ABI.

* Allow for an alternative driver for the device-dax address-range

* Introduce the 'kmem' driver to hotplug / assign a device-dax
  address-range to the core-mm.

* Arrange for the device-dax target-node to be onlined so that the newly
  added memory range can be uniquely referenced by numa apis.

----------------------------------------------------------------
Dan Williams (11):
      device-dax: Kill dax_region ida
      device-dax: Kill dax_region base
      device-dax: Remove multi-resource infrastructure
      device-dax: Start defining a dax bus model
      device-dax: Introduce bus + driver model
      device-dax: Move resource pinning+mapping into the common driver
      device-dax: Add support for a dax override driver
      device-dax: Add /sys/class/dax backwards compatibility
      acpi/nfit, device-dax: Identify differentiated memory with a
unique numa-node
      device-dax: Auto-bind device after successful new_id
      device-dax: Add a 'target_node' attribute

Dave Hansen (5):
      mm/resource: Return real error codes from walk failures
      mm/resource: Move HMM pr_debug() deeper into resource code
      mm/memory-hotplug: Allow memory resources to be children
      mm/resource: Let walk_system_ram_range() search child resources
      device-dax: "Hotplug" persistent memory for use like normal RAM

Vishal Verma (1):
      device-dax: Add a 'modalias' attribute to DAX 'bus' devices

 Documentation/ABI/obsolete/sysfs-class-dax |  22 ++
 arch/powerpc/platforms/pseries/papr_scm.c  |   1 +
 drivers/acpi/nfit/core.c                   |   8 +-
 drivers/acpi/numa.c                        |   1 +
 drivers/base/memory.c                      |   1 +
 drivers/dax/Kconfig                        |  28 +-
 drivers/dax/Makefile                       |   6 +-
 drivers/dax/bus.c                          | 503 +++++++++++++++++++++++++++++
 drivers/dax/bus.h                          |  61 ++++
 drivers/dax/dax-private.h                  |  34 +-
 drivers/dax/dax.h                          |  18 --
 drivers/dax/device-dax.h                   |  25 --
 drivers/dax/device.c                       | 363 +++++----------------
 drivers/dax/kmem.c                         | 108 +++++++
 drivers/dax/pmem.c                         | 153 ---------
 drivers/dax/pmem/Makefile                  |   7 +
 drivers/dax/pmem/compat.c                  |  73 +++++
 drivers/dax/pmem/core.c                    |  71 ++++
 drivers/dax/pmem/pmem.c                    |  40 +++
 drivers/dax/super.c                        |  41 ++-
 drivers/nvdimm/e820.c                      |   1 +
 drivers/nvdimm/nd.h                        |   2 +-
 drivers/nvdimm/of_pmem.c                   |   1 +
 drivers/nvdimm/region_devs.c               |   1 +
 include/linux/acpi.h                       |   5 +
 include/linux/libnvdimm.h                  |   1 +
 kernel/resource.c                          |  18 +-
 mm/memory_hotplug.c                        |  33 +-
 tools/testing/nvdimm/Kbuild                |   7 +-
 tools/testing/nvdimm/dax-dev.c             |  16 +-
 30 files changed, 1112 insertions(+), 537 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-class-dax
 create mode 100644 drivers/dax/bus.c
 create mode 100644 drivers/dax/bus.h
 delete mode 100644 drivers/dax/dax.h
 delete mode 100644 drivers/dax/device-dax.h
 create mode 100644 drivers/dax/kmem.c
 delete mode 100644 drivers/dax/pmem.c
 create mode 100644 drivers/dax/pmem/Makefile
 create mode 100644 drivers/dax/pmem/compat.c
 create mode 100644 drivers/dax/pmem/core.c
 create mode 100644 drivers/dax/pmem/pmem.c

