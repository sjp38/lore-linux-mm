Date: Fri, 19 Jul 2002 23:36:40 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: [PATCH 6/6] Updated VM statistics patch
In-Reply-To: <Pine.LNX.4.44.0207190154390.4647-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.44.0207192328330.5880-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This latest version takes advantage of the list management macros in 
mm_inline.h to handle all of the 'pgactivate' and 'pgdeactivate' 
counter incrementing.  This simplifies the patch, and makes it easier to 
keep accounting accurate.

	http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.26/
	[ 2.5.26-rmap-6-VMstats2 19-Jul-2002 23:27    10k ]

Craig Kulesa
Steward Obs.
Univ. of Arizona

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
