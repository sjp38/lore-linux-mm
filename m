Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.30.0207181900390.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207181900390.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 11:28:59 -0700
Message-Id: <1027016939.1086.127.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 10:25, Szakacsits Szabolcs wrote:

> And my point (you asked for comments) was that, this is only (the
> harder) part of the solution making Linux a more reliable (no OOM
> killing *and* root always has the control) and cost effective platform
> (no need for occasionally very complex and continuous resource limit
> setup/adjusting, especially for inexpert home/etc users).

I understand your point, and you are entirely right.

But it is a _completely_ unrelated issue.  The goal here is to not
overcommit memory and I think we succeeded.

An orthogonal issue is per-user resource limits and this may need to be
coupled with that.  It is not a problem I am trying to solve, however.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
