Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0D9476B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 10:07:59 -0400 (EDT)
Message-ID: <1351260464.16863.80.camel@twins>
Subject: Re: [PATCH 1/2] numa, mm: drop redundant check in
 do_huge_pmd_numa_page()
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Oct 2012 16:07:44 +0200
In-Reply-To: <20121026135750.GA16598@otc-wbsnb-06>
References: 
	<1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1351256885.16863.62.camel@twins> <20121026134129.GA31306@otc-wbsnb-06>
	 <1351258992.16863.77.camel@twins> <20121026135750.GA16598@otc-wbsnb-06>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org

On Fri, 2012-10-26 at 16:57 +0300, Kirill A. Shutemov wrote:
> > > Yes, this code will catch it:
> > >=20
> > >     /* if an huge pmd materialized from under us just retry later */
> > >     if (unlikely(pmd_trans_huge(*pmd)))
> > >             return 0;
> > >=20
> > > If the pmd is under splitting it's still a pmd_trans_huge().
> >=20
> > OK, so then we simply keep taking the same fault until the split is
> > complete? Wouldn't it be better to wait for it instead of spin on
> > faults?
>=20
> IIUC, on next fault we will wait split the page in fallow_page().=20

What follow_page()?, a regular hardware page-fault will not call
follow_page() afaict, we do a down_read(), find_vma() and call
handle_mm_fault() -- with a lot of error and corner case checking in
between.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
