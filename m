Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4A86680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 19:05:16 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so51262966itb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 16:05:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x197si1929215pgx.75.2017.02.14.16.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 16:05:15 -0800 (PST)
Date: Tue, 14 Feb 2017 16:05:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/autonuma: don't use set_pte_at when updating
 protnone ptes
Message-Id: <20170214160514.40765dfab42491b8b7b9bf3c@linux-foundation.org>
In-Reply-To: <87a89ovp4q.fsf@skywalker.in.ibm.com>
References: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<87a89ovp4q.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Feb 2017 19:41:17 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> 
> > Architectures like ppc64, use privilege access bit to mark pte non accessible.
> > This implies that kernel can do a copy_to_user to an address marked for numa fault.
> > This also implies that there can be a parallel hardware update for the pte.
> > set_pte_at cannot be used in such scenarios. Hence switch the pte
> > update to use ptep_get_and_clear and set_pte_at combination.
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> With this and other patches a kvm guest is giving me
> 
> ...
> 
> Reverting this patch gets rid of the above hang. But I am running into segfault
> with systemd in guest. It could be some other patches in my local tree.
> 
> Maybe we should hold merging this to 4.11 and wait for this to get more
> testing ?

Shall do.  Please let me know the outcome...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
