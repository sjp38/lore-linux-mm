Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 552466B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:04:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l186-v6so28158231qkc.22
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:04:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d24-v6si1583357qvc.113.2018.07.12.10.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 10:04:06 -0700 (PDT)
Subject: Re: [PATCH v7 3/6] fs/dcache: Add sysctl parameter neg-dentry-limit
 as a soft limit on negative dentries
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
 <1531413965-5401-4-git-send-email-longman@redhat.com>
 <20180712165605.GB3475@bombadil.infradead.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <91d03770-b184-354b-576c-690dade2d695@redhat.com>
Date: Thu, 12 Jul 2018 13:04:04 -0400
MIME-Version: 1.0
In-Reply-To: <20180712165605.GB3475@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 07/12/2018 12:56 PM, Matthew Wilcox wrote:
> On Thu, Jul 12, 2018 at 12:46:02PM -0400, Waiman Long wrote:
>> +int neg_dentry_limit;
>> +EXPORT_SYMBOL_GPL(neg_dentry_limit);
> Why are you exporting it?  What module needs this?

I was following the example of another sysctl parameter in dcache.c -
sysctl_vfs_cache_pressure. Looking more carefully now, you are right
that I don't need to do the exporting. Will fix that in the next update.

Thanks,
Longman
