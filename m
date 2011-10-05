Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1D7F9400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 11:32:17 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 5 Oct 2011 09:26:27 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95FLiF3098052
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 09:21:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95FLeVX011531
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 09:21:44 -0600
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel>
	 <20111001000900.BD9248B8@kernel>
	 <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Oct 2011 08:21:33 -0700
Message-ID: <1317828093.7842.72.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Tue, 2011-10-04 at 23:50 -0700, David Rientjes wrote:
> That way, 1G pages would just show pagesize=1073741824.  I don't think 
> that's too long and is much easier to parse systematically. 

OK, I'll switch it back.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
