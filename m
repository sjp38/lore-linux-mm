Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E133B6B0006
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:16:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n17-v6so19431123pff.10
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:16:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u13-v6si8596565pgg.263.2018.07.12.16.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:16:46 -0700 (PDT)
Date: Thu, 12 Jul 2018 16:16:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-Id: <20180712161644.02dec2142cad842bc8b73a41@linux-foundation.org>
In-Reply-To: <c68aa6ad-9e35-f828-6373-39938fd6e2a7@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
	<20180709081920.GD22049@dhcp22.suse.cz>
	<62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
	<20180710142740.GQ14284@dhcp22.suse.cz>
	<a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
	<20180711102139.GG20050@dhcp22.suse.cz>
	<9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	<20180712084807.GF32648@dhcp22.suse.cz>
	<c68aa6ad-9e35-f828-6373-39938fd6e2a7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Thu, 12 Jul 2018 12:12:28 -0400 Waiman Long <longman@redhat.com> wrote:

> The rationale beside this patchset comes from a customer request to have
> the ability to track and limit negative dentries. 

Please go back to customer and ask them "why", then let us know.

Could I suggest you stop working on implementation things and instead
work on preparing a comprehensive bug report?  Describe the workload,
describe the system behavior, describe why it is problematic, describe
the preferred behavior, etc.

Once we have that understanding, it might be that we eventually agree
that the problem is unfixable using existing memory management
techniques and that it is indeed appropriate that we add a lot more
code which essentially duplicates kswapd functionality and which
essentially duplicates direct reclaim functionality.  But I sure hope
not.
