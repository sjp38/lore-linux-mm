Message-ID: <44DF7FB9.8020003@google.com>
Date: Sun, 13 Aug 2006 12:38:33 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
References: <20060808193447.1396.59301.sendpatchset@lappy>	<44D9191E.7080203@garzik.org>	<44D977D8.5070306@google.com> <20060808.225537.112622421.davem@davemloft.net>
In-Reply-To: <20060808.225537.112622421.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeff@garzik.org, a.p.zijlstra@chello.nl, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> I think he's saying that he doesn't think your code is yet a
> reasonable way to solve the problem, and therefore doesn't belong
> upstream.

That is why it has not yet been submitted upstream.  Respectfully, I
do not think that jgarzik has yet put in the work to know if this anti
deadlock technique is reasonable or not, and he was only commenting
on some superficial blemish.  I still don't get his point, if there
was one.  He seems to be arguing in favor of a jump-off-the-cliff
approach to driver conversion.  If he wants to do the work and take
the blame when some driver inevitably breaks because of being edited
in a hurry then he is welcome to submit the necessary additional
patches.  Until then, there are about 3 nics that actually matter to
network storage at the moment, all of them GigE.

The layer 2 blemishes can be fixed easily, including avoiding the
atomic op stall and the ->dev volatility .  Thankyou for pointing
those out.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
