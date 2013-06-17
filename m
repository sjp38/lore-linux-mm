Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 5CFD86B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:29:17 -0400 (EDT)
Date: Mon, 17 Jun 2013 14:29:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: +
 mm-thp-dont-use-hpage_shift-in-transparent-hugepage-code.patch added to -mm
 tree
Message-Id: <20130617142914.4914dcfbd19d345dde686245@linux-foundation.org>
In-Reply-To: <20130617132746.GA30262@shutemov.name>
References: <20130513231406.D912031C276@corp2gmr1-1.hot.corp.google.com>
	<20130617132746.GA30262@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 17 Jun 2013 16:27:46 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, May 13, 2013 at 04:14:06PM -0700, akpm@linux-foundation.org wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > Subject: mm/THP: don't use HPAGE_SHIFT in transparent hugepage code
> > 
> > For architectures like powerpc that support multiple explicit hugepage
> > sizes, HPAGE_SHIFT indicate the default explicit hugepage shift.  For THP
> > to work the hugepage size should be same as PMD_SIZE.  So use PMD_SHIFT
> > directly.  So move the define outside CONFIG_TRANSPARENT_HUGEPAGE #ifdef
> > because we want to use these defines in generic code with if
> > (pmd_trans_huge()) conditional.
> 
> I would propose to partly revert the patch with the patch bellow.

It's not completely clear what you're proposing here.  Can you send a
real patch against mmotm or -next for us to look at?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
