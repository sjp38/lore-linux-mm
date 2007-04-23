Date: Mon, 23 Apr 2007 09:08:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
In-Reply-To: <1177343900.26937.6.camel@twins>
Message-ID: <Pine.LNX.4.64.0704230907470.11250@schroedinger.engr.sgi.com>
References: <20070420155154.898600123@chello.nl>  <20070420155503.608300342@chello.nl>
  <20070421025532.916b1e2e.akpm@linux-foundation.org>  <1177156902.2934.96.camel@lappy>
 <1177157708.2934.100.camel@lappy>  <Pine.LNX.4.64.0704230847400.10624@schroedinger.engr.sgi.com>
 <1177343900.26937.6.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2007, Peter Zijlstra wrote:

> Ooh, thats handy... /me ditches the hotplug code again.
> That is, unless its very common to have half empty boxens.. ?

Its up to the arch code to establish reasonable boundaries.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
