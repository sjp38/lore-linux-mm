Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4INwQNs022790
	for <linux-mm@kvack.org>; Wed, 18 May 2005 19:58:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4INwQPE153174
	for <linux-mm@kvack.org>; Wed, 18 May 2005 19:58:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4INwQAf015546
	for <linux-mm@kvack.org>; Wed, 18 May 2005 19:58:26 -0400
In-Reply-To: <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
MIME-Version: 1.0
Subject: Re: page flags ?
Message-ID: <OF5AB2212B.F152D3D7-ON88257005.00830C2C-88257005.00839F74@us.ibm.com>
From: Bryan Henderson <hbryan@us.ibm.com>
Date: Wed, 18 May 2005 16:57:09 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pbadari@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

By the way, shouldn't these really be PG_as_misc/PG_as_specific as opposed 
to PG_fs_misc ...?

In theory, an address space can be something other than a file cache, and 
there's no reason any arbitrary adress_space_ops shouldn't have its own 
private flags.

--
Bryan Henderson                          IBM Almaden Research Center
San Jose CA                              Filesystems
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
