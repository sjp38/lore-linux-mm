Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: severely bloated slabs
Date: Tue, 30 Jul 2002 20:13:01 -0400
References: <20020730172341.GD29537@holomorphy.com> <649629297.1028025550@[10.10.2.3]> <20020730175339.GF29537@holomorphy.com>
In-Reply-To: <20020730175339.GF29537@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200207302013.01958.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On July 30, 2002 01:53 pm, William Lee Irwin III wrote:
> At some point in the past, I wrote:
> >> 132MB of ZONE_NORMAL on a 16GB i386 box tied up in buffer_head slabs
> >> when all of 3% of it is in use gives me the willies. Periodic slab
> >> pruning anyone? Might be useful in addition to slab-in-lru.
>
> On Tue, Jul 30, 2002 at 10:39:35AM -0700, Martin J. Bligh wrote:
> > As long as we give this up under memory pressure, why does this
> > matter?
>
> Mostly a question of response time and long idle times being a good
> indicator of upcoming workload shifts. I'd say it's behaving as
> designed, but not as desired.

Was this with full rmap + slablru or with a linus kernel?  With slablru
I would expect this to happen to some extent.  When vm pressure picks
up slablru is fast to free the 'old' slabs...  On the other hand, if periodic
prunes are really a good idea, it would be easy to have slablru do them
for us.  As it stands now, slablru adds a flag bit to each slab cache telling
slablru to prune the cache instead of just the page encounted.  This flag
gets set when we are able to add a page to the lru (when the pagemap_lru
lock is busy).  I would not be hard to set this flag under other conditions.

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
