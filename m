Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>
	<m3snvrvymq.fsf@austin.jhcloos.com>
From: "James H. Cloos Jr." <cloos@jhcloos.com>
In-Reply-To: "James H. Cloos Jr."'s message of "09 May 2000 23:05:01 -0500"
Date: 10 May 2000 02:29:09 -0500
Message-ID: <m366smx3qy.fsf@austin.jhcloos.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Ok.  Tried w/ Manfred patch (ie the 2nd half).  kswapd still uses a lot
of cpu doing recursuve cp(1)s, but it is less than in virgin pre7-8.  I
got about 10s of cpu for cp and 40s for kswapd doing a cp -a of the 7-8
tree (after compiling) on the ide drive (w/ 4k ext2 blocks).  On the 1k
ext2 block scsi partition, it was 1m50s for kswapd and 20s for cp to cp
three such trees.  kswapd %cpu never exceeded 65% on the latter and 50%
on the former; substantially better than in virgin 7-8, but not as good
as earlier kernels (though I don't have any numbers to back that up). I
did this test in single user mode w/ only top running (on another vc).

Hope the datapoint helps!

-JimC
-- 
James H. Cloos, Jr.  <URL:http://jhcloos.com/public_key> 1024D/ED7DAEA6 
<cloos@jhcloos.com>  E9E9 F828 61A4 6EA9 0F2B  63E7 997A 9F17 ED7D AEA6
        Save Trees:  Get E-Gold! <URL:http://jhcloos.com/go?e-gold>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
