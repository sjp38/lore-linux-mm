Date: Fri, 1 Jun 2007 14:02:00 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
Message-ID: <20070601180200.GA7968@redhat.com>
References: <20070531002047.702473071@sgi.com> <20070531003012.302019683@sgi.com> <20070531141147.423ad5e3.akpm@linux-foundation.org> <20070531213046.GA27923@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070531213046.GA27923@uranus.ravnborg.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roman Zippel <zippel@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 11:30:46PM +0200, Sam Ravnborg wrote:
 > > +	sym = sym_lookup("DEVEL_KERNEL", 0);
 > > +	sym->type = S_BOOLEAN;
 > > +	sym->flags |= SYMBOL_AUTO;
 > > +	p = getenv("DEVEL_KERNEL");
 > > +	if (p && atoi(p))
 > > +		sym_add_default(sym, "y");
 > > +	else
 > > +		sym_add_default(sym, "n");
 > > +
 > 
 > 		sym_set_tristate_value(sym, yes);
 > 	else
 > 		sym_set_tristate_value(sym, no);
 > 
 > should do the trick (untested).

Odd. What's the third state ? Undefined?

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
