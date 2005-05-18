Date: Tue, 17 May 2005 18:07:42 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: NUMA aware slab allocator V2
In-Reply-To: <428A7E48.6060909@us.ibm.com>
Message-ID: <Pine.LNX.4.62.0505171807280.12337@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <20050512000444.641f44a9.akpm@osdl.org> <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
 <20050513000648.7d341710.akpm@osdl.org> <428A7E48.6060909@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 May 2005, Matthew Dobson wrote:

> Also, there is a similar loop for CPUs which should be replaced with
> for_each_online_cpu(i).
> 
> These for_each_FOO macros are cleaner and less likely to break in the
> future, since we can simply modify the one definition if the way to
> itterate over nodes/cpus changes, rather than auditing 100 open coded
> implementations and trying to determine the intent of the loop's author.

Ok. Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
