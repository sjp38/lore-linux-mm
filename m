Date: Fri, 11 Mar 2005 13:25:00 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm counter operations through macros
Message-ID: <20050311182500.GA4185@redhat.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 11, 2005 at 04:23:21AM -0800, Christoph Lameter wrote:
 > This patch extracts all the operations on counters protected by the
 > page table lock (currently rss and anon_rss) into definitions in
 > include/linux/sched.h. All rss operations are performed through
 > the following three macros:
 > 
 > get_mm_counter(mm, member)		-> Obtain the value of a counter
 > set_mm_counter(mm, member, value)	-> Set the value of a counter
 > update_mm_counter(mm, member, value)	-> Add a value to a counter

Splitting this last one into inc_mm_counter() and dec_mm_counter()
means you can kill off the last argument, and get some of the
readability back. As it stands, I think this patch adds a bunch
of obfuscation for no clear benefit.

		Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
