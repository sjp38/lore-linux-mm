Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id BAFFA6B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 11:37:48 -0400 (EDT)
Date: Tue, 2 Oct 2012 18:38:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 04/10] thp: do_huge_pmd_wp_page(): handle huge zero
 page
Message-ID: <20121002153823.GA27771@shutemov.name>
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1349191172-28855-5-git-send-email-kirill.shutemov@linux.intel.com>
 <506B09DF.7010209@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <506B09DF.7010209@inria.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Oct 02, 2012 at 05:35:59PM +0200, Brice Goglin wrote:
> Le 02/10/2012 17:19, Kirill A. Shutemov a ecrit :
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > On right access to huge zero page we alloc a new page and clear it.
> >
> 
> s/right/write/ ?

Oops... thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
