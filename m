Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 13A146B0073
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 17:16:14 -0400 (EDT)
Received: by oblw8 with SMTP id w8so108726442obl.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 14:16:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id vs4si11901774oeb.39.2015.04.08.14.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 14:16:13 -0700 (PDT)
Message-ID: <55259A95.3030500@oracle.com>
Date: Wed, 08 Apr 2015 14:16:05 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: HugePages_Rsvd leak
References: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
In-Reply-To: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Bohrer <shawn.bohrer@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 04/08/2015 09:15 AM, Shawn Bohrer wrote:
> I've noticed on a number of my systems that after shutting down my
> application that uses huge pages that I'm left with some pages still
> in HugePages_Rsvd.  It is possible that I still have something using
> huge pages that I'm not aware of but so far my attempts to find
> anything using huge pages have failed.  I've run some simple tests
> using map_hugetlb.c from the kernel source and can see that pages that
> have been reserved but not allocated still show up in
> /proc/<pid>/smaps and /proc/<pid>/numa_maps.  Are there any cases
> where this is not true?

Just a quick question.  Are you using hugetlb filesystem(s)?

If so, you might want to take a look at files residing in the
filesystem(s).  As an experiment, I had a program do a simple
mmap() of a file in a hugetlb filesystem.  The program just
created the mapping, and did not actually fault/allocate any
huge pages.  The result was the reservation (HugePages_Rsvd)
of sufficient huge pages to cover the mapping.  When the program
exited, the reservations remained.  If I remove (unlink) the
file the reservations will be removed.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
