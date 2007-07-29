Date: Sun, 29 Jul 2007 13:18:49 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070729131849.15f29159.pj@sgi.com>
In-Reply-To: <2c0942db0707291300k3e30e410wdd0aba7644382e3b@mail.gmail.com>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46AB166A.2000300@gmail.com>
	<20070728122139.3c7f4290@the-village.bc.nu>
	<46AC4B97.5050708@gmail.com>
	<20070729141215.08973d54@the-village.bc.nu>
	<46AC9F2C.8090601@gmail.com>
	<2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>
	<46ACAB45.6080307@gmail.com>
	<2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
	<20070729123353.2bfb9630.pj@sgi.com>
	<2c0942db0707291300k3e30e410wdd0aba7644382e3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: rene.herman@gmail.com, alan@lxorguk.ukuu.org.uk, david@lang.hm, dhazelton@enter.net, efault@gmx.de, akpm@linux-foundation.org, mingo@elte.hu, frank@kingswood-consulting.co.uk, andi@firstfloor.org, nickpiggin@yahoo.com.au, jesper.juhl@gmail.com, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray wrote:
> Ah, so in a normal scenario where a working-set is getting faulted
> back in, we have the swap storage as well as the file-backed stuff
> that needs to be read as well. So even if swap is organized perfectly,
> we're still seeking. Damn.

Perhaps this applies in some cases ... perhaps.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
