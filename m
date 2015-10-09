Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CE5636B0038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 17:43:55 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so96996671pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 14:43:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zl1si5461114pbc.95.2015.10.09.14.43.54
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 14:43:54 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH][RFC] mm: Introduce kernelcore=reliable option
Date: Fri, 9 Oct 2015 21:43:50 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B534D5@ORSMSX114.amr.corp.intel.com>
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com>
In-Reply-To: <561762DC.3080608@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Hansen, Dave" <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>

> I remember Kame has already suggested this idea. In my opinion,
> I still think it's better to add a new migratetype or a new zone,
> so both user and kernel could use mirrored memory.

A new zone would be more flexible ... and probably the right long
term solution.  But this looks like a very clever was to try out the
feature with a minimally invasive patch.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
