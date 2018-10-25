Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 501326B02C5
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 17:44:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c6-v6so6596756pls.15
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 14:44:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t11-v6si9672216pgo.494.2018.10.25.14.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 14:44:52 -0700 (PDT)
Date: Thu, 25 Oct 2018 17:44:49 -0400
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Message-ID: <20181025214449.GA2015@sasha-vm>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
 <20181025092352.GP18839@dhcp22.suse.cz>
 <20181025124442.5513d282273786369bbb7460@linux-foundation.org>
 <20181025202014.GA216405@sasha-vm>
 <20181025202707.GL25444@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181025202707.GL25444@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Sasha Levin <Alexander.Levin@microsoft.com>

On Thu, Oct 25, 2018 at 01:27:07PM -0700, Matthew Wilcox wrote:
>On Thu, Oct 25, 2018 at 04:20:14PM -0400, Sasha Levin wrote:
>> On Thu, Oct 25, 2018 at 12:44:42PM -0700, Andrew Morton wrote:
>> > Yup.  Sasha, can you please take care of this?
>>
>> Sure, I'll revert it from current stable trees.
>>
>> Should 172b06c32b94 and this commit be backported once Roman confirms
>> the issue is fixed? As far as I understand 172b06c32b94 addressed an
>> issue FB were seeing in their fleet and needed to be fixed.
>
>I'm not sure I see "FB sees an issue in their fleet" and "needs to be
>fixed in stable kernels" as related.  FB's workload is different from
>most people's workloads and FB has a large and highly-skilled team of
>kernel engineers.  Obviously I want this problem fixed in mainline,
>but I don't know that most people benefit from having it fixed in stable.

I don't want to make backporting decisions based on how big a certain
company's kernel team is. I only mentioned FB explicitly to suggest that
this issue is seen on real-life scenarios rather than on synthetic tests
or code review.

So yes, let's not run to fix it just because it's FB but also let's not
ignore it because FB has a world-class kernel team. This should be done
purely based on how likely this patch will regress stable kernels vs the
severity of the bug it fixes.

--
Thanks,
Sasha
