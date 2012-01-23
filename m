Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 823106B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 09:38:17 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 23 Jan 2012 07:38:16 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 52E6119D8026
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 07:38:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0NEbBHw211792
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 09:37:12 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0NEa75P002379
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 07:36:07 -0700
Message-ID: <4F1D7056.1080705@linux.vnet.ibm.com>
Date: Mon, 23 Jan 2012 08:36:06 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <20120120141232.a7572919.akpm@linux-foundation.org>
In-Reply-To: <20120120141232.a7572919.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hey Andrew, 

Thanks again for responding.

On 01/20/2012 04:12 PM, Andrew Morton wrote:
> On Mon,  9 Jan 2012 16:51:56 -0600
> Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
>> This patch creates a new memory allocation library named
>> zsmalloc.
> 
> I haven't really begun to look at this yet.  The code is using many
> fields of struct page in new ways.  This is key information for anyone
> to effectively review the code.  So please carefully document (within
> the code itself) the ways in which the various page fields are used:
> semantic meaning of the overload, relationships between them, any
> locking rules or assumptions.

Will do.

> It appears that a pile of dead code will be generated if CPU hotplug is
> disabled.  (That's if it compiles at all!).  Please take a look at users
> of hotcpu_notifier() - this facility cunningly causes all the hotplug code
> to vanish from vmlinux if it is unneeded.

I'll take a look at hotcpu_notifier() users.  Thanks.

> afacit this code should be added to core mm/.  Addition of code like
> this to core mm/ will be fiercely resisted on principle!  Hence the
> (currently missing) justifications for adding it had best be good ones.

Thanks for the insight.  I'll put some work into spelling out the benefits
this code provides that are not currently provided by any other code in the
kernel right now (afaik).

If you think this belongs in mm/ then disregard my previous comment in
the response to the cover letter.  I guess I was leaning toward putting it
in lib/ specifically because I knew that it would be hard to get it into mm/.

Thanks
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
