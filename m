Subject: Re: [Lse-tech] Re: [patch] SImple Topology API v0.3 (1/2)
From: "Timothy D. Witham" <wookie@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0208281640240.3234-100000@hawkeye.luckynet.adm>
References: <Pine.LNX.4.44.0208281640240.3234-100000@hawkeye.luckynet.adm>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 28 Aug 2002 15:42:09 -0700
Message-Id: <1030574529.6157.132.camel@wookie-t23.pdx.osdl.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thunder from the hill <thunder@lightweight.ods.org>
Cc: Pavel Machek <pavel@suse.cz>, Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

that I was thinking of is that you might have 
a case in the future where you would like to break out
some of the stuff into say ... PPC or SPARC NUMA and also
X86 NUMA but still keep the Cache Coherent NUMA configuration
as a base.  But that is just wild talk from somebody
who knows wild talk. :-)

Tim

On Wed, 2002-08-28 at 15:40, Thunder from the hill wrote:
> Hi,
> 
> On 28 Aug 2002, Timothy D. Witham wrote:
> > How about the old Marketing name CONFIG_CCNUMA?
> 
> Why not keep CONFIG_X86_NUMA then?
> 
> 			Thunder
> -- 
> --./../...-/. -.--/---/..-/.-./..././.-../..-. .---/..-/.../- .-
> --/../-./..-/-/./--..-- ../.----./.-../.-.. --./../...-/. -.--/---/..-
> .- -/---/--/---/.-./.-./---/.--/.-.-.-
> --./.-/-.../.-./.././.-../.-.-.-
-- 
Timothy D. Witham - Lab Director - wookie@osdlab.org
Open Source Development Lab Inc - A non-profit corporation
15275 SW Koll Parkway - Suite H - Beaverton OR, 97006
(503)-626-2455 x11 (office)    (503)-702-2871     (cell)
(503)-626-2436     (fax)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
