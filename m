Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 251F66B00E8
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:58:57 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 17 May 2012 15:58:56 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A263619D804C
	for <linux-mm@kvack.org>; Thu, 17 May 2012 15:58:40 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4HLwqgW202032
	for <linux-mm@kvack.org>; Thu, 17 May 2012 15:58:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4HLwoTw023227
	for <linux-mm@kvack.org>; Thu, 17 May 2012 15:58:51 -0600
Message-ID: <4FB57493.3070308@linux.vnet.ibm.com>
Date: Thu, 17 May 2012 14:58:43 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Huge pages: Memory leak on mmap failure
References: <alpine.DEB.2.00.1205171605001.19076@router.home>
In-Reply-To: <alpine.DEB.2.00.1205171605001.19076@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 05/17/2012 02:07 PM, Christoph Lameter wrote:
> 
> On 2.6.32 and 3.4-rc6 mmap failure of a huge page causes a memory
> leak. The 32 byte kmalloc cache grows by 10 mio entries if running
> the following code:

Urg.  Looks like the resv_maps, probably.  I'll take a look.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
