From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: no way to swapoff a deleted swap file?
Date: Fri, 17 Oct 2008 10:20:22 +0200
Message-ID: <E1KqkZK-0001HO-WF__14597.13597219$1224231099$gmane$org@be1.7eggert.dyndns.org>
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it> <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
To: David Newall <davidn@davidnewall.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph
List-Id: linux-mm.kvack.org

David Newall <davidn@davidnewall.com> wrote:
> Hugh Dickins wrote:
>> On Thu, 16 Oct 2008, Peter Zijlstra wrote:

>>> On Wed, 2008-10-15 at 17:21 -0300, Peter Cordes wrote:
>>>     
>>>> I unlinked a swapfile without realizing I was still swapping on it.

[...]

> Me too.  The kernel shouldn't protect the administrator against all
> possible mistakes; and this mistake is one of them.  Besides, who's to
> say it's always a mistake?  Somebody might want their swap file to have
> zero links.

Somebody might want their swapfiles to have zero links, _and_ the possibility
of doing swapoff. If you can do it by keeping some fds open to let
/proc/pid/fd point to the files, I think it's OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
