Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 757116B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 10:15:40 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so92860515pac.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 07:15:40 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id xg10si4765075pab.141.2016.02.09.07.15.37
        for <linux-mm@kvack.org>;
        Tue, 09 Feb 2016 07:15:37 -0800 (PST)
Subject: Re: [PATCH 01/31] mm, gup: introduce concept of "foreign"
 get_user_pages()
References: <20160129181642.98E7D468@viggo.jf.intel.com>
 <20160129181644.74134A5D@viggo.jf.intel.com>
 <20160209124649.GA20153@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56BA0296.3080107@sr71.net>
Date: Tue, 9 Feb 2016 07:15:34 -0800
MIME-Version: 1.0
In-Reply-To: <20160209124649.GA20153@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 02/09/2016 04:46 AM, Ingo Molnar wrote:
>  - introduce the new get_user_pages() but also add macros so that both 8-parameter 
>    and 7-parameter variants work without breaking the build. We can remove the 
>    compatibility wrapping on v4.6 or so.

Do you want this done with some __VA_ARGS__ macro trickery, or did you
have something else in mind?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
