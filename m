Date: Fri, 25 May 2007 14:46:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180129271.21879.45.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705251444420.8208@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
 <1180114648.5730.64.camel@localhost>  <200705252301.00722.ak@suse.de>
 <1180129271.21879.45.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Lee Schermerhorn wrote:

> As I've said, I view this series as addressing a number of problems,
> including the numa_maps hang when displaying hugetlb shmem segments with
> shared policy [that one by accident, I admit], the incorrect display of

That hang exists only if you first add a shared policy right?

> shmem segment policy from different tasks, and the disconnect between

Ahh.. Never checked that. What is happening with shmem policy display?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
