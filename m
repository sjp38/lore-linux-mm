Date: Fri, 5 Aug 2005 11:16:30 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: NUMA policy interface
Message-ID: <20050805091630.GL8266@wotan.suse.de>
References: <20050804142942.GY8266@wotan.suse.de> <Pine.LNX.4.62.0508040922110.6650@graphe.net> <20050804170803.GB8266@wotan.suse.de> <Pine.LNX.4.62.0508041011590.7314@graphe.net> <20050804211445.GE8266@wotan.suse.de> <Pine.LNX.4.62.0508041416490.10150@graphe.net> <20050804214132.GF8266@wotan.suse.de> <Pine.LNX.4.62.0508041509330.10813@graphe.net> <20050804234025.GJ8266@wotan.suse.de> <Pine.LNX.4.62.0508041642130.15157@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0508041642130.15157@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 04, 2005 at 04:49:33PM -0700, Christoph Lameter wrote:
> On Fri, 5 Aug 2005, Andi Kleen wrote:
> 
> > None of them seem very attractive to me.  I would prefer to just
> > not support external accesses keeping things lean and fast.
> 
> That is a surprising statement given what we just discussed. Things 
> are not lean and fast but weirdly screwed up. The policy layer is 
> significantly impacted by historical contingencies rather than designed in 
> a clean way. It cannot even deliver the functionality it was designed to 
> deliver (see BIND).

That seems like a unfair description to me. While things are not
perfect they are definitely not as bad as you're trying to paint them.

> 
> > Individual physical page migration is quite different from
> > address space migration.
> 
> Address space migration? That is something new in this discussion. So 
> could you explain what you mean by that? I have looked at page migration 
> in a variety of contexts and could not see much difference.

MCE page migration just puts a physical page to somewhere else.
memory hotplug migration does the same for multiple pages from
different processes.

Page migration like you're asking for migrates whole processes.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
