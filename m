Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 24AD3900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 16:51:18 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p94KZJgA019115
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 14:35:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p94Kp9K9074564
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 14:51:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p94Kp8n8015960
	for <linux-mm@kvack.org>; Tue, 4 Oct 2011 14:51:09 -0600
Subject: Re: [RFCv3][PATCH 1/4] replace string_get_size() arrays
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1317760957.18210.15.camel@Joe-Laptop>
References: <20111001000856.DD623081@kernel>
	 <1317497626.22613.1.camel@Joe-Laptop> <1317756942.7842.38.camel@nimitz>
	 <1317760957.18210.15.camel@Joe-Laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Oct 2011 13:51:06 -0700
Message-ID: <1317761466.7842.41.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com

On Tue, 2011-10-04 at 13:42 -0700, Joe Perches wrote:
> > Right, but we're only handling u64.
> 
> So the declaration should be:
> 
>         static const char byte_units[] = " KMGTPE";

I guess that's worth a comment.  But that first character doesn't get
used.  There were two alternatives:

	static const char byte_units[] = "_KMGTPE";

or something along the lines of:

+	static const char byte_units[] = "KMGTPE";
...
+	index--;
+       /* index=-1 is plain 'B' with no other unit */
+       if (index >= 0) {

We don't ever _actually_ look at the space (or underscore).  I figured
the _ was nicer since it would be _obvious_ if it ever got printed out
somehow.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
