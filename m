Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A88D82F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 14:17:13 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so64014150pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 11:17:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pn6si14993667pbb.43.2015.10.21.11.17.12
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 11:17:12 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
Date: Wed, 21 Oct 2015 18:17:06 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

+	if (reliable_kernelcore) {
+		for_each_memblock(memory, r) {
+			if (memblock_is_mirror(r))
+				continue;

Should we have a safety check here that there is some mirrored memory?  If =
you give
the kernelcore=3Dreliable option on a machine which doesn't have any mirror=
 configured,
then we'll mark all memory as removable.  What happens then?  Do kernel all=
ocations
fail?  Or do they fall back to using removable memory?

Is there a /proc or /sys file that shows the current counts for the removab=
le zone?  I just
tried this patch with a high percentage of memory marked as mirror ... but =
I'd like to see
how much is actually being used to tune things a bit.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
