Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A71876B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:48:36 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so9213799pfb.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:48:36 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id ui8si18498565pac.217.2016.01.20.10.48.35
        for <linux-mm@kvack.org>;
        Wed, 20 Jan 2016 10:48:35 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <20160120173504.59300BEC@viggo.jf.intel.com>
 <569FCA5A.8040906@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <569FD681.2020808@sr71.net>
Date: Wed, 20 Jan 2016 10:48:33 -0800
MIME-Version: 1.0
In-Reply-To: <569FCA5A.8040906@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 01/20/2016 09:56 AM, Vlastimil Babka wrote:
> On 01/20/2016 06:35 PM, Dave Hansen wrote:
>> This also switches get_user_pages_(un)locked() over to be like
>> get_user_pages() and not take a tsk/mm.  There is no
>> get_user_pages_foreign_(un)locked().  If someone wants that
>> behavior they just have to use "__" variant and pass in
>> FOLL_FOREIGN explicitly.
> 
> Hm so this gets a bit ahead of patch "mm: add gup flag to indicate "foreign" mm
> access", right? It might be cleaner to postpone passing FOLL_FOREIGN until then,
> but not critical.

I've reworded that patch a bit, so it just talks about only enforcing
pkey permissions on non-foreign accesses.  I think I'll keep
FOLL_FOREIGN in this patch because it fits in well with the other things
converted to get_user_pages_foreign().

> BTW doesn't that other patch miss passing FOLL_FOREIGN from
> get_user_pages_foreign() or something? I see it only uses it from break_ksm(),
> am I missing something?

Nope.  At some point along the way, it got dropped in a merge.  Thanks
for catching that!  I'll include it in future versions of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
