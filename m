Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3A06B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 13:26:57 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so1924876pab.34
        for <linux-mm@kvack.org>; Fri, 30 May 2014 10:26:57 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gr3si6347918pbb.210.2014.05.30.10.26.56
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 10:26:56 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 0/3] HWPOISON: improve memory error handling for
 multithread process
Date: Fri, 30 May 2014 17:25:39 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32823225@ORSMSX114.amr.corp.intel.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
 <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> This patchset is the summary of recent discussion about memory error hand=
ling
> on multithread application. Patch 1 and 2 is for action required errors, =
and
> patch 3 is for action optional errors.

Naoya,

You suggested early in the discussion (when there were just two patches) th=
at
they deserved a "Cc: stable@vger.kernel.org".  I agreed, and still think th=
e same
way.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
