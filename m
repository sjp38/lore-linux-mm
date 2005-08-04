Date: Thu, 4 Aug 2005 16:49:33 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: NUMA policy interface
In-Reply-To: <20050804234025.GJ8266@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0508041642130.15157@graphe.net>
References: <20050803084849.GB10895@wotan.suse.de> <Pine.LNX.4.62.0508040704590.3319@graphe.net>
 <20050804142942.GY8266@wotan.suse.de> <Pine.LNX.4.62.0508040922110.6650@graphe.net>
 <20050804170803.GB8266@wotan.suse.de> <Pine.LNX.4.62.0508041011590.7314@graphe.net>
 <20050804211445.GE8266@wotan.suse.de> <Pine.LNX.4.62.0508041416490.10150@graphe.net>
 <20050804214132.GF8266@wotan.suse.de> <Pine.LNX.4.62.0508041509330.10813@graphe.net>
 <20050804234025.GJ8266@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Aug 2005, Andi Kleen wrote:

> None of them seem very attractive to me.  I would prefer to just
> not support external accesses keeping things lean and fast.

That is a surprising statement given what we just discussed. Things 
are not lean and fast but weirdly screwed up. The policy layer is 
significantly impacted by historical contingencies rather than designed in 
a clean way. It cannot even deliver the functionality it was designed to 
deliver (see BIND).

> Individual physical page migration is quite different from
> address space migration.

Address space migration? That is something new in this discussion. So 
could you explain what you mean by that? I have looked at page migration 
in a variety of contexts and could not see much difference.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
