Date: Sat, 16 Dec 2006 23:08:24 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.19 file content corruption on ext3
In-Reply-To: <1166304581.10372.18.camel@twins>
Message-ID: <Pine.LNX.4.64.0612162259510.15520@blonde.wat.veritas.com>
References: <20061207155740.GC1434@torres.l21.ma.zugschlus.de>
 <4578465D.7030104@cfl.rr.com>  <20061209092639.GA15443@torres.l21.ma.zugschlus.de>
  <20061216184310.GA891@unjust.cyrius.com>  <Pine.LNX.4.64.0612161909460.25272@blonde.wat.veritas.com>
 <1166304581.10372.18.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Martin Michlmayr <tbm@cyrius.com>, Marc Haber <mh+linux-kernel@zugschlus.de>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Dec 2006, Peter Zijlstra wrote:
> Moving the cleaning of the page out from under the private_lock opened
> up a window where newly attached buffer might still see the page dirty
> status and were thus marked (incorrectly) dirty themselves; resulting in
> filesystem data corruption.

I'm not going to pretend to understand the buffers issues here:
people thought that change was safe originally, and I can't say
it's not - it just stood out as a potentially weakening change.

The patch you propose certainly looks like a good way out, if
that moved unlock really is a problem: your patch is very well
worth trying by those people seeing their corruption problems,
let's wait to hear their feedback.

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
