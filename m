Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDC106B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:33:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f12-v6so8020495iob.11
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:33:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e10-v6si7272196iof.90.2018.06.15.12.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 12:33:02 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5FJTJPc015463
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:33:01 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2jk0xr2692-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:33:01 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5FJWxgp013865
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:32:59 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5FJWx0p007059
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:32:59 GMT
Received: by mail-ot0-f173.google.com with SMTP id 101-v6so12203833oth.4
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:32:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180615155733.1175-1-pasha.tatashin@oracle.com> <20180615181113.GA27558@techadventures.net>
In-Reply-To: <20180615181113.GA27558@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 15 Jun 2018 15:32:23 -0400
Message-ID: <CAGM2rea+sUcewR+Ur58gNFC-fkdnK5_UHh6qgOvARpZ7un2n_A@mail.gmail.com>
Subject: Re: [PATCH] mm: skip invalid pages block at a time in zero_resv_unresv
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de, willy@infradead.org, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

> Hi Pavel,
>
> Thanks for the patch.
> This looks good to me.
>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thank you Oscar!

Pavel
