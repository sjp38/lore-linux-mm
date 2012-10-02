Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BD99C6B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 11:36:13 -0400 (EDT)
Message-ID: <506B09DF.7010209@inria.fr>
Date: Tue, 02 Oct 2012 17:35:59 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/10] thp: do_huge_pmd_wp_page(): handle huge zero
 page
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com> <1349191172-28855-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1349191172-28855-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

Le 02/10/2012 17:19, Kirill A. Shutemov a ecrit :
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> On right access to huge zero page we alloc a new page and clear it.
>

s/right/write/ ?

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
