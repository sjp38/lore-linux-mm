Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id CA58A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 19:49:04 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id i138so30375816oig.6
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:49:04 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id 70si7014713oic.2.2015.03.02.16.49.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 16:49:04 -0800 (PST)
Received: by mail-oi0-f50.google.com with SMTP id v1so30373863oia.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:49:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150302164228.4de418951c7d17b7e315d52f@linux-foundation.org>
References: <1425316867-6104-1-git-send-email-jeffv@google.com>
	<20150302164228.4de418951c7d17b7e315d52f@linux-foundation.org>
Date: Mon, 2 Mar 2015 16:49:03 -0800
Message-ID: <CABXk95CWLnAY7myFn-5DuMJg94jzZ0KFoePdHi55=+F17pMoqA@mail.gmail.com>
Subject: Re: [PATCH] mm: reorder can_do_mlock to fix audit denial
From: Jeffrey Vander Stoep <jeffv@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Kralevich <nnk@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Paul Cassella <cassella@cray.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Yes, minor issue.

I appreciate the advice.

On Mon, Mar 2, 2015 at 4:42 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon,  2 Mar 2015 09:20:32 -0800 Jeff Vander Stoep <jeffv@google.com> wrote:
>
>> A userspace call to mmap(MAP_LOCKED) may result in the successful
>> locking of memory while also producing a confusing audit log denial.
>> can_do_mlock checks capable and rlimit. If either of these return
>> positive can_do_mlock returns true. The capable check leads to an LSM
>> hook used by apparmour and selinux which produce the audit denial.
>> Reordering so rlimit is checked first eliminates the denial on success,
>> only recording a denial when the lock is unsuccessful as a result of
>> the denial.
>
> I'm assuming that this is a minor issue - a bogus audit log, no other
> consequences.  And based on this I queued the patch for 4.0 with no
> -stable backport.
>
> All of this might have been wrong - the changelog wasn't very helpful
> in making such decisions (hint).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
