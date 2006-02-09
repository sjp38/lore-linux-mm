Date: Thu, 9 Feb 2006 10:23:01 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
In-Reply-To: <1139428810.4668.20.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.63.0602091021270.23817@cuia.boston.redhat.com>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
 <20051230224312.765.58575.sendpatchset@twins.localnet>  <20051231002417.GA4913@dmt.cnet>
 <1136028546.17853.69.camel@twins>  <20060105094722.897C574030@sv1.valinux.co.jp>
  <Pine.LNX.4.63.0601050830530.18976@cuia.boston.redhat.com>
 <20060106090135.3525D74031@sv1.valinux.co.jp>  <20060124063010.B85C77402D@sv1.valinux.co.jp>
  <20060124072503.BAF6A7402F@sv1.valinux.co.jp>  <1138958705.5450.9.camel@localhost.localdomain>
  <20060208100505.247D874034@sv1.valinux.co.jp> <1139428810.4668.20.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Feb 2006, Peter Zijlstra wrote:

> In your patch you move all Hot pages to the head of the hot list, which
> effectively leaves them in place. The other pages are moved to the head
> of the cold list, which is right behind hand hot.

Isn't clock-pro supposed to leave the page right where it found
it, when it just scans a page and is not evicting it ?

That is, if the page came off one list, it should go onto the
other, regardless of accessed, hot/cold, etc. status...

This has the effect of the clock hand moving beyond the page.

Or am I overlooking something?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
