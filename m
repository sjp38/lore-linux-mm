Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 03CC09000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 13:54:28 -0400 (EDT)
Received: by qadb17 with SMTP id b17so2384820qad.14
        for <linux-mm@kvack.org>; Mon, 03 Oct 2011 10:54:28 -0700 (PDT)
Message-ID: <4E89F6D1.6000502@vflare.org>
Date: Mon, 03 Oct 2011 13:54:25 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>  <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>  <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>  <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>  <4E72284B.2040907@linux.vnet.ibm.com>  <075c4e4c-a22d-47d1-ae98-31839df6e722@default 4E725109.3010609@linux.vnet.ibm.com>  <863f8de5-a8e5-427d-a329-e69a5402f88a@default> <1317657556.16137.696.camel@nimitz>
In-Reply-To: <1317657556.16137.696.camel@nimitz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

Hi Dave,

On 10/03/2011 11:59 AM, Dave Hansen wrote:

> 
> I've been reading through Seth's patches a bit and looking over the
> locking in general.  I'm wondering why preempt_disable() is used so
> heavily.  Preempt seems to be disabled for virtually all of zcache's
> operations.  It seems a bit unorthodox, and I guess I'm anticipating the
> future screams of the low-latency folks. :)
> 
> I think long-term it will hurt zcache's ability to move in to other
> code.  Right now, it's pretty limited to being used in conjunction with
> memory reclaim called from kswapd.  Seems like something we ought to add
> to the TODO list before it escapes from staging/.
> 


I think disabling preemption on the local CPU is the cheapest we can get
to protect PCPU buffers. We may experiment with, say, multiple buffers
per CPU, so we end up disabling preemption only in highly improbable
case of getting preempted just too many times exactly within critical
section. But before we do all that, we really need to come up with cases
where zcache induced latency is/can be a problem.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
