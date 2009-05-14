Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 127146B005A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 15:51:50 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8B1FF82C380
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:05:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2jBt7lwxUOIw for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:05:20 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4612882C37D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:05:16 -0400 (EDT)
Date: Thu, 14 May 2009 15:52:27 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/4] vmscan: change the number of the unmapped files in
 zone reclaim
In-Reply-To: <20090513120606.587C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905141551390.1381@qirst.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120606.587C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



Yup, the use of NR_FILE_PAGES there predates the INACTIVE/ACTIVE stats.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
