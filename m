Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20B419000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 13:46:47 -0400 (EDT)
Received: by vws7 with SMTP id 7so5050778vws.35
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 10:46:44 -0700 (PDT)
Message-ID: <4E738B81.2070005@vflare.org>
Date: Fri, 16 Sep 2011 13:46:41 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org> <4E72284B.2040907@linux.vnet.ibm.com>
In-Reply-To: <4E72284B.2040907@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

Hi Seth,

On 09/15/2011 12:31 PM, Seth Jennings wrote:

> 
> So this is how I see things...
> 
> Right now xvmalloc is broken for zcache's application because
> of its huge fragmentation for half the valid allocation sizes
> (> PAGE_SIZE/2).
> 
> My xcfmalloc patches are _a_ solution that is ready now.  Sure,
> it doesn't so compaction yet, and it has some metadata overhead.
> So it's not "ideal" (if there is such I thing). But it does fix
> the brokenness of xvmalloc for zcache's application.
> 
> So I see two ways going forward:
> 
> 1) We review and integrate xcfmalloc now.  Then, when you are
> done with your allocator, we can run them side by side and see
> which is better by numbers.  If yours is better, you'll get no
> argument from me and we can replace xcfmalloc with yours.
> 
> 2) We can agree on a date (sooner rather than later) by which your
> allocator will be completed.  At that time we can compare them and
> integrate the best one by the numbers.
> 


I think replacing allocator every few weeks isn't a good idea. So, I
guess better would be to let me work for about 2 weeks and try the slab
based approach.  If nothing works out in this time, then maybe xcfmalloc
can be integrated after further testing.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
