Message-ID: <41DDC7F2.2020909@sgi.com>
Date: Thu, 06 Jan 2005 17:21:22 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de> <20050106223046.GB9636@holomorphy.com>
In-Reply-To: <20050106223046.GB9636@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@muc.de>, Hugh Dickins <hugh@veritas.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Thu, Jan 06, 2005 at 03:43:07PM +0100, Andi Kleen wrote:
> 
>>If nothing happens soon regarding the "other" hugetlb code I will
>>forward port my SLES9 code. It already has NUMA policy support.
>>For now you can remove the hugetlb policy code from mainline if you
> 
> 
> This is not specifically directed at Andi...
> 

Who is it directed at then?

<snip>

> Obviously, I have no recourse, otherwise there would be no credible
> threat of this kind of end-run tactic succeeding, and I've apparently
> already been circumvented by pushing the things to distros anyway. So
> I can do no more than kindly ask you to address issues 1-6 in your
> patch presentations.
> 

And who does "you" refer to here?

I'd point out that one of the reasons we have Christoph Lameter working
on this is that he is better at working with cross architecture type
stuff than I am, since I have neither the skills nor interest to do
such things (I'm much too focused on Altix specific problems).

So, I guess the question is, do you, wli, have allocate hugetlbpage on
fault code available somewhere that we, SGI, have somehow stepped on,
ignored, or not properly given credit for?  SGI has a strong requirement
to  eliminate the current "allocate hugetlb pages at mmap() time",
single-threaded allocation.  (We have sold machines where it would
take thousands of seconds to complete that operation as it is
currently coded in the mainline.)

We need the allocate on fault hugetlbpage code.  We worked quite hard
to get that code to behave the same way wrt out of memory failures as the
existing code.  To say that we didn't worry about backwards
compatibility there (at least in that regard) is simply absurd.

But I care not where this code comes from.  If it works, meets our
scaling requirements, and can get accepted into the mainline, then
I am all for it.  And I will happily give credit where credit is
due.

However, at the pesent time it appears that if we want this code in the
mainline, we will have to bring it up to level and push it upstream,
and that is what Christoph is working on.

When that happens, the code is subject to review and we look forward
to working with you to resolve your concerns (1)-(6) wrt to those
patches.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
