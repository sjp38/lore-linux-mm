Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id kB1JWauV013214
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 11:32:36 -0800
Received: from nf-out-0910.google.com (nfap46.prod.google.com [10.48.67.46])
	by zps37.corp.google.com with ESMTP id kB1JWS1N007241
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 11:32:29 -0800
Received: by nf-out-0910.google.com with SMTP id p46so262718nfa
        for <linux-mm@kvack.org>; Fri, 01 Dec 2006 11:32:28 -0800 (PST)
Message-ID: <6599ad830612011132i3e70ab38ye3bc8e48f879fea3@mail.gmail.com>
Date: Fri, 1 Dec 2006 11:32:27 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301821270.14059@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
	 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
	 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
	 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
	 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
	 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
	 <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
	 <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
	 <Pine.LNX.4.64.0611301821270.14059@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Thu, 30 Nov 2006, Paul Menage wrote:
>
> > Don't we need to bump the mapcount? If we don't, then the page gets
> > unmapped by the migration prep, and if we race with anyone trying to
> > map it they may allocate a new anon_vma and replace it.
>
> Allocate a new vma for an existing anon page? That never happens. We may
> do COW in which case the page is copied.

I was thinking of a new anon_vma, rather than a new vma - but I guess
that even if we do race with someone who's faulting on the page and
pulling it from the swap cache, they'll just set the page mapping to
the same value as it is already, rather than setting it to a new
value. So you're right, not a problem.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
