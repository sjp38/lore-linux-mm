Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AED826B025C
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:30:40 -0500 (EST)
Received: by pfu207 with SMTP id 207so15965048pfu.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:30:40 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id uo3si6624804pac.221.2015.12.08.10.30.40
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 10:30:40 -0800 (PST)
Subject: Re: [PATCH 16/34] x86, mm: simplify get_user_pages() PTE bit handling
References: <20151204011424.8A36E365@viggo.jf.intel.com>
 <20151204011446.DDC6435F@viggo.jf.intel.com>
 <alpine.DEB.2.11.1512081839471.3595@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <566721CE.1060800@sr71.net>
Date: Tue, 8 Dec 2015 10:30:38 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1512081839471.3595@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On 12/08/2015 10:01 AM, Thomas Gleixner wrote:
> static inline int pte_allows_gup(unsigned long pteval, int write)
> {
> 	unsigned long mask = _PAGE_PRESENT|_PAGE_USER;
> 
> 	if (write)
> 		mask |= _PAGE_RW;
> 
> 	if ((pteval & mask) != mask)
> 		return 0;
> 
> 	if (!__pkru_allows_pkey(pte_flags_pkey(pteval), write))
> 	   	return 0;
> 	return 1;
> }
> 
> and at the callsites do:
> 
>     if (pte_allows_gup(pte_val(pte, write))
> 
>     if (pte_allows_gup(pmd_val(pmd, write))
> 
>     if (pte_allows_gup(pud_val(pud, write))
> 
> Hmm?

Looks fine to me.  I'll do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
