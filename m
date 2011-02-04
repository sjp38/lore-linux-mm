Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBE918D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 12:19:18 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p14GxPIh016291
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 12:00:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 810664DE8050
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 12:18:35 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p14HJEoL128004
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 12:19:14 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p14HJEgf005134
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 10:19:14 -0700
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when necessary
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1102031343530.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003359.8DDFF665@kernel>
	 <alpine.DEB.2.00.1102031257490.948@chino.kir.corp.google.com>
	 <1296768812.8299.1644.camel@nimitz>
	 <alpine.DEB.2.00.1102031343530.1307@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 04 Feb 2011 09:19:12 -0800
Message-ID: <1296839952.6737.2316.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 2011-02-03 at 13:46 -0800, David Rientjes wrote:
> > Probably, but we don't currently have any central documentation for it.
> > Guess we could make some, or just ensure that all the users got updated.
> > Any ideas where to put it other than the mm_walk struct?
> 
> I think noting it where struct mm_walk is declared would be best (just a 
> "/* must handle pmd_trans_huge() */" would be sufficient) although 
> eventually it might be cleaner to add a ->pmd_huge_entry(). 

For code maintenance, I really like _not_ hiding this in the API
somewhere.  This way, we have a great, self-explanatory tag wherever
code (possibly) hasn't properly dealt with THPs.  We get a nice,
greppable, cscope'able:

	split_huge_page_pmd()

wherever we need to "teach" the code about THP.

It's kinda like the BKL. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
