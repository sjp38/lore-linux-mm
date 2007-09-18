Date: Tue, 18 Sep 2007 13:26:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/4] oom: rename serialization helper functions
In-Reply-To: <alpine.DEB.0.9999.0709181323080.25339@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709181325270.3953@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
 <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180247250.21326@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181253280.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181255320.22517@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181258570.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181302490.22984@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709181323080.25339@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, David Rientjes wrote:

> -		if (oom_killer_trylock(zonelist)) {
> +		if (zone_in_oom(zonelist)) {

The name is confusing. Looks like we are just checking a bit whereas we 
attempt to set the zone to oom. try_set_zone_oom with the correct trylock 
semantics?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
