Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.35-mm1
Date: Thu, 19 Sep 2002 09:51:02 +0200
References: <3D858515.ED128C76@digeo.com>
In-Reply-To: <3D858515.ED128C76@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17rw5X-0000vG-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lse-tech@lists.sourceforge.net" <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Monday 16 September 2002 09:15, Andrew Morton wrote:
> A 4x performance regression in heavy dbench testing has been fixed. The
> VM was accidentally being fair to the dbench instances in page reclaim.
> It's better to be unfair so just a few instances can get ahead and submit
> more contiguous IO.  It's a silly thing, but it's what I meant to do anyway.

Curious... did the performance hit show anywhere other than dbench?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
