Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7C39C6B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 13:47:32 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0AIXHBC018203
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:33:17 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0AIlNfR143202
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:47:24 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0AIlNW7017149
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:47:23 -0700
Message-ID: <4D2B543A.3070609@austin.ibm.com>
Date: Mon, 10 Jan 2011 12:47:22 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory sections
References: <4D2B4B38.80102@austin.ibm.com> <20110110184416.GA18974@kroah.com>
In-Reply-To: <20110110184416.GA18974@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

On 01/10/2011 12:44 PM, Greg KH wrote:
> On Mon, Jan 10, 2011 at 12:08:56PM -0600, Nathan Fontenot wrote:
>> This is a re-send of the remaining patches that did not make it
>> into the last kernel release for de-coupling sysfs memory
>> directories from memory sections.  The first three patches of the
>> previous set went in, and this is the remaining patches that
>> need to be applied.
> 
> Well, it's a bit late right now, as we are merging stuff that is already
> in our trees, and we are busy with that, so this is likely to be ignored
> until after .38-rc1 is out.
> 
> So, care to resend this after .38-rc1 is out so people can pay attention
> to it?

I was afraid of this. I didn't get a chance to get it out sooner but thought
I would send it out anyway.

> 
> 
>> The root of this issue is in sysfs directory creation. Every time
>> a directory is created a string compare is done against all sibling
>> directories to ensure we do not create duplicates.  The list of
>> directory nodes in sysfs is kept as an unsorted list which results
>> in this being an exponentially longer operation as the number of
>> directories are created.
> 
> Are you sure this is still an issue?  I thought we solved this last
> kernel or so with a simple patch?

I'll go back and look at this again.

thanks,
-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
