Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] start_aggressive_readahead
Date: Fri, 26 Jul 2002 08:53:25 +0200
References: <20020725181059.A25857@lst.de>
In-Reply-To: <20020725181059.A25857@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17Xyyf-0006Al-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 25 July 2002 18:10, Christoph Hellwig wrote:
> I'm also open for a better name (I think the current one is very bad,
> but don't have a better idea :)).  I'd also be ineterested in comments
> how to avoid the new function and use existing functionality for it,
> but I've tried to find it for a long time and didn't find something
> suiteable.

That's the right attitude imho.  Redoing reahead needs to be a project
all by itself, a fine thing to experiment with in the stable series.
A bad idea that sort of works for now is better than what we've got.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
