Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65F0D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:39:42 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 72so17886607uaf.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:39:42 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id v2si2444497uae.183.2017.03.17.01.39.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 01:39:41 -0700 (PDT)
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
 <20170316234950.GA5725@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <a0e1af7b-d8a6-2277-b659-66608cc61ef5@huawei.com>
Date: Fri, 17 Mar 2017 16:39:28 +0800
MIME-Version: 1.0
In-Reply-To: <20170316234950.GA5725@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David
 Nellans <dnellans@nvidia.com>

On 2017/3/17 7:49, Jerome Glisse wrote:
> On Thu, Mar 16, 2017 at 01:43:21PM -0700, Andrew Morton wrote:
>> On Thu, 16 Mar 2017 12:05:19 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
>>
>>> Cliff note:
>>
>> "Cliff's notes" isn't appropriate for a large feature such as this. 
>> Where's the long-form description?  One which permits readers to fully
>> understand the requirements, design, alternative designs, the
>> implementation, the interface(s), etc?
>>
>> Have you ever spoken about HMM at a conference?  If so, the supporting
>> presentation documents might help here.  That's the level of detail
>> which should be presented here.
> 
> Longer description of patchset rational, motivation and design choices
> were given in the first few posting of the patchset to which i included
> a link in my cover letter. Also given that i presented that for last 3
> or 4 years to mm summit and kernel summit i thought that by now peoples
> were familiar about the topic and wanted to spare them the long version.
> My bad.
> 
> I attach a patch that is a first stab at a Documentation/hmm.txt that
> explain the motivation and rational behind HMM. I can probably add a
> section about how to use HMM from device driver point of view.
> 

And a simple example program/pseudo-code make use of the device memory 
would also very useful for person don't have GPU programming experience :)

Regards,
Bob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
