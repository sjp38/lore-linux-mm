Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 176DF6B0088
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 12:11:18 -0500 (EST)
Date: Thu, 6 Jan 2011 11:09:42 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Very large memory configurations:   > 16 TB
Message-ID: <20110106170942.GA8253@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, mingo@elte.hu
Cc: linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>



SGI is currently developing an x86_64 system with more than 16TB of memory per
SSI. As far as I can tell, this should be supported. The relevant definitions
such as MAX_PHYSMEM_BITS appear ok.


One area of concern is page counts. Exceeding 16TB will also exceed MAX_INT
page frames. The kernel (at least in all places I've found) keep pagecounts
in longs.

Have I missed anything? Should this > 16TB work? Are there any kernel problems or
problems with user tools that anyone knows of.

Any help or pointers to potential problem areas would be appreciated...

---
Jack Steiner (steiner@sgi.com)
SGI - Silicon Graphics, Inc. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
