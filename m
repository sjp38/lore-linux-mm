Date: Fri, 04 Jul 2008 13:37:21 -0700 (PDT)
Message-Id: <20080704.133721.98729739.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1215178035.10393.763.camel@pmac.infradead.org>
References: <1215177044.10393.743.camel@pmac.infradead.org>
	<486E2260.5050503@garzik.org>
	<1215178035.10393.763.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 04 Jul 2008 14:27:15 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: dwmw2@infradead.org
Cc: jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Your argument makes about as much sense as an argument that we should
> link b43.ko with mac80211.ko so that the 802.11 core code "rides along
> in the module's .ko file". It's just silly.

I totally disagree with you.  Jeff is right and you are wrong.

We have a large set of drivers which you are basically breaking.

You keep harping on this "current best practices" crap but it's simply
that, crap.  The only argument behind why you're doing this is a legal
one.

And for one, I have consistently argued that this "best practice" is
the "worst practice" from a technical perspective.  It is the worst
because it means mistakes are possible to make between driver and
firmware versions.  Even with versioning it is not fool proof.
Whereas if you link the firmware into the driver, it's impossible to
get wrong.

It's the difference between "might get it wrong" and "impossible
to get wrong."  And what you're doing is swaying these drivers
away from the latter and towards the former.

That to me is a strong technical argument against your changes.

So stop bringing up this "best practices" garbage.  It's "best
practices" from someone's legal perspective, not from a kernel
technical one, and you know it.

Tell me, would you even invest one single second of your time on this
bogus set of changes without the legal impetus?  Would you sit here
and listen to Jeff, myself, and the others scream at you for breaking
things on people for what you claim are "technical" reasons?

No, you would absolutely not work on this without the legal incentive.
There would be no reason to, since everything works perfectly fine now.

I want you to be completely honest about the real reason why you're
making any of these decisions the way you are, RIGHT NOW.  I don't
want to hear any more of this "best practices" request_firmware()
crap, because that's just nonsense.

It seems your employer is telling you to work on this in order to sort
out some perceived legal issue.  And that's the only reason you're
investing any effort into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
