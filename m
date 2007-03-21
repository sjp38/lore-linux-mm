Date: Wed, 21 Mar 2007 10:42:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API (V2)
Message-ID: <20070321174210.GI2986@holomorphy.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <Pine.LNX.4.64.0703211549220.32077@blonde.wat.veritas.com> <20070321162324.GH2986@holomorphy.com> <Pine.LNX.4.64.0703211650250.9630@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703211650250.9630@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Mar 2007, William Lee Irwin III wrote:
>> What sort of uglier stuff are you concerned about this enabling? My
>> wild guess is precisely the prospective users in my queue of features
>> to implement that I've neglected on account of the lack of such an
>> interface. It might be a good idea for me to take whatever distaste for
>> them exists into account before belting out the code for them.

On Wed, Mar 21, 2007 at 05:08:00PM +0000, Hugh Dickins wrote:
> I'll probably hate it whatever it is, don't worry about me ;)  I'm
> rather weary of all the grand mm schemes people are toting these days.

Breathe a sigh of relief; I've retired from the world of grand schemes.
That much should be clear from my patch output over the past few years.
A driver in its own corner of the tree wouldn't have been so ambitious.


On Wed, Mar 21, 2007 at 05:08:00PM +0000, Hugh Dickins wrote:
> I guess my distaste is for letting a door open, for all kinds of
> drivers (or odd corners of architectures etc) to take control of
> the mm in ways we've never anticipated, and which we'll forever
> after be stumbling over.
> It would be a good idea for you to belt out the code for a few of them,
> to give everyone else an idea of what's to be let in through this door:
> I haven't the faintest idea what's envisaged.

After consulting with Adam Litke it appears I should remain silent on
this front.


On Wed, Mar 21, 2007 at 05:08:00PM +0000, Hugh Dickins wrote:
> Seeing what you have, maybe everyone will react that of course
> Adam's page table ops are the way to go, or maybe the reverse.
> I would be rather surprised if the adhoc collection of divergences
> you found necessary for hugetlb turn out to have a fundamental
> applicability.  Perhaps we'll need subvert_the_core_ops.

The fact something can be done with them doesn't mean it has to be
done. At least in some corners of industry, the mere opportunity
to do things considered distasteful doesn't outweigh courtesy. Users
doing distasteful things need not be merged, nor shipped or supported,
regardless of what infrastructure they could utilize.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
