Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 74BF56B0088
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 07:16:58 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p07CGs4m007027
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 04:16:55 -0800
Received: from qyk1 (qyk1.prod.google.com [10.241.83.129])
	by kpbe20.cbf.corp.google.com with ESMTP id p07CGnGt027815
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 04:16:52 -0800
Received: by qyk1 with SMTP id 1so351645qyk.18
        for <linux-mm@kvack.org>; Fri, 07 Jan 2011 04:16:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106170942.GA8253@sgi.com>
References: <20110106170942.GA8253@sgi.com>
Date: Fri, 7 Jan 2011 04:16:49 -0800
Message-ID: <AANLkTik_cTS629Ag+jmkJV+M6auEnu0r17EGZ8nXXBj1@mail.gmail.com>
Subject: Re: Very large memory configurations: > 16 TB
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 6, 2011 at 9:09 AM, Jack Steiner <steiner@sgi.com> wrote:
> SGI is currently developing an x86_64 system with more than 16TB of memory per
> SSI. As far as I can tell, this should be supported. The relevant definitions
> such as MAX_PHYSMEM_BITS appear ok.
>
> One area of concern is page counts. Exceeding 16TB will also exceed MAX_INT
> page frames. The kernel (at least in all places I've found) keep pagecounts
> in longs.
>
> Have I missed anything? Should this > 16TB work? Are there any kernel problems or
> problems with user tools that anyone knows of.
>
> Any help or pointers to potential problem areas would be appreciated...

I don't know of any place that uses ints to count physical pages.
However, the page_referenced functions in mm/rmap.c return reference
counts as an integer. I believe a wraparound would only mislead the
LRU algorithms, but I haven't thought about it much. (Not sure why we
return a count anyway, since I believe callers only want to compare it
against zero ???)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
