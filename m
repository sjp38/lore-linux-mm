Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 25D356B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 18:42:27 -0500 (EST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 4 Dec 2012 05:12:17 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E4971125804A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 05:12:03 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB3NgIqo4194590
	for <linux-mm@kvack.org>; Tue, 4 Dec 2012 05:12:19 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB3NgIt1010915
	for <linux-mm@kvack.org>; Tue, 4 Dec 2012 10:42:19 +1100
Message-ID: <50BD38D6.7060900@linux.vnet.ibm.com>
Date: Tue, 04 Dec 2012 07:42:14 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Generate events when tasks change their memory
References: <50B8F2F4.6000508@parallels.com> <50B8F327.4030703@parallels.com>
In-Reply-To: <50B8F327.4030703@parallels.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On 12/01/2012 01:55 AM, Pavel Emelyanov wrote:

>  	case MADV_DOTRACE:
> +		/*
> +		 * Protect pages to be read-only and force tasks to generate
> +		 * #PFs on modification.
> +		 *
> +		 * It should be done before issuing trace-on event. Otherwise
> +		 * we're leaving a short window after the 'on' event when tasks
> +		 * can still modify pages.
> +		 */
> +		change_protection(vma, start, end,
> +				vm_get_page_prot(vma->vm_flags & ~VM_READ),
> +				vma_wants_writenotify(vma));

Should be VM_WRITE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
