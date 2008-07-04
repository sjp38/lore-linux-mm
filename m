MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18541.35720.223976.231701@harpo.it.uu.se>
Date: Fri, 4 Jul 2008 04:31:36 +0200
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
In-Reply-To: <20080703232554.7271d645@lxorguk.ukuu.org.uk>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	<20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<486CC440.9030909@garzik.org>
	<Pine.LNX.4.64.0807031353030.11033@blonde.site>
	<486CCFED.7010308@garzik.org>
	<1215091999.10393.556.camel@pmac.infradead.org>
	<486CD654.4020605@garzik.org>
	<1215093175.10393.567.camel@pmac.infradead.org>
	<20080703173040.GB30506@mit.edu>
	<1215111362.10393.651.camel@pmac.infradead.org>
	<486D3E88.9090900@garzik.org>
	<486D4596.60005@infradead.org>
	<486D511A.9020405@garzik.org>
	<20080703232554.7271d645@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, David Woodhouse <dwmw2@infradead.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
 > > The only valid assumption here is to assume that the user is /unaware/ 
 > > of these new steps they must take in order to continue to have a working 
 > > system.
 > 
 > To a large extent not the user but their distro - consider "make install"
 > --

Last time I checked only x86 had 'make install'. I regularly build
natively on ppc(32|64) and sparc64, and none of them implement
'make install' AFAIK. And on ARM I move the kernels over to a tftp
server for network boots, again w/o 'make install'.

Not that 'make install' is difficult. All it does it hand over to
/sbin/installkernel or something like that.

In the context of .config changes, 'make oldconfig' with 'select the
default' must IMO result in a working kernel similar to the previous
one. Anything else is madness or arrogance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
