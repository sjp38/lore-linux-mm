Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 53B6E6B00B8
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 12:11:28 -0500 (EST)
Received: by bwz7 with SMTP id 7so752324bwz.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 09:11:26 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v0 0/3] cgroup notifications API and memory thresholds
Date: Thu, 26 Nov 2009 19:11:14 +0200
Message-Id: <cover.1259255307.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

It's my first attempt to implement cgroup notifications API and memory
thresholds on top of it. The idea of API was proposed by Paul Menage.

It lacks some important features and need more testing, but I want publish
it as soon as possible to get feedback from community.

TODO:
 - memory thresholds on root cgroup;
 - memsw support;
 - documentation.

Kirill A. Shutemov (3):
  cgroup: implement eventfd-based generic API for notifications
  res_counter: implement thresholds
  memcg: implement memory thresholds

 include/linux/cgroup.h      |    8 ++
 include/linux/res_counter.h |   44 +++++++++++
 kernel/cgroup.c             |  181 ++++++++++++++++++++++++++++++++++++++++++-
 kernel/res_counter.c        |    4 +
 mm/memcontrol.c             |  149 +++++++++++++++++++++++++++++++++++
 5 files changed, 385 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
