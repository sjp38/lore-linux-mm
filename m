Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 17:08:32 +0200
References: <3D2DF5CB.471024F9@zip.com.au> <Pine.LNX.4.44L.0207111837060.14432-100000@imladris.surriel.com> <3D2E08DE.3C0D619@zip.com.au>
In-Reply-To: <3D2E08DE.3C0D619@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TOVd-0003Je-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 12 July 2002 00:38, Andrew Morton wrote:
> But yes, at some point you do need to stop carving away at the
> clean pagecache and wait on writeback completion.  Not sure
> how to balance that.

Alert alert!  We're supposed to be benchmarking rmap, not fixing the
world just now.  We should just ensure that our rmap and non-rmap
kernels are equally crippled with respect to purging of streaming
IO, unless we have a very specific reason why the situation should
be affected by the difference in scanning strategies.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
