Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 11:32:05 -0700
Message-Id: <1027017125.1116.130.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 10:31, Szakacsits Szabolcs wrote:

> Ahh, I figured out your target, embedded devices. Yes it's good for
> that but not enough for general purpose.

I think this applies to more than just embedded devices.  Further, it
applies to even the case you are talking about because the issues are
_orthogonal_.

If you also have an issue with root vs non-root users then you need
resource limits.  You still need this too.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
