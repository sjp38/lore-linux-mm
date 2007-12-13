Date: Thu, 13 Dec 2007 09:37:24 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH 2/2] Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"
Message-ID: <20071213173724.GD31637@holomorphy.com>
References: <20071213074156.GA17526@us.ibm.com> <20071213074259.GB17526@us.ibm.com> <20071213085346.GC31637@holomorphy.com> <20071213164727.GD17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213164727.GD17526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.12.2007 [00:53:46 -0800], William Lee Irwin III wrote:
>> This is recent enough that dependencies shouldn't have developed, but
>> it'd be nice to stage user-visible API/ABI changes more consciously
>> and carefully in the future. Or at least we should try to avoid the
>> sorts of situations where we end up changing recently introduced
>> user/kernel ABI's and API's shortly after merging. We'll run the risk
>> of getting stuck with a user/kernel ABI we can't abandon for years on
>> account of not fixing it up before dependencies develop if this
>> happens too often.

On Thu, Dec 13, 2007 at 08:47:27AM -0800, Nishanth Aravamudan wrote:
> I agree and I apologize if I'm making things hard for everyone. However,
> I hadn't fully considered the implications of the dynamic pool for my
> other patches. The patches moved from -mm to -linus rather quickly,
> iirc. No excuse, however, I should have been paying more attention.
> If folks really don't want things to change, I guess we could also just
> make the sysctl's per-node corresponding attribute be a boolean too. It
> just seems less flexible than this approach.

I'm fine with this getting changed over since we've not spanned a point
release with the old nomenclature. If we had spanned a point release
there would be trouble. I've no particular preference about old vs. new
nomenclature apart from following user/kernel ABI/API stability rules.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
