Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id l0GJqMrb023033
	for <linux-mm@kvack.org>; Tue, 16 Jan 2007 19:52:22 GMT
Received: from ug-out-1314.google.com (ugfk3.prod.google.com [10.66.187.3])
	by spaceape8.eur.corp.google.com with ESMTP id l0GJoaD2000310
	for <linux-mm@kvack.org>; Tue, 16 Jan 2007 19:52:17 GMT
Received: by ug-out-1314.google.com with SMTP id k3so1734648ugf
        for <linux-mm@kvack.org>; Tue, 16 Jan 2007 11:52:17 -0800 (PST)
Message-ID: <6599ad830701161152q75ff29cdo7306c9b8df5c351b@mail.gmail.com>
Date: Tue, 16 Jan 2007 11:52:13 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC 8/8] Reduce inode memory usage for systems with a high MAX_NUMNODES
In-Reply-To: <20070116054825.15358.65020.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116054825.15358.65020.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On 1/15/07, Christoph Lameter <clameter@sgi.com> wrote:
>
> This solution may be a bit hokey. I tried other approaches but this
> one seemed to be the simplest with the least complications. Maybe someone
> else can come up with a better solution?

How about a 64-bit field in struct inode that's used as a bitmask if
there are no more than 64 nodes, and a pointer to a bitmask if there
are more than 64 nodes. The filesystems wouldn't need to be involved
then, as the bitmap allocation could be done in the generic code.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
