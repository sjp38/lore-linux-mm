Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 589FF6B0073
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:10:51 -0400 (EDT)
Message-ID: <1351257008.16863.63.camel@twins>
Subject: Re: [PATCH 2/2] numa, mm: consolidate error path in
 do_huge_pmd_numa_page()
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Oct 2012 15:10:08 +0200
In-Reply-To: <1351256077-1594-2-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1351256077-1594-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org

On Fri, 2012-10-26 at 15:54 +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>=20
> Let's move all error path code to the end if the function. It makes code
> more straight-forward.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c |   44 ++++++++++++++++++++------------------------
>  1 file changed, 20 insertions(+), 24 deletions(-)

and smaller! Thanks!

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
