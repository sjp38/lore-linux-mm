Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA23054
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 17:38:04 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> 	<199808271207.OAA15842@hwal02.hyperwave.com> 	<87emu2zkc0.fsf@atlas.CARNet.hr> 	<199808271243.OAA28073@hwal02.hyperwave.com> 	<m1d89lex3t.fsf@flinx.npwt.net> <199808280909.LAA19060@hwal02.hyperwave.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 28 Aug 1998 23:36:29 +0200
In-Reply-To: Bernhard Heidegger's message of "Fri, 28 Aug 1998 11:09:59 +0200 (MET DST)"
Message-ID: <87soighjqa.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Bernhard Heidegger <bheide@hyperwave.com>
Cc: "Eric W. Biederman" <ebiederm@inetnebr.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Bernhard Heidegger <bheide@hyperwave.com> writes:

> >>>> Questions is why can't this functionality be integrated in the kernel, 
> >>>> so we don't have to run yet another daemon?
> 
> >> We can do this in kernel thread but I don't see the win.
> 
> I don't have a problem with the user level thing (so I can decide to not
> start it ;-)
> 

You can always tune things up to you preference, even with update
functionality in the kernel. If you set flushing period to say 12
hours, it's effectively like you killed update. :)
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
			Do vampires get AIDS?
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
