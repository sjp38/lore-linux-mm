Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing, leak gone
Date: Fri, 22 Feb 2002 10:21:23 +0100
References: <Pine.LNX.4.33.0202181758260.24597-100000@home.transmeta.com> <E16e8Gf-0005HN-00@starship.berlin> <E16e9Fw-0005I3-00@starship.berlin>
In-Reply-To: <E16e9Fw-0005I3-00@starship.berlin>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16eBtL-0005J9-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

I found the leak.  As predicted, it was stupid, a get_page left over from a 
previous incarnation.  Now it's behaving pretty nicely.  I haven't seen an
oops for a while and leaks seem to be down to a dull roar if not entirely 
gone.  I think swapoff isn't entirely comfortable with the new situation, and 
tends to hang, I'll look into that in due course.

Since I don't actually have a user base for this, I just overwrote the 
previously posted leaky version, it's still:

  nl.linux.org/~phillips/ptab-2.4.17-3

This is getting to the point of needing heavier testing.

-- 
Daniel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
