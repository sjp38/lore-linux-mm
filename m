Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E68426B0062
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 17:18:51 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 24 Oct 2012 15:18:51 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 4824C1FF003C
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:18:47 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9OLIkYu229244
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:18:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9OLIjiI026140
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:18:46 -0600
Message-ID: <50885B2E.5050500@linux.vnet.ibm.com>
Date: Wed, 24 Oct 2012 14:18:38 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
References: <20121012125708.GJ10110@dhcp22.suse.cz> <20121023164546.747e90f6.akpm@linux-foundation.org> <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org> <50884F63.8030606@linux.vnet.ibm.com> <20121024134836.a28d223a.akpm@linux-foundation.org> <20121024210600.GA17037@liondog.tnic>
In-Reply-To: <20121024210600.GA17037@liondog.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On 10/24/2012 02:06 PM, Borislav Petkov wrote:
> On Wed, Oct 24, 2012 at 01:48:36PM -0700, Andrew Morton wrote:
>> Well who knows. Could be that people's vm *does* suck. Or they have
>> some particularly peculiar worklosd or requirement[*]. Or their VM
>> *used* to suck, and the drop_caches is not really needed any more but
>> it's there in vendor-provided code and they can't practically prevent
>> it.
> 
> I have drop_caches in my suspend-to-disk script so that the hibernation
> image is kept at minimum and suspend times are as small as possible.
> 
> Would that be a valid use-case?

Sounds fairly valid to me.  But, it's also one that would not be harmed
or disrupted in any way because of a single additional printk() during
each suspend-to-disk operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
