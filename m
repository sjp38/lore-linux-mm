Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l27CF7jV301342
	for <linux-mm@kvack.org>; Wed, 7 Mar 2007 23:15:08 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l27C20s3113196
	for <linux-mm@kvack.org>; Wed, 7 Mar 2007 23:02:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l27BwTGq020962
	for <linux-mm@kvack.org>; Wed, 7 Mar 2007 22:58:29 +1100
Message-ID: <45EEA8DA.6060006@linux.vnet.ibm.com>
Date: Wed, 07 Mar 2007 17:28:18 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [PATCH 3/3][RFC] Containers: Pagecache controller
 reclaim
References: <20070305145237.003560000@linux.vnet.ibm.com> > <20070305145311.247699000@linux.vnet.ibm.com> > <1173178212.4998.54.camel@localhost.localdomain> <45ED4CF7.7030501@linux.vnet.ibm.com> <1173258239.4998.79.camel@localhost.localdomain>
In-Reply-To: <1173258239.4998.79.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shane <ibm-main@tpg.com.au>
Cc: riel@redhat.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, balbir@in.ibm.com, linux-kernel@vger.kernel.org, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, devel@openvz.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>


Shane wrote:
> On Tue, 2007-03-06 at 16:43 +0530, Vaidyanathan Srinivasan wrote:
>> Please let me know if so see any problem running the patch.  The
>> patches are against 2.6.20 only since dependent patches are at that level.
> 
> My problem - a bad copy of the patch. It patches o.k.
> However, it fails to compile vmscan. This looks a bit dodgy;
> 
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> @@ -1470,11 +1494,13 @@ unsigned long shrink_all_memory(unsigned
>         int pass;
>         struct reclaim_state reclaim_state;
>         struct scan_control sc = {
> -               .gfp_mask = GFP_KERNEL,
> +               .gfp_mask = GFdefined(CONFIG_CONTAINER_PAGECACHE_ACCT)
> +P_KERNEL,
> 
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> I deleted what looks like an over-enthusiastic "copy-and-paste", and it
> compiled o.k.
> Testing continues.

OOPS!! How did it get there!  That is certainly some random mouse
click.  Thanks for pointing that out.

--Vaidy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
