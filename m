Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 42C846B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:14:35 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so1727205pde.10
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:14:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id wm7si2398475pab.274.2014.03.13.16.14.32
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 16:14:33 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 4/6] fs/proc/page.c: introduce /proc/kpagecache interface
Date: Thu, 13 Mar 2014 23:09:10 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F31E04DD3@ORSMSX106.amr.corp.intel.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1394746786-6397-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi
 Nomura <j-nomura@ce.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Usage is simple: 1) write a file path to be scanned into the interface,
> and 2) read 64-bit entries, each of which is associated with the page on
> each page index.

Do we have other interfaces that work like that?  I suppose this is file is=
 only open
to "root", so it may be safe to assume that applications using this won't s=
tomp on
each other.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
