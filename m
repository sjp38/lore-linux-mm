Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3U7lmQo008181
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 13:17:48 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3U7lfqs1355818
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 13:17:42 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3U7llNM024142
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 07:47:47 GMT
Date: Wed, 30 Apr 2008 13:17:38 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: correct use of vmtruncate()?
Message-ID: <20080430074738.GC7791@skywalker>
References: <20080429100601.GO108924158@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429100601.GO108924158@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 08:06:01PM +1000, David Chinner wrote:
> Folks,
> 
> It appears to me that vmtruncate() is not used correctly in
> block_write_begin() and friends. The short summary is that it
> appears that the usage in these functions implies that vmtruncate()
> should cause truncation of blocks on disk but no filesystem
> appears to do this, nor does the documentation imply they should.

Looking at ext*_truncate, I see we are freeing blocks as a part of vmtruncate.
Or did I miss something ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
