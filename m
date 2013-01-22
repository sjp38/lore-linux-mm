Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id ABF956B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 21:37:24 -0500 (EST)
From: Tony Lu <zlu@tilera.com>
Subject: RE: [PATCH 1/1] mm/hugetlb: Set PTE as huge in
 hugetlb_change_protection
Date: Tue, 22 Jan 2013 02:37:15 +0000
Message-ID: <BAB94DBB0E89D8409949BC28AC95914C47B12789@USMAExch1.tad.internal.tilera.com>
References: <BAB94DBB0E89D8409949BC28AC95914C47B123D2@USMAExch1.tad.internal.tilera.com>
 <20130121100410.GE7798@dhcp22.suse.cz>
In-Reply-To: <20130121100410.GE7798@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>

>-----Original Message-----
>From: Michal Hocko [mailto:mhocko@suse.cz]
>Sent: Monday, January 21, 2013 6:04 PM
>To: Tony Lu
>Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; Andrew Morton; Anees=
h
>Kumar K.V; Hillf Danton; KAMEZAWA Hiroyuki; Chris Metcalf
>Subject: Re: [PATCH 1/1] mm/hugetlb: Set PTE as huge in
>hugetlb_change_protection
>
>On Mon 21-01-13 04:13:07, Tony Lu wrote:
>> From da8432aafd231e7cdcda9d15484829def4663cb0 Mon Sep 17 00:00:00 2001
>> From: Zhigang Lu <zlu@tilera.com>
>> Date: Mon, 21 Jan 2013 11:23:26 +0800
>> Subject: [PATCH 1/1] mm/hugetlb: Set PTE as huge in hugetlb_change_prote=
ction
>>
>> When setting a huge PTE, besides calling pte_mkhuge(), we also need
>> to call arch_make_huge_pte(), which we indeed do in make_huge_pte(),
>> but we forget to do in hugetlb_change_protection().
>
>I guess you also need it in remove_migration_pte. This calls for a
>helper which would do both pte_mkhuge() and arch_make_huge_pte.
>
>Besides that, tile seem to be the only arch which implements this arch
>hook (introduced by 621b1955 in 3.5) so this should be considered for
>stable.

Thank you. Yes, remove_migration_pte also needs it. Here is the updated pat=
ch.
