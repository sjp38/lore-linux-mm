Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3556F6B025C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:16:01 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so15517319pfb.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:16:01 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id sb2si3299012pac.161.2016.02.17.10.15.59
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 10:15:59 -0800 (PST)
Subject: Re: [PATCH 02/33] mm: overload get_user_pages() functions
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210155.73222EE1@viggo.jf.intel.com>
 <20160216083606.GB3335@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56C4B8DD.5040404@sr71.net>
Date: Wed, 17 Feb 2016 10:15:57 -0800
MIME-Version: 1.0
In-Reply-To: <20160216083606.GB3335@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 02/16/2016 12:36 AM, Ingo Molnar wrote:
>> > From: Dave Hansen <dave.hansen@linux.intel.com>
>> > 
>> > The concept here was a suggestion from Ingo.  The implementation
>> > horrors are all mine.
>> > 
>> > This allows get_user_pages(), get_user_pages_unlocked(), and
>> > get_user_pages_locked() to be called with or without the
>> > leading tsk/mm arguments.  We will give a compile-time warning
>> > about the old style being __deprecated and we will also
>> > WARN_ON() if the non-remote version is used for a remote-style
>> > access.
> So at minimum this should be WARN_ON_ONCE(), to make it easier to recover some 
> meaningful kernel log from such incidents.

I went to go fix this in the code but realized that I coded it up as
WARN_ONCE().  The description was just imprecise.  So I won't be sending
a code fix for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
