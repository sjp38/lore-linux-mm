Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3FB6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:37:26 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so12937342pdb.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:37:26 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id oa11si8159137pdb.33.2015.03.02.17.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 17:37:25 -0800 (PST)
Message-ID: <54F5102F.50902@oracle.com>
Date: Mon, 02 Mar 2015 17:36:47 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] hugetlbfs: accept subpool reserved option and setup
 accordingly
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>	<1425077893-18366-6-git-send-email-mike.kravetz@oracle.com> <20150302151033.562db79cd3da844392461795@linux-foundation.org>
In-Reply-To: <20150302151033.562db79cd3da844392461795@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/02/2015 03:10 PM, Andrew Morton wrote:
> On Fri, 27 Feb 2015 14:58:13 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Make reserved be an option when mounting a hugetlbfs.
>
> New mount option triggers a user documentation update.  hugetlbfs isn't
> well documented, but Documentation/vm/hugetlbpage.txt looks like the
> place.
>

Will do

>
>> reserved
>> option is only possible if size option is also specified.
>
> The code doesn't appear to check for this (maybe it does).  Probably it
> should do so, and warn when it fails.
>

It is hard to see from the diffs, but this case is covered.  If size is
not specified, it implies the size is "unlimited".  The code in the
patch actually makes the mount fail in this case.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
