From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16946.62799.737502.923025@gargle.gargle.HOWL>
Date: Sat, 12 Mar 2005 16:57:35 +0300
Subject: Re: [PATCH] mm counter operations through macros
In-Reply-To: <Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
	<20050311182500.GA4185@redhat.com>
	<Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:
 > On Fri, 11 Mar 2005, Dave Jones wrote:
 > 
 > > Splitting this last one into inc_mm_counter() and dec_mm_counter()
 > > means you can kill off the last argument, and get some of the
 > > readability back. As it stands, I think this patch adds a bunch
 > > of obfuscation for no clear benefit.
 > 
 > Ok.
 > -----------------------------------------------------------------
 > This patch extracts all the operations on counters protected by the
 > page table lock (currently rss and anon_rss) into definitions in
 > include/linux/sched.h. All rss operations are performed through
 > the following macros:
 > 
 > get_mm_counter(mm, member)		-> Obtain the value of a counter
 > set_mm_counter(mm, member, value)	-> Set the value of a counter
 > update_mm_counter(mm, member, value)	-> Add to a counter

A nitpick, but wouldn't be it clearer to call it add_mm_counter()? As an
additional bonus this matches atomic_{inc,dec,add}() and makes macro
names more uniform.

 > inc_mm_counter(mm, member)		-> Increment a counter
 > dec_mm_counter(mm, member)		-> Decrement a counter

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
