Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.44L.0207181923180.12241-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0207181923180.12241-100000@imladris.surriel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 15:30:22 -0700
Message-Id: <1027031422.1555.161.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 15:24, Rik van Riel wrote:

> I see no reason to not merge this (useful) part. Not only
> is it useful on its own, it's also a necessary ingredient
> of whatever "complete solution" to control per-user resource
> limits.

I am glad we agree here - resource limits and strict overcommit are two
separate solutions to various problems.  Some they solve individually,
others they solve together.

I may use one, the other, both, or neither.  A clean abstract solution
allows this.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
