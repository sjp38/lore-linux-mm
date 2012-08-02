Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7E3BE6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:40:49 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20120731182330.GD21292@google.com> <50197348.9010101@gmail.com>
	<20120801182112.GC15477@google.com> <50197460.8010906@gmail.com>
	<20120801182749.GD15477@google.com> <50197E4A.7020408@gmail.com>
	<20120801202432.GE15477@google.com> <5019B0B4.1090102@gmail.com>
	<20120801224556.GF15477@google.com> <501A4FC1.8040907@gmail.com>
	<20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com>
	<87txwl1dsq.fsf@xmission.com> <501AAC26.6030703@gmail.com>
Date: Thu, 02 Aug 2012 09:40:38 -0700
In-Reply-To: <501AAC26.6030703@gmail.com> (Sasha Levin's message of "Thu, 02
	Aug 2012 18:34:46 +0200")
Message-ID: <87fw851c3d.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Josh Triplett <josh@joshtriplett.org>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

Sasha Levin <levinsasha928@gmail.com> writes:

> Heh, I've started working on it in April, and just returned to this. Didn't think about rebasing to something new.
>
> will fix - Thanks!

You might want to look at some of the work that Eric Dumazet has done in
the networking stack with rcu hashtables that can be resized.

For a trivial hash table I don't know if the abstraction is worth it.
For a hash table that starts off small and grows as big as you need it
the incent to use a hash table abstraction seems a lot stronger.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
