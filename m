From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16410.18288.285937.59890@laputa.namesys.com>
Date: Fri, 30 Jan 2004 15:00:48 +0300
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
In-Reply-To: <20040129195602.469e9586.akpm@osdl.org>
References: <400F630F.80205@cyberone.com.au>
	<20040121223608.1ea30097.akpm@osdl.org>
	<16399.42863.159456.646624@laputa.namesys.com>
	<40105633.4000800@cyberone.com.au>
	<16400.63379.453282.283117@laputa.namesys.com>
	<4011392D.1090600@cyberone.com.au>
	<16401.16474.881069.437933@laputa.namesys.com>
	<4011C537.8040104@cyberone.com.au>
	<16404.63446.649110.348477@laputa.namesys.com>
	<4014F915.7060300@cyberone.com.au>
	<16405.1185.973874.89638@laputa.namesys.com>
	<4019D3F8.4090808@cyberone.com.au>
	<20040129195602.469e9586.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nick Piggin <piggin@cyberone.com.au> wrote:
 > >
 > > Hi Nikita,
 > > 
 > > Just having a look at your patch. I think maybe this array
 > > should be in a seperate cacheline per node?
 > > 
 > > +/* dummy pages used to scan active lists */
 > > +static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
 > > +
 > 
 > You really want it a member of `struct zone', don't you?
 > 
 > That'll cause include dependency hell, so maybe a page* in struct zone.

I don't quite understand:

struct zone {

    ....

	/*
	 * dummy page used as place holder during scanning of
	 * active_list in refill_inactive_zone()
	 */
	struct page *scan_page;

    ....

};

is already here. Array scan_pages[][] contains struct pages to which
zone->scan_page's point to. Yes, I didn't embed struct page into struct
zone exactly due to dependencies problems.

 > 
 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
