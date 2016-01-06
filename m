Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8F386B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:43:35 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ho8so2087792pac.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:43:35 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id d80si83510090pfj.168.2016.01.06.09.43.35
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 09:43:35 -0800 (PST)
Subject: Re: [PATCH 01/32] mm, gup: introduce concept of "foreign"
 get_user_pages()
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190544.74DCE448@viggo.jf.intel.com> <568BA039.4060901@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <568D5245.4070409@sr71.net>
Date: Wed, 6 Jan 2016 09:43:33 -0800
MIME-Version: 1.0
In-Reply-To: <568BA039.4060901@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com

On 01/05/2016 02:51 AM, Vlastimil Babka wrote:
> 
> Changelog doesn't mention that get_user_pages_unlocked() is also changed
> to be effectively get_current_user_pages_unlocked(). It's a bit
> non-obvious and the inconsistent naming is unfortunate, but I can see
> how get_current_user_pages_unlocked() would be too long, and just
> deleting the parameters from get_user_pages() would be too large and
> intrusive. But please mention this in changelog?

Thanks for the review!  Good point about the churn there.  I'll add some
changelog comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
