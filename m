Received: from ariessys.com (ns.ariessys.com [198.115.92.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA23526
	for <linux-mm@kvack.org>; Thu, 29 Apr 1999 10:38:47 -0400
Received: from [198.115.92.60] (lightning.ariessys.com [198.115.92.60])
	by ariessys.com (8.8.8/8.8.8) with ESMTP id KAA19366
	for <linux-mm@kvack.org>; Thu, 29 Apr 1999 10:38:37 -0400
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Message-Id: <v04020a00b34e1e944f31@[198.115.92.60]>
Date: Thu, 29 Apr 1999 10:38:39 -0400
From: "James E. King, III" <jking@ariessys.com>
Subject: 1GB ramdisk
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for all the help.  I don't really need the 4GB memory for
application space...  What I want to do is take the index files of the
database and put them into a ramdisk.  It appears that this is possible,
albeit with some patches.  I think this will substantially increate the
performance of my database system.

Someone suggested using alpha which would solve all of my problems.  True,
but where can I find a quad processor 500MHz alpha box for around $25,000?
Let me know.  Last time I checked, the list price on an AlphaServer 4100
configured this way was over $100,000.

It would be really, really helpful if someone created a ramdisk-HOWTO with
information on how one can create a ramdisk of 1GB or 2GB size. :>


     _/   _/_/  _/_/_/ _/_/  _/_/         James E. King, III
    _/_/  _/ _/   _/   _/   _/            Aries Systems Corporation
   _/_/_/ _/_/    _/   _/_/  _/_/         200 Sutton Street
   _/  _/ _/ _/   _/   _/       _/        North Andover, MA.  01845
   _/  _/ _/ _/ _/_/_/ _/_/  _/_/         (978) 975-7570
                                          (978) 975-3811 FAX
      <http://www.kfinder.com/>
  Enhancing the Power of Knowledge(r)     jking@ariessys.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
