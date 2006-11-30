Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id kAU4IqTc031365
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 20:18:52 -0800
Received: from nf-out-0910.google.com (nfao63.prod.google.com [10.48.66.63])
	by zps38.corp.google.com with ESMTP id kAU4IQhR017232
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 20:18:49 -0800
Received: by nf-out-0910.google.com with SMTP id o63so2797138nfa
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 20:18:47 -0800 (PST)
Message-ID: <6599ad830611292018p24eb297s215da52debde1883@mail.gmail.com>
Date: Wed, 29 Nov 2006 20:18:47 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <Pine.LNX.4.64.0611292011540.19628@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
	 <Pine.LNX.4.64.0611292011540.19628@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/29/06, Christoph Lameter <clameter@sgi.com> wrote:
>
> Reclaim? I thought you wanted to migrate memory of a node?
>

Both. The idea would be to apply gentle (or not so gentle, depending
on how important the job is ...) reclaim pressure to all the nodes
owned by a job. If you free up enough memory, you can then consider
migrating the allocated pages from one node into other nodes belonging
to the job, and hence reclaim a node for use by some other job.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
