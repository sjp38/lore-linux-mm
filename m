Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 20:58:43 +0100
Message-Id: <1027022323.8154.38.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: Robert Love <rml@tech9.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 18:31, Szakacsits Szabolcs wrote:
> 
> On Thu, 18 Jul 2002, Szakacsits Szabolcs wrote:
> > And my point (you asked for comments) was that, this is only (the
> > harder) part of the solution making Linux a more reliable (no OOM
> > killing *and* root always has the control) and cost effective platform
> > (no need for occasionally very complex and continuous resource limit
> > setup/adjusting, especially for inexpert home/etc users).
> 
> Ahh, I figured out your target, embedded devices. Yes it's good for
> that but not enough for general purpose.

Adjusting the percentages to have a root only zone is doable. It helps
in some conceivable cases but not all. Do people think its important, if
so I'll add it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
