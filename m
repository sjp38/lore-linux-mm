Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6C18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:27:47 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id j5so3674173qtk.11
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:27:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c8si7688757qvp.163.2019.01.15.13.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 13:27:46 -0800 (PST)
Subject: Re: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
 <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <0433488a-c8ad-e31a-6144-648e45478c07@redhat.com>
Date: Tue, 15 Jan 2019 16:27:42 -0500
MIME-Version: 1.0
In-Reply-To: <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, mcgrof@kernel.org, Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, mszeredi@redhat.com, Matthew Wilcox <willy@infradead.org>, lwoodman@redhat.com, James Bottomley <James.Bottomley@hansenpartnership.com>, wangkai86@huawei.com, Michal Hocko <mhocko@kernel.org>

On 12/16/2018 02:37 PM, Linus Torvalds wrote:
> On Fri, Dec 14, 2018 at 1:53 PM Waiman Long <longman@redhat.com> wrote:
>> This patchset addresses 2 issues found in the dentry code and adds a
>> new nr_dentry_negative per-cpu counter to track the total number of
>> negative dentries in all the LRU lists.
> The series looks sane to me. I'm assuming I'll get it either though
> -mm or from Al..
>
>             Linus

Could anyone pick up this patchset?

Thanks,
Longman
