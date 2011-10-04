Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 01CA0900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 17:19:03 -0400 (EDT)
Message-ID: <1317763133.20800.4.camel@Joe-Laptop>
Subject: Re: [RFCv3][PATCH 1/4] replace string_get_size() arrays
From: Joe Perches <joe@perches.com>
Date: Tue, 04 Oct 2011 14:18:53 -0700
In-Reply-To: <1317761466.7842.41.camel@nimitz>
References: <20111001000856.DD623081@kernel>
	 <1317497626.22613.1.camel@Joe-Laptop> <1317756942.7842.38.camel@nimitz>
	 <1317760957.18210.15.camel@Joe-Laptop> <1317761466.7842.41.camel@nimitz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com, hpa@zytor.com

On Tue, 2011-10-04 at 13:51 -0700, Dave Hansen wrote:
> On Tue, 2011-10-04 at 13:42 -0700, Joe Perches wrote:
> > > Right, but we're only handling u64.
> > So the declaration should be:
> >         static const char byte_units[] = " KMGTPE";
> I guess that's worth a comment.  But that first character doesn't get
> used.  There were two alternatives:
> 	static const char byte_units[] = "_KMGTPE";

or
	static const char byte_units[] = { 0, 'K', 'M', 'G', 'T', 'P', 'E' };

and use ARRAY_SIZE(byte_units) not strlen(byte_units)
for array size maximum.

> or something along the lines of:
> +	static const char byte_units[] = "KMGTPE";
> ...
> +	index--;
> +       /* index=-1 is plain 'B' with no other unit */
> +       if (index >= 0) {
> 
> We don't ever _actually_ look at the space (or underscore).  I figured
> the _ was nicer since it would be _obvious_ if it ever got printed out
> somehow.  

shrug.  It's all the same stuff.

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
