Received: from pfaffben.user.msu.edu (mail@pfaffben.user.msu.edu [35.10.20.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA02623
	for <linux-mm@kvack.org>; Wed, 17 Mar 1999 00:45:26 -0500
Subject: Re: Small patch to mm/mmap_avl.c
References: <36EF35C3.E0EFC58D@interaccess.com>
Reply-To: pfaffben@pilot.msu.edu
From: Ben Pfaff <pfaffben@pilot.msu.edu>
Date: 17 Mar 1999 00:47:01 -0500
In-Reply-To: "Paul F. Dietz"'s message of "Tue, 16 Mar 1999 22:55:31 -0600"
Message-ID: <87zp5cr7l6.fsf@pfaffben.user.msu.edu>
Sender: owner-linux-mm@kvack.org
To: "Paul F. Dietz" <dietz@interaccess.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Paul F. Dietz" <dietz@interaccess.com> writes:

   I want to rewrite the AVL tree code in mm/mmap_avl.c.
   Before I do that, though, I wanted to clean up the
   existing code a bit.  Here's a small patch to 2.2.3 that
   gets rid of some unnecessary counters.  After this,
   I want to recode using the AVL tree routines from
   Knuth vol. 3, storing the height difference of the
   children at each node, rather than the height itself.

If you want to do it using Knuth vol. 3, then you might want to take a
look at my libavl, which uses his algorithm for insertion and an
algorithm I developed from his outline for deletion.  All iterative,
of course, given the way that Knuth writes his algorithms.

You can find libavl at ftp://ftp.gnu.org/pub/gnu/avl.  Currently
version 1.2.4 is there but 1.2.8 with minor nits fixed should be moved
there soon; 1.2.8 is currently in ftp://alpha.gnu.org/gnu.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
