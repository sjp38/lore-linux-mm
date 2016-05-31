Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9546B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:15:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b126so96026023ite.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:15:14 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z12si43491478iof.93.2016.05.31.02.15.12
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 02:15:13 -0700 (PDT)
Date: Tue, 31 May 2016 18:15:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
Message-ID: <20160531091550.GA19976@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
MIME-Version: 1.0
In-Reply-To: <1463779979.22178.142.camel@linux.intel.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, May 20, 2016 at 02:32:59PM -0700, Tim Chen wrote:
> This patch consolidates the page out and the various cleanup operations
> within shrink=5Fpage=5Flist function into handle=5Fpgout and pg=5Ffinish
> functions.
>=20
> This makes the shrink=5Fpage=5Flist function more concise and allows for
> the separation of page out and page scan operations.
> It paves the way to group similar pages together and batch
> process them in the page out path for better efficiency.
>=20
> After we have scanned a page in shrink=5Fpage=5Flist and=A0
> completed paging, the final disposition and clean=A0
> up of the page is consolidated into pg=5Ffinish.=A0=A0T
> he designated disposition of the page from page scanning
> in shrink=5Fpage=5Flist is marked with one of the designation in pg=5Fres=
ult.
>=20
> There is no intention to change shrink=5Fpage=5Flist's
> functionality or logic in this patch.
>=20
> Thanks.
>=20
> Tim
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Hello Tim,

checking file mm/vmscan.c
patch: **** malformed patch at line 89: =A0               mapping->a=5Fops-=
>is=5Fdirty=5Fwriteback(page, dirty, writeback);

Could you resend formal patch?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
