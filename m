Date: Thu, 20 Sep 2007 10:56:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/8] oom: save zonelist pointer for oom killer calls
In-Reply-To: <alpine.DEB.0.9999.0709192235170.22371@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709201054470.8626@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
  <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191204590.2241@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709191416380.30290@chino.kir.corp.google.com>
 <eada2a070709191651i24185d1ep9e0d1829e115ee79@mail.gmail.com>
 <alpine.DEB.0.9999.0709192235170.22371@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tim Pepper <lnxninja@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, David Rientjes wrote:

> But yeah, it's cleaner if we change all_unreclaimable to an
> unsigned int flags and convert all current testers of the 
> all_unreclaimable value to use it.  Then we can simply set a bit, 
> ZONE_OOM, to identify such zones.

If we do that then we can also get rid of the atomic_t 
reclaim_in_progress. It is only used by zone reclaim these days.

> But I do agree that checking bits in an unsigned int flags member of 
> struct zone will be better, but I intend to still mimic the behavior of a 
> trylock for serialization.  try_set_zone_oom() will simply be implemented 
> differently.

Good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
