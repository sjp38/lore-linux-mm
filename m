Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4BD7E6B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 12:36:15 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 30 May 2013 12:36:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C1CA3C90045
	for <linux-mm@kvack.org>; Thu, 30 May 2013 12:36:10 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4UGaA3I218874
	for <linux-mm@kvack.org>; Thu, 30 May 2013 12:36:11 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4UGdF6h022840
	for <linux-mm@kvack.org>; Thu, 30 May 2013 10:39:16 -0600
Message-ID: <51A77FF7.5090908@linux.vnet.ibm.com>
Date: Thu, 30 May 2013 09:36:07 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sparse: use __aligned() instead of manual padding
 in mem_section
References: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com> <51A6A34B.6020907@gmail.com>
In-Reply-To: <51A6A34B.6020907@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 05/29/2013 05:54 PM, Jiang Liu wrote:
> On Thu 30 May 2013 07:14:39 AM CST, Cody P Schafer wrote:
>> Also, does anyone know what causes this alignment to be required here? I found
>> this was breaking things in a patchset I'm working on (WARNs in sysfs code
>> about duplicate filenames when initing mem_sections). Adding some documentation
>> for the reason would be appreciated.
> Hi Cody,
>          I think the alignment requirement is caused by the way the
> mem_section array is
> organized. Basically it requires that PAGE_SIZE could be divided by
> sizeof(struct mem_section).
> So your change seems risky too because it should be aligned to power of
> two instead
> of 2 * sizeof(long).

Well, if that's the case then this patch is wrong, and manual padding 
may be the only way to go. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
