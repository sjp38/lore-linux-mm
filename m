Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id kAU96tgE030513
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 01:06:56 -0800
Received: from ug-out-1314.google.com (ugf39.prod.google.com [10.66.6.39])
	by zps78.corp.google.com with ESMTP id kAU96nFi028827
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 01:06:52 -0800
Received: by ug-out-1314.google.com with SMTP id 39so3793846ugf
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 01:06:49 -0800 (PST)
Message-ID: <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
Date: Thu, 30 Nov 2006 01:06:48 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456E9C90.4020909@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
	 <456E8A74.5080905@yahoo.com.au>
	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
	 <456E95C4.5020809@yahoo.com.au>
	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>
	 <456E9C90.4020909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >
> > Being able to say "try to move all memory from this node to this other
> > set of nodes" seems like a generically useful thing even for other
> > uses (e.g. hot unplug, general HPC numa systems, etc).
>
> AFAIK they do that in their higher level APIs (at least HPC numa does).

Could you point me at an example?

> > This would be happening after reclaim has successfully shrunk the
> > in-use memory in a bunch of nodes, and we want to consolidate to a
> > smaller set of nodes.
>
> So your API could be some directive to consolidate? You could get
> pretty accurate estimates with page statistics, as to whether it
> can be done or not.

Yes, and exposing those statistics (already available in
/sys/device/system/node/node*/meminfo) and the low-level mechanism for
migration are, to me, things that are appropriate for the kernel. I'm
not sure what a specific "consolidation API" would look like, beyond
the API that I'm already proposing (migrate memory from node X to
nodes A,B,C)

> The cpusets code is definitely similar to what memory resource control
> needs. I don't think that a resource control API needs to be tied to
> such granular, hard limits as the fakenodes code provides though. But
> maybe I'm wrong and it really would be acceptable for everyone.

Ah. This isn't intended to be specifically a "resource control API".
It's more intended to be an API that could be useful for certain kinds
of resource control, but could also be generically useful.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
