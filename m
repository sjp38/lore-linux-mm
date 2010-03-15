Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 899266B0156
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 14:48:57 -0400 (EDT)
Received: by pvg2 with SMTP id 2so733967pvg.14
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:48:52 -0700 (PDT)
Message-ID: <4B9E810E.9010706@codemonkey.ws>
Date: Mon, 15 Mar 2010 13:48:46 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315091720.GC18054@balbir.in.ibm.com> <4B9DFD9C.8030608@redhat.com>
In-Reply-To: <4B9DFD9C.8030608@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/15/2010 04:27 AM, Avi Kivity wrote:
>
> That's only beneficial if the cache is shared.  Otherwise, you could 
> use the balloon to evict cache when memory is tight.
>
> Shared cache is mostly a desktop thing where users run similar 
> workloads.  For servers, it's much less likely.  So a modified-guest 
> doesn't help a lot here.

Not really.  In many cloud environments, there's a set of common images 
that are instantiated on each node.  Usually this is because you're 
running a horizontally scalable application or because you're supporting 
an ephemeral storage model.

In fact, with ephemeral storage, you typically want to use 
cache=writeback since you aren't providing data guarantees across 
shutdown/failure.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
