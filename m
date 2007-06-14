Message-Id: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:26 -0700
From: clameter@sgi.com
Subject: [RFC 00/13] RFC memoryless node handling fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This has now become a longer series since I have seen a couple of things in
various places where we do not take into account memoryless nodes.

I changed the GFP_THISNODE fix to generate a new set of zonelists. GFP_THISNODE
will then simply use a zonelist that only has the zones of the node.

I have only tested this by booting on a IA64 simulator. Please review. I do not
have a real system with a memoryless node.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
