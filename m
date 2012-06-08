From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
Date: Fri, 8 Jun 2012 03:05:20 +0200
Message-ID: <20120608010520.GA25317@x4>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com>
 <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com>
 <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, khlebnikov@openvz.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com, stable@vger.kernel.org
List-Id: linux-mm.kvack.org

On 2012.06.07 at 17:25 -0700, Linus Torvalds wrote:
> Ugh, looking more at the patch, I'm getting more and more convinces
> that it is pure and utter garbage.
> 
> It does "sync_mm_rss(mm);" in mmput(), _after_ it has done the
> possibly final mmdrop(). WTF?
> 
> This is crap, guys. Seriously. Stop playing russian rulette with this
> code. I think we need to revert *all* of the crazy rss games, unless
> Konstantin can show us some truly obviously correct fix.
> 
> Sadly, I merged and pushed out the crap before I had rebooted and
> noticed this problem, so now it's in the wild. Can somebody please
> take a look at this asap?

You've somehow merged the wrong patch.
The correct version can be found here:
http://marc.info/?l=linux-kernel&m=133848759505805

-- 
Markus
