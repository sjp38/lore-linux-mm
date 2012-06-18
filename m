Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 1A4B56B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 23:14:44 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 17 Jun 2012 21:14:42 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 437743E40048
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 03:13:38 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5I3DcEF260494
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 21:13:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5I3DcxN031886
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 21:13:38 -0600
Date: Mon, 18 Jun 2012 11:13:36 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Message-ID: <20120618031336.GA16855@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
 <jrm5fb$uji$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <jrm5fb$uji$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org

>> When dumping the statistics for zones in the allowed nodes in the
>> function show_free_areas(), skip_free_areas_node() got called for
>> multiple times to figure out the same information: the allowed nodes
>> for dump. It's reasonable to get the allowed nodes at once.
>>

>
>I am not sure if cpuset_current_mems_allowed could be changed
>during show_free_areas(), also show_free_areas() is not called
>in any hot path...
>

Yeah, but I think it's reasonable to dump consistent nodes here.
If cpuset_current_mems_allowed gets changed on the fly, we won't
get consistent dump. So the code change would avoid non-consistent
case if possible.

Thanks,
Gavin

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
