Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42539C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:00:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07B9F217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:00:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07B9F217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962E48E01A3; Mon, 11 Feb 2019 20:00:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913D98E019C; Mon, 11 Feb 2019 20:00:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827BD8E01A3; Mon, 11 Feb 2019 20:00:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F60C8E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:00:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v16so732374plo.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qA5ZT83/QYrRaxjhEQZi8vGcfLvKUUmohFR5LFK50EY=;
        b=mre4+JMY2H7Luc+ew5y87m4ACg9siXSQLP+dmTecSUT431PiEXAO5V8QDDG73RHUC7
         bWxSwH5+2p0cTOBWge5wS9RKf33A6lpO7st4wGW9In5qhi9oVURpIpG39fynJgbGW7wR
         fO/jYgZy1JZtGJTuNQNKRmAXBVAU+JKZp9NUuzBfGvLEzEzXPM4FW1ABW68VnxmsIYZx
         LZOMWZRZKvIzJokK8GDzjOnLsploCgbr25SD1mH+YBrUPVuZ/p7ljYWaVmkaZb94nJlr
         vvp1OrNmL2jr7/rpgoMORXD9zRx0j8tiJXWRrShTabzEVlbCtxXV8+0UHPp5jCQF0/KN
         H4bA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYTnbusbNylHrBp7oluZfay+gLXWR7ZiqewxNIg8o+Yjz4fa4aB
	2lHt5qIPNH8/Fqaz86eISeeN31/DoR0CBGxkn4bDpVEvR8CHvqHq4hfOxvC3haaPig2/T7T5e5V
	8MNoyeu7P/okYBpCIuqV0A0fWtXDC9L6ddJ+NUr8CCO2+spRKRe2J3OjJGfW5xPHlXg==
X-Received: by 2002:a62:32c4:: with SMTP id y187mr1195283pfy.195.1549933239883;
        Mon, 11 Feb 2019 17:00:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaP/5rr0r9Ke+zUtFyEtr9thniFlTn1POE4OSJxzD3gknT/irgOZgrrZxXLjJQeVAXNFT2J
X-Received: by 2002:a62:32c4:: with SMTP id y187mr1195197pfy.195.1549933238994;
        Mon, 11 Feb 2019 17:00:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549933238; cv=none;
        d=google.com; s=arc-20160816;
        b=qqQumv4DGs8D9wdgBxZKhWmzglQMjzfwT2eWR0ecIkuLkpzdYTxhUYcR9rf7gFcJwl
         n52Tf5tRolnXfmOwCUcNwB2/SUCrGaO0BReW5y65meRpxtZ6HhvQ6eX4gOXoMJsFLR/9
         wtpbbWJCymINn72wqnst5eETqgkrkC7hOc1wCgoo0FFc7bdkUKocvnLZmUhlMr+caHbK
         iTJWPmbTciroMWsPkT2SYlfNOEotnspYF8fiqh2mOzNlC3GCh3Y0fOO1CA+LdgVWP+in
         u4MWSGs3O3D7B773XWhbQLhNiuQ2jgubdGCJkulPZGIbjDcmpu7wT5hQOTq3jLOg+y1B
         lO2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=qA5ZT83/QYrRaxjhEQZi8vGcfLvKUUmohFR5LFK50EY=;
        b=lkxKEng03imZ7yJEN94pysCOnLzfYnjIbB9B9FxiVgX53lQIrO8wR4xRaN5CGQ/K2j
         DWdThgDcC8/bmIQEcMHtko35pzEVfhRaEY+gzGVlS+UoWj9jagbvkx6XnJimmxB4pLb/
         UqVS8UPWJRIf3zgCAnNyagNbW00kAaMB3J0y2aEClLn+amGBqrNYaUfFlwRWmOOMgCkF
         9mGp7JUJIRMzPc6s5zKjChsMho9jRLJHc0LWXTL5U8tGCgObrqKqGDxjeTCABgDAFEQX
         CX37iF9qtSrHTM+rE8VjGdL+TcuomZ9xRlYIU+//IkrCkcQoMWx5nM4YlLswy6BoNHu7
         ub4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m186si7965241pfc.236.2019.02.11.17.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 17:00:38 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 7247ED6AC;
	Tue, 12 Feb 2019 01:00:38 +0000 (UTC)
