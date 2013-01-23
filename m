Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 36C3A6B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 20:56:42 -0500 (EST)
From: Tony Lu <zlu@tilera.com>
Subject: [PATCH v2] mm/hugetlb: Set PTE as huge in hugetlb_change_protection
Date: Wed, 23 Jan 2013 01:56:29 +0000
Message-ID: <BAB94DBB0E89D8409949BC28AC95914C47B12B8D@USMAExch1.tad.internal.tilera.com>
References: <BAB94DBB0E89D8409949BC28AC95914C47B123D2@USMAExch1.tad.internal.tilera.com>
	<20130121100410.GE7798@dhcp22.suse.cz>
	<BAB94DBB0E89D8409949BC28AC95914C47B12789@USMAExch1.tad.internal.tilera.com>
 <CAJd=RBD-C5dUJL-S8aRk-yQ2-7+GUdQRGJuyxsnymG8k9P8ppw@mail.gmail.com>
In-Reply-To: <CAJd=RBD-C5dUJL-S8aRk-yQ2-7+GUdQRGJuyxsnymG8k9P8ppw@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, "stable@kernel.org" <stable@kernel.org>, Tony Lu <zlu@tilera.com>

