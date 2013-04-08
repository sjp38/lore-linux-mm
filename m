Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6FD806B0039
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:37:45 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 15:37:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8FE9838C8054
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:37:39 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38Jbb3f282130
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 15:37:38 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38JbTC9014350
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 13:37:29 -0600
Message-ID: <51631C70.8010404@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 12:37:20 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: fixup changers of per cpu pageset's ->high and
 ->batch
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <5160CC94.6040909@gmail.com>
In-Reply-To: <5160CC94.6040909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/06/2013 06:32 PM, Simon Jeons wrote:
> Hi Cody,
> On 04/06/2013 04:33 AM, Cody P Schafer wrote:
>> In one case while modifying the ->high and ->batch fields of per cpu
>> pagesets
>> we're unneededly using stop_machine() (patches 1 & 2), and in another
>> we don't have any
>> syncronization at all (patch 3).
>
> Do you mean stop_machine() is used for syncronization between each
> online cpu?
>

I mean that it looks like synchronization between cpus is unneeded 
because of how per cpu pagesets are used, so stop_machine() (which does 
provide syncro between all cpus) is unnecessarily "strong".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