Date: Mon, 11 Feb 2019 17:00:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: paulmck@linux.ibm.com
Cc: kbuild test robot <lkp@intel.com>, Suren Baghdasaryan
 <surenb@google.com>, kbuild-all@01.org, Johannes Weiner
 <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-Id: <20190211170037.f227b544efd64ecef56357c0@linux-foundation.org>
In-Reply-To: <20190209074407.GE4240@linux.ibm.com>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
	<20190208151441.4048e6968579dd178b259609@linux-foundation.org>
	<20190209074407.GE4240@linux.ibm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > 
> > Paul, can you please shed light?
> 
> First, please avoid using rcu_dereference_raw() where possible.  It is
> intended for situations where the developer cannot easily state what
> is to be protecting access to an RCU-protected data structure.  So...
> 
> 1.	If the access needs to be within an RCU read-side critical
> 	section, use rcu_dereference().  With the new consolidated
> 	RCU flavors, an RCU read-side critical section is entered
> 	using rcu_read_lock(), anything that disables bottom halves,
> 	anything that disables interrupts, or anything that disables
> 	preemption.
> 
> 2.	If the access might be within an RCU read-side critical section
> 	on the one hand, or protected by (say) my_lock on the other,
> 	use rcu_dereference_check(), for example:
> 	
> 		p1 = rcu_dereference_check(p->rcu_protected_pointer,
> 					   lockdep_is_held(&my_lock));
> 
> 
> 3.	If the access might be within an RCU read-side critical section
> 	on the one hand, or protected by either my_lock or your_lock on
> 	the other, again use rcu_dereference_check(), for example:
> 
> 		p1 = rcu_dereference_check(p->rcu_protected_pointer,
> 					   lockdep_is_held(&my_lock) ||
> 					   lockdep_is_held(&your_lock));
> 
> 4.	If the access is on the update side, so that it is always protected
> 	by my_lock, use rcu_dereference_protected():
> 
> 		p1 = rcu_dereference_protected(p->rcu_protected_pointer,
> 					       lockdep_is_held(&my_lock));
> 
> 	This can be extended to handle multiple locks as in #3 above,
> 	and both can be extended to check other conditions as well.
> 
> 5.	If the protection is supplied by the caller, and is thus unknown
> 	to this code, that is when you use rcu_dereference_raw().  Or
> 	I suppose you could use it when the lockdep expression would be
> 	excessively complex, except that a better approach in that case
> 	might be to take a long hard look at your synchronization design.
> 	Still, there are data-locking cases where any one of a very
> 	large number of locks or reference counters suffices to protect the
> 	pointer, so rcu_derefernce_raw() does have its place.
> 
> 	However, its place is probably quite a bit smaller than one
> 	might expect given the number of uses in the current kernel.
> 	Ditto for its synonym, rcu_dereference_protected( ... , 1).  :-/

Is this documented anywhere (apart from here?)

> Now on to this sparse checking and what the point of it is.  This sparse
> checking is opt-in.  Its purpose is to catch cases where someone
> mistakenly does something like:
> 
> 	p = q->rcu_protected_pointer;
> 
> When they should have done this instead:
> 
> 	p = rcu_dereference(q->rcu_protected_pointer);
> 
> If you wish to opt into this checking, you need to mark the pointer
> definitions (in this case ->private) with __rcu.  It may also
> be necessary to mark function parameters as well, as is done for
> radix_tree_iter_resume().  If you do not wish to use this checking,
> you should ignore these sparse warnings.
> 
> Unfortunately, I don't know of a way to inform 0-day test robot of
> the various maintainers' opt-in/out choices.

Oh geeze.

Good luck, Suren ;)

