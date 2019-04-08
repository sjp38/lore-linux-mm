Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EA98C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C820220880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C820220880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 648D16B0005; Mon,  8 Apr 2019 06:12:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F7F06B0006; Mon,  8 Apr 2019 06:12:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E7176B0008; Mon,  8 Apr 2019 06:12:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5486B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 06:12:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d49so12180355qtk.8
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 03:12:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ZUL8Fv31s+1wfFRlAq3PiY1SqK5fwriE7DqsfWk4nwg=;
        b=jSxw2olAQ4iiVgYgn8JjfnFqNRWAkCB5qsh33f3c7EcQV2gy6+2K8yFaxk4xL6UF4Z
         tvlNXY//z6J15rF7pRFj3zn5HYU3KeXprBNf9FZ4n3lE+qe+voDhzq+2AONkbE5DRE2j
         UVy+hZjK99e1cE5GftAez0PT/hDgo0lQWN7/hoNKWXyRUOIK7UJ4VYuFbE6fywYB0BDd
         nltoG1UQsfErBDhGr9d8DlilvARStZ1B9pXDweuAat7laRn5Ly3t8t8mWhz/2uPw2esb
         D2t7C31O+Kp8j+unDit/kHU+I96pR+AGNB383LFzP+/IBwUby+0qWGkDSDtsLQxHAM7r
         UulA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUiP+kbxx6sWOSP7YWOhFKYKJHBOYfGhNwJNJ76M2HPYSOWn+z5
	wNHNJj7D8dBGPaLUyW7ovoqiQAI9TQB3mAsaNdLMXo6/DGkVThoMFvyhsvfF4eOuoHhJ5ygHV7p
	7lKTKhIUc9/rYQdL3MPSPNGPq9QqGQg9lUiM2RskClI6+mNnvwY9E8GaltSmCgnPHvA==
X-Received: by 2002:ac8:30d1:: with SMTP id w17mr22593557qta.4.1554718355970;
        Mon, 08 Apr 2019 03:12:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweobNnabIb94rcbSRNF1ZdtJ2pR4essLH/Udn5wF4KnoMzvj/56XmhB5qrvUsB+PyuUpVv
X-Received: by 2002:ac8:30d1:: with SMTP id w17mr22593531qta.4.1554718355356;
        Mon, 08 Apr 2019 03:12:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554718355; cv=none;
        d=google.com; s=arc-20160816;
        b=JVkgMwlSkDnQo9sV4ssV5c5Ib8OEm0Ul2yiqGaIzcwebqCXiDdAz85YXiOH9jZKzBB
         sJWtG31DYYI4tLaRLD1ZPLYbTPwkrt/J69jg61/XuhWQDgZPNON/dXZGOXNHdAqjEJaQ
         r5mIcopvJgFaKL5UJFZVNMF22GX7KubIHxn1Go41vuC/jR6OoLr8E41slO7CG8389hr0
         P/ynAex5iYg/EkcaSv/qEBKIfhbKN22zi7La35p7Qm9Y7Se8J7/BKXgVSG0dL+1C2lGL
         Skdf5yJACRREum7nxaOPfD34o1z1IIh4HeAx2RzgqoGAPGASRTQ8goPGrg5uXYWe714o
         Gqvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ZUL8Fv31s+1wfFRlAq3PiY1SqK5fwriE7DqsfWk4nwg=;
        b=Q5X0Lnwjww//y1se+3TkQ/cEPOG2ubVSaA6Jj8mJBwYZK8kHMcMc0jhDXirFapkuUi
         oYNN7KrrxhtYwkXs4PSPyZCYc99wzfb9Oq2+qurTs7lwh9zDRrD+4BGgWX65tjM5jjtt
         nOh05tQfUCdLthq7ElqMYHfiAzoI44BJJKn1GX1syBgXG4gaa4YTEfX4pq9cksKJwpPk
         MOutsd2kmWEGV8MQkVoXpCP3xLBnKdtriI8EgxPNpauEnZLC2jIzYDQspyczIcGiCjf1
         CYhwWa/STuibAa0OB0rV4Vc98F+7EEmITP/NZMlUCI4pXSZDOByQ6sjd33FZGPjLQbcN
         K11A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b47si5140833qvd.155.2019.04.08.03.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 03:12:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3BF2D30821C0;
	Mon,  8 Apr 2019 10:12:34 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-53.ams2.redhat.com [10.36.117.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9E39319C57;
	Mon,  8 Apr 2019 10:12:27 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	mike.travis@hpe.com,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	linux-mm@kvack.org,
	dan.j.williams@intel.com,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 0/3] mm/memory_hotplug: Factor out memory block device handling
Date: Mon,  8 Apr 2019 12:12:23 +0200
Message-Id: <20190408101226.20976-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 08 Apr 2019 10:12:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We only want memory block devices for memory to be onlined/offlined
(add/remove from the buddy). This is required so user space can
online/offline memory and kdump gets notified about newly onlined memory.

Only such memory has the requirement of having to span whole memory blocks.
Let's factor out creation/removal of memory block devices.

This not only allows to clean up arch_add_memory() to get rid of
want_memblock, but also reduces locking overhead and eventually allows
us to handle errors while adding memory in a nicer fashion.

Only did a quick sanity test with DIMM plug/unplug. This should be
sufficient to discuss the general approach. Patches are against
next/master.

David Hildenbrand (3):
  mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
  mm/memory_hotplug: Create memory block devices after arch_add_memory()
  mm/memory_hotplug: Remove memory block devices before
    arch_remove_memory()

 drivers/base/memory.c  | 108 +++++++++++++++++++++--------------------
 drivers/base/node.c    |   7 ++-
 include/linux/memory.h |   4 +-
 include/linux/node.h   |   6 +--
 mm/memory_hotplug.c    |  38 +++++++--------
 5 files changed, 81 insertions(+), 82 deletions(-)

-- 
2.17.2

