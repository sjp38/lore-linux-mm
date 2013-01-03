Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 53E816B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 11:27:56 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 3 Jan 2013 09:27:55 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B98B219D8045
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 09:27:41 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r03GRfoG179828
	for <linux-mm@kvack.org>; Thu, 3 Jan 2013 09:27:41 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r03GReq5022676
	for <linux-mm@kvack.org>; Thu, 3 Jan 2013 09:27:40 -0700
Message-ID: <50E5B173.7070807@linux.vnet.ibm.com>
Date: Thu, 03 Jan 2013 08:27:31 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/8] Don't allow volatile attribute on THP and KSM
References: <1357187286-18759-1-git-send-email-minchan@kernel.org> <1357187286-18759-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On 01/02/2013 08:28 PM, Minchan Kim wrote:
> VOLATILE imply the the pages in the range isn't working set any more
> so it's pointless that make them to THP/KSM.

One of the points of this implementation is that it be able to preserve
memory contents when there is no pressure.  If those contents happen to
contain a THP/KSM page, and there's no pressure, it seems like the right
thing to do is to leave that memory in place.

It might be a fair thing to do this in order to keep the implementation
more sane at the moment.  But, we should make sure there's some good
text on that in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
