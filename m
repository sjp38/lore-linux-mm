Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MM patches against 2.5.31
Date: Wed, 28 Aug 2002 19:18:52 +0200
References: <3D644C70.6D100EA5@zip.com.au> <E17jjWN-0002fo-00@starship> <20020828131445.25959.qmail@thales.mathematik.uni-ulm.de>
In-Reply-To: <20020828131445.25959.qmail@thales.mathematik.uni-ulm.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17k6Sy-0002s6-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>
Cc: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 28 August 2002 15:14, Christian Ehrhardt wrote:
> Side note: The BUG in __pagevec_lru_del seems strange. refill_inactive
> or shrink_cache could have removed the page from the lru before
> __pagevec_lru_del acquired the lru lock.

It's suspect all right.  If there's a chain of assumptions that proves
the page is always on the lru at the point, I haven't seen it yet.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
