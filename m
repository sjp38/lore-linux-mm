Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6276A6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:53:39 -0400 (EDT)
Received: by oica37 with SMTP id a37so77802234oic.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:53:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c2si8344007oih.6.2015.04.17.09.53.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 09:53:38 -0700 (PDT)
Message-ID: <55313A71.4090202@oracle.com>
Date: Fri, 17 Apr 2015 09:53:05 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/4] mm: madvise allow remove operation for hugetlbfs
References: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com> <1429225378-22965-5-git-send-email-mike.kravetz@oracle.com> <20150417064435.GA21672@infradead.org>
In-Reply-To: <20150417064435.GA21672@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

On 04/16/2015 11:44 PM, Christoph Hellwig wrote:
> On Thu, Apr 16, 2015 at 04:02:58PM -0700, Mike Kravetz wrote:
>> Now that we have hole punching support for hugetlbfs, we can
>> also support the MADV_REMOVE interface to it.
>
> Meh.  Just use fallocate for any new code..
>

I don't have the complete context for your comment.  Is there
a general consensus or effort underway to deprecate the use
of MADV_REMOVE?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
