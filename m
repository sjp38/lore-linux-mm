Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D424B6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 19:44:33 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RESEND PATCH v2 1/4] mm/hwpoison: fix traverse hugetlbfs page
 to avoid printk flood
Date: Mon, 16 Sep 2013 23:44:32 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F31CFD50B@ORSMSX106.amr.corp.intel.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130915001352.GQ18242@two.firstfloor.org>
 <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
 <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
 <20130916232345.GA3241@hacker.(null)>
In-Reply-To: <20130916232345.GA3241@hacker.(null)>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>>Sorry, I have no meaningful progress on this. Splitting hugepages is not
>>a trivial operation, and introduce more complexity on hugetlbfs code.
>>I don't hit on any usecase of it rather than memory failure, so I'm not
>>sure that it's worth doing now.
>
> Agreed. ;-)

Agreed that huge pages should be split - or that it is not worth splitting =
them?

Actually I wonder how useful huge pages still are - transparent huge pages =
may
give most of the benefits without having to modify applications to use them=
.
Plus the kernel does know how to split them when an error occurs (which I c=
are
about more than most people).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
