Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 600386B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 10:35:40 -0400 (EDT)
Received: by wgoe14 with SMTP id e14so21331768wgo.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 07:35:39 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ek3si29246191wid.2.2015.03.31.07.35.37
        for <linux-mm@kvack.org>;
        Tue, 31 Mar 2015 07:35:38 -0700 (PDT)
Date: Tue, 31 Mar 2015 17:35:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
Message-ID: <20150331143534.GA10808@node.dhcp.inet.fi>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.11.1503310810320.13959@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1503310810320.13959@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, Mar 31, 2015 at 08:11:02AM -0500, Christoph Lameter wrote:
> On Tue, 31 Mar 2015, Kirill A. Shutemov wrote:
> 
> > Let's use PageAnon() and PageKsm() helpers instead. It helps readability
> > and makes page_anon_vma() work correctly on tail pages.
> 
> But it adds a branch due to the use of ||.

Which caller is hot enough to care?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
