Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA05201
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 08:36:34 -0500
Date: Thu, 3 Dec 1998 13:03:35 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: SWAP: Linux far behind Solaris or I missed something (fwd)
Message-ID: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Jean-Michel.Vansteene@bull.net
List-ID: <linux-mm.kvack.org>

Hi,

I think we really should be working on this -- anybody
got a suggestion?

(although the 2.1.130+my patch seems to work very well
with extremely high swap throughput)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

---------- Forwarded message ----------
Date: Wed, 02 Dec 1998 16:49:30 +0100
From: Jean-Michel VANSTEENE <Jean-Michel.Vansteene@bull.net>
To: linux-kernel <linux-kernel@vger.rutgers.edu>
Subject: SWAP: Linux far behind Solaris or I missed something

I've made some tests to load a computer (1GB memory).
A litle process starts eating 900 MB then slowly eats 
the remainder of the memory 1MB by 1MB and does a
"data shake": 200,000 times a memcpy of 4000 bytes 
randomly choosen.

I want to test the swap capability.

Solaris was used under XWindow, Linux under text
console... What do I forget to comfigure or tune?
Don't let me with such bad values.......

------------------------------------------------	
I removed micro seconds displayed by my function
after call to gettimeofday

megs    Solaris      Linux
------------------------------------------------
901:    18 secs      9 secs
902:    11 secs      9 secs
903:    10 secs      9 secs
904:    9 secs       9 secs
905:    9 secs       9 secs
906:    9 secs       9 secs
907:    9 secs       9 secs
908:    9 secs       9 secs
909:    9 secs       9 secs
910:    9 secs       13 secs
911:    9 secs       17 secs
912:    9 secs       20 secs
913:    9 secs       24 secs
914:    9 secs       33 secs
915:    10 secs      44 secs
916:    9 secs       56 secs
917:    9 secs       65 secs
918:    9 secs       75 secs
919:    9 secs       81 secs
920:    9 secs       87 secs
921:    9 secs       96 secs
922:    9 secs       108 secs
923:    9 secs       122 secs
924:    9 secs       129 secs
925:    9 secs       142 secs
926:    9 secs       155 secs
927:    9 secs       161 secs

928 - 977  always  9 secs under solaris

978:    10 secs      <stop testing>
979:    10 secs       -------
980:    11 secs
981:    14 secs
982:    17 secs
983:    21 secs
984:    28 secs
985:    32 secs
986:    26 secs
987:    18 secs
988:    19 secs
989:    24 secs
990:    29 secs
991:    41 secs
992:    48 secs
993:    85 secs
994:    86 secs
995:    91 secs
996:    92 secs
997:    93 secs
998:    97 secs
999:    83 secs

------------------------------------------------

-- 
*--* mailto:Jean-Michel.Vansteene@bull.net  (Bull)
*--* mailto:vanstee@worldnet.fr             (Home)
*--* http://www.worldnet.fr/~vanstee        (Jean GABIN)
-------------------------------------------------------------
- - - - - U n   L i n u x   s i n o n   r i e n - - - - - - -

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.rutgers.edu
Please read the FAQ at http://www.tux.org/lkml/

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
