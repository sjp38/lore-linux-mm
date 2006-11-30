Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id kAUBNFrO002457
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:23:15 -0800
Received: from nf-out-0910.google.com (nfec2.prod.google.com [10.48.155.2])
	by zps37.corp.google.com with ESMTP id kAUBNA3r022283
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:23:10 -0800
Received: by nf-out-0910.google.com with SMTP id c2so3014268nfe
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 03:23:09 -0800 (PST)
Message-ID: <6599ad830611300323l40841241qaa39ee497c26769c@mail.gmail.com>
Date: Thu, 30 Nov 2006 03:23:09 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456EBACB.9080304@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <456E95C4.5020809@yahoo.com.au>
	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>
	 <456E9C90.4020909@yahoo.com.au>
	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
	 <456EA28C.8070508@yahoo.com.au>
	 <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>
	 <456EAF4D.5000804@yahoo.com.au>
	 <6599ad830611300240x388ef00s60183bc3a105ed2a@mail.gmail.com>
	 <456EBACB.9080304@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> But I'm not sure that there is a good reason to use the same
> abstraction. Maybe there is, but I think it needs more discussion
> (unless I missed something in the past couple of weeks were you
> managed to get all memory resource controller groups to agree with
> your fakenodes approach).

No, not at all - but we've observed that:

a) people have been proposing interesting memory controller approaches
for a long time, and haven't made a great deal of progress so far, so
there's no indication than something is going to be agreed upon in the
near future

b) the cpusets and fake numa code provide a fairly serviceable
coarse-grained memory controller, modulo a few missing features such
as per-node reclaim/migration and auto-expansion (see my patch
proposal hopefully tomorrow).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
