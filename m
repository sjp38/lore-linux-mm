Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D39B96B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:53:11 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id ho8so10397075pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:53:11 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id e12si11583812pap.197.2016.01.27.12.53.10
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 12:53:11 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Date: Wed, 27 Jan 2016 20:53:09 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE04217CB7B@FMSMSX114.amr.corp.intel.com>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
	<20160127123131.2be09678d5b477386497ade7@linux-foundation.org>
 <20160127123933.bcfef2fe5bcdc5bb6714eec7@linux-foundation.org>
In-Reply-To: <20160127123933.bcfef2fe5bcdc5bb6714eec7@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

Yeah, I need to rebase.  Please drop for now, I'll resend tomorrow.

See you Monday, I assume ;-)

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Wednesday, January 27, 2016 12:40 PM
To: Wilcox, Matthew R; Matthew Wilcox; linux-mm@kvack.org; linux-nvdimm@ml0=
1.01.org; linux-fsdevel@vger.kernel.org; linux-kernel@vger.kernel.org; x86@=
kernel.org
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files

On Wed, 27 Jan 2016 12:31:31 -0800 Andrew Morton <akpm@linux-foundation.org=
> wrote:

> Just from eyeballing the patches, I'm expecting build errors ;)

Didn't take long :(

mm/memory.c: In function 'zap_pud_range':
mm/memory.c:1216: error: implicit declaration of function 'pud_trans_huge'
mm/memory.c:1217: error: 'HPAGE_PUD_SIZE' undeclared (first use in this fun=
ction)

and, midway:

include/linux/mm.h:348: error: redefinition of 'pud_devmap'
include/asm-generic/pgtable.h:684: note: previous definition of 'pud_devmap=
' was here

Please run x86_64 allnoconfig at each step of the series, fix and
respin?  It only takes 30s to compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
