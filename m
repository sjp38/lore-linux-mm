Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] On paging of kernel VM.
Date: Tue, 10 Sep 2002 02:28:53 +0200
References: <2653.1031563253@redhat.com>
In-Reply-To: <2653.1031563253@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oYth-0006wD-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 09 September 2002 11:20, David Woodhouse wrote:
> But as I said, this means screwing with every fault handler. It doesn't 
> have to affect the fast path -- we can go looking for these vmas only in 
> the case where we've already tried looking for the appropriate pte in 
> init_mm and haven't found it. But it's still an intrusive change that would 
> need to be done on every architecture.

Why can't you go per-architecture and fall back to the slow way of doing it
for architectures that don't have the new functionality yet?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
