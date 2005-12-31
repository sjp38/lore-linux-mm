Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20051231002417.GA4913@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20051231002417.GA4913@dmt.cnet>
Content-Type: text/plain
Date: Sat, 31 Dec 2005 12:29:06 +0100
Message-Id: <1136028546.17853.69.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Forgot one in the previous mail.

On Fri, 2005-12-30 at 22:24 -0200, Marcelo Tosatti wrote:
> Please make it easier for others to understand why the hands 
> swap, and when, and why.

Its not the hands that swap, its the lists. The hands will lap each
other, like the minute hand will lap the hour hand every ~65 minutes.

Let me try some ascii art.

   ====
  ^---<>---v
       ====

'='	a page
'^---<' hand cold
'>---v' hand hot

now let hand cold move 4 pages:

   
  ^---<>---v
   ========

ie. hand hot and hand cold have the same position.
now if we want to move hand cold one more position this happens:

   =======
  ^---<>---v
          =

see the swap?
-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
