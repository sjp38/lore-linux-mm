Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 19PSCC-0000z3-00
	for <linux-mm@kvack.org>; Mon, 09 Jun 2003 21:20:44 +0200
From: Pasi Savolainen <psavo@iki.fi>
Subject: Re: 2.5.70-mm6
Date: Mon, 9 Jun 2003 19:07:30 +0000 (UTC)
Message-ID: <bc2lti$ss7$1@main.gmane.org>
References: <20030607151440.6982d8c6.akpm@digeo.com> <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Maciej Soltysiak <solt@dns.toxicfilms.tv>:
>> . -mm kernels will be running at HZ=100 for a while.  This is because
>>   the anticipatory scheduler's behaviour may be altered by the lower
>>   resolution.  Some architectures continue to use 100Hz and we need the
>>   testing coverage which x86 provides.
> The interactivity seems to have dropped. Again, with common desktop
> applications: xmms playing with ALSA, when choosing navigating through
> evolution options or browsing with opera, music skipps.
> X is running with nice -10, but with mm5 it ran smoothly.

I see that idle() is called much less often than before (1000
calls/second down to 150 calls/second, estimated and non-scientifical).

non-linear scale down is most probably because processes get more done
and don't wait so much.

idle() is also get called more when there is some load.

There is something weird though, I have this constant 0.8 load which I
can't pinpoint, in -mm4 fully idle machine was at about 0.1 load.

Regarding my stupidly reported Xfree86 -problem, it was PEBKAC, though I
can't tell what exactly that was. Only one module changed way to iterate
pci_find_device between boots.


-- 
   Psi -- <http://www.iki.fi/pasi.savolainen>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
