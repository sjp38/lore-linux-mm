Date: Thu, 1 Aug 2002 11:15:17 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: severely bloated slabs
Message-ID: <20020801181517.GR29537@holomorphy.com>
References: <20020730172341.GD29537@holomorphy.com> <649629297.1028025550@[10.10.2.3]> <20020730175339.GF29537@holomorphy.com> <200207302013.01958.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200207302013.01958.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On July 30, 2002 01:53 pm, William Lee Irwin III wrote:
>> Mostly a question of response time and long idle times being a good
>> indicator of upcoming workload shifts. I'd say it's behaving as
>> designed, but not as desired.

On Tue, Jul 30, 2002 at 08:13:01PM -0400, Ed Tomlinson wrote:
> Was this with full rmap + slablru or with a linus kernel?  With slablru
> I would expect this to happen to some extent.  When vm pressure picks
> up slablru is fast to free the 'old' slabs...  On the other hand, if periodic
> prunes are really a good idea, it would be easy to have slablru do them
> for us.  As it stands now, slablru adds a flag bit to each slab cache telling
> slablru to prune the cache instead of just the page encounted.  This flag
> gets set when we are able to add a page to the lru (when the pagemap_lru
> lock is busy).  I would not be hard to set this flag under other conditions.

Sounds reasonable, not sure what the general consensus is on periodic
prunes, though. I'm mostly thinking of the desktop workload for this
one, as servers are probably not going to really care. But I'm not a good
testcase for this one as even my "desktop" usage patterns are atypical.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
