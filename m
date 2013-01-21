Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6F1BF6B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 23:13:14 -0500 (EST)
From: Tony Lu <zlu@tilera.com>
Subject: [PATCH 1/1] mm/hugetlb: Set PTE as huge in hugetlb_change_protection
Date: Mon, 21 Jan 2013 04:13:07 +0000
Message-ID: <BAB94DBB0E89D8409949BC28AC95914C47B123D2@USMAExch1.tad.internal.tilera.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Tony Lu <zlu@tilera.com>

