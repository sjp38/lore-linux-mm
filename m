Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DAB05828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:16:39 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so270284365pab.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:16:39 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id c26si3714396pfj.47.2016.01.13.11.16.38
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 11:16:38 -0800 (PST)
Subject: Re: [PATCH 01/31] mm, gup: introduce concept of "foreign"
 get_user_pages()
References: <20160107000104.1A105322@viggo.jf.intel.com>
 <20160107000106.D9135553@viggo.jf.intel.com> <56969EE1.5060904@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5696A293.5020609@sr71.net>
Date: Wed, 13 Jan 2016 11:16:35 -0800
MIME-Version: 1.0
In-Reply-To: <56969EE1.5060904@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com

On 01/13/2016 11:00 AM, Vlastimil Babka wrote:
>> > We leave a stub get_user_pages() around with a __deprecated
>> > warning.
> Hm when replying to previous version I assumed this is because there are many
> get_user_pages() callers remaining. But now I see there are just 3 drivers not
> converted by this patch? In that case I would favor to convert get_user_pages()
> to become what is now get_current_user_pages(). This would be much more
> consistent IMHO. We don't need to cater to out-of-tree modules?
> 
> Sorry, I should have looked thoroughly on the previous reply, not just assume.

It's really hard to submit a set of patches that remove a well-known
API.  New (in-tree) callers are always popping up, and you can see that
a few have popped up since I updated this the last time.  Without
leaving the old stub around, it virtually guarantees that this patch
will cause breakage in -next for a release or two.

I'll fix up the other bits you commented on, btw!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
