Content-Type: text/plain;
  charset="iso-8859-1"
From: Marc-Christian Petersen <m.c.p@wolk-project.de>
Subject: Re: [PATCH] rmap 15c
Date: Thu, 30 Jan 2003 17:09:09 +0100
References: <Pine.LNX.4.50L.0301301131220.27926-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.50L.0301301131220.27926-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200301301709.09692.m.c.p@wolk-project.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 30 January 2003 14:32, Rik van Riel wrote:

Hi Rik,

> rmap 15c:
>   - backport and audit akpm's reliable pte_chain alloc
>     code from 2.5                                         (me)
>   - reintroduce cache size tuning knobs in /proc          (me)
>     | on very, very popular request

GREAT to see this. Already merged for wolk4.0s-pre10 :)

ciao, Marc
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
