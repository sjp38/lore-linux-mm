Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.30.0207190843200.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207190843200.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Jul 2002 11:06:33 -0700
Message-Id: <1027101993.1116.199.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: root@chaos.analogic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-07-19 at 00:30, Szakacsits Szabolcs wrote:

> *However* distinguishing root and non-root users also in strict VM
> overcommit would make a significant difference for general purpose
> systems, this was always my point.
> 
> Can you see the non-orthogonality now?

Nope, I still disagree and there is no point going back and forth.

We both agree that there are situations where both resource accounting
(or some sort of root-protection like you want) and strict overcommit is
required.

I contend there are situations where only one or the other is needed.

More importantly, I argue the two things should be kept separate. 
Putting some root safety net into strict accounting is a hack (how much
of a net? etc.).  You want to keep users from ruining things - get
per-user resource limits.  You want to keep the machine from
overcommiting memory and thus not OOMing?  Get strict accounting.  You
want both?  Use both.

I provided the first piece.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
