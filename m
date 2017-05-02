Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0976B0038
	for <linux-mm@kvack.org>; Tue,  2 May 2017 17:32:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d3so3459383pfj.5
        for <linux-mm@kvack.org>; Tue, 02 May 2017 14:32:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 70si566143pfi.45.2017.05.02.14.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 14:32:43 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
Date: Tue, 2 May 2017 14:32:42 -0700
MIME-Version: 1.0
In-Reply-To: <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/01/2017 11:00 AM, Prakash Sangappa wrote:
> This patch adds a new hugetlbfs mount option 'noautofill', to indicate that
> pages should not be allocated at page fault time when accessed thru mmapped
> address.

I think the main argument against doing something like this is further
specializing hugetlbfs.  I was really hoping that userfaultfd would be
usable for your needs here.

Could you elaborate on other options that you considered?  Did you look
at userfaultfd?  What about an madvise() option that disallows backing
allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
