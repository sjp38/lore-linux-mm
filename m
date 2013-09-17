Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 00F6F6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 12:47:42 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RESEND PATCH v2 1/4] mm/hwpoison: fix traverse hugetlbfs page
 to avoid printk flood
Date: Tue, 17 Sep 2013 16:47:39 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F31CFEAC9@ORSMSX106.amr.corp.intel.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130915001352.GQ18242@two.firstfloor.org>
 <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
 <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
 <20130916232345.GA3241@hacker.(null)>
 <3908561D78D1C84285E8C5FCA982C28F31CFD50B@ORSMSX106.amr.corp.intel.com>
 <20130917000817.GA5996@hacker.(null)>
In-Reply-To: <20130917000817.GA5996@hacker.(null)>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wu,
 Fengguang" <fengguang.wu@intel.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Transparent huge pages are not helpful for DB workload which there is a l=
ot of=20
> shared memory

Hmm. Perhaps they should be.  If a database allocates most[1] of the memory=
 on a
machine to a shared memory segment - that *ought* to be a candidate for usi=
ng
transparent huge pages.  Now that we have them they seem a better choice (m=
uch
more flexibility) than hugetlbfs.

-Tony

[1] I've been told that it is normal to configure over 95% of physical memo=
ry to the
shared memory region to run a particular transaction based benchmark with o=
ne
commercial data base application.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
