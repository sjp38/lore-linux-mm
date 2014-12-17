Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2704A6B0038
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 13:52:10 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so16964012pad.1
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 10:52:09 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id ou2si6670813pbb.214.2014.12.17.10.52.04
        for <linux-mm@kvack.org>;
        Wed, 17 Dec 2014 10:52:05 -0800 (PST)
Message-ID: <5491D0D2.5070103@sr71.net>
Date: Wed, 17 Dec 2014 10:52:02 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: post-3.18 performance regression in TLB flushing code
References: <5490A5F8.6050504@sr71.net> <20141217100810.GA3461@arm.com> <CA+55aFyVxOw0upa=At6MmiNYEHzfPz4rE5bZUBCs9h4vKGh1iA@mail.gmail.com> <20141217165310.GJ870@arm.com>
In-Reply-To: <20141217165310.GJ870@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 12/17/2014 08:53 AM, Will Deacon wrote:
> On Wed, Dec 17, 2014 at 04:28:23PM +0000, Linus Torvalds wrote:
>> On Wed, Dec 17, 2014 at 2:08 AM, Will Deacon <will.deacon@arm.com> wrote:
>> So why not just this trivial patch, to make the logic be the same it
>> used to be (just using "end > 0" instead of the old "need_flush")?
> 
> Looks fine to me... Dave?

First of all, this is quite observable when testing single-threaded on a
desktop.  This is a mildly crusty Sandybridge CPU from 2011.  I made 3
runs with a single thread: ./brk1_processes -s 30 -t 1

	   fb7332a9fed : 4323385
	   fb7332a9fed^: 4503736
fb7332a9fed+Linus's fix: 4516761

These things are also a little bit noisy, so we're well within the
margin of error with Linus's fix.

This also holds up on the large system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
