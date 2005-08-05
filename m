Date: Fri, 5 Aug 2005 07:52:27 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: NUMA policy interface
In-Reply-To: <20050805091630.GL8266@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0508050750560.27054@graphe.net>
References: <20050804142942.GY8266@wotan.suse.de> <Pine.LNX.4.62.0508040922110.6650@graphe.net>
 <20050804170803.GB8266@wotan.suse.de> <Pine.LNX.4.62.0508041011590.7314@graphe.net>
 <20050804211445.GE8266@wotan.suse.de> <Pine.LNX.4.62.0508041416490.10150@graphe.net>
 <20050804214132.GF8266@wotan.suse.de> <Pine.LNX.4.62.0508041509330.10813@graphe.net>
 <20050804234025.GJ8266@wotan.suse.de> <Pine.LNX.4.62.0508041642130.15157@graphe.net>
 <20050805091630.GL8266@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Aug 2005, Andi Kleen wrote:

> > Address space migration? That is something new in this discussion. So 
> > could you explain what you mean by that? I have looked at page migration 
> > in a variety of contexts and could not see much difference.
> 
> MCE page migration just puts a physical page to somewhere else.
> memory hotplug migration does the same for multiple pages from
> different processes.
> 
> Page migration like you're asking for migrates whole processes.

No I am asking for the migration of parts of a process. Hotplug migration 
and MCE page migration do the same.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
