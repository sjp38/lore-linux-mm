Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1027020179.1085.150.camel@sinai>
References: <Pine.LNX.3.95.1020718150735.1373A-100000@chaos.analogic.com>
	<1027020179.1085.150.camel@sinai>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 21:49:21 +0100
Message-Id: <1027025361.9727.41.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: root@chaos.analogic.com, Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Same issue with HA etc... its not preventing OOM so much as being
> prepared for it, by pushing the failures into the allocation routines
> and out from the page access.
> 
> Certainly Alan and RedHat found a need for it, too.  It should be pretty
> clear why this is an issue...

The code was written initially because we had large customers with a
direct requirement for the facility. It is also very relevant to
embedded systems where you want controlled failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
