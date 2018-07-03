Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 428E96B02A7
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 21:11:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d23-v6so398641qtj.12
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 18:11:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 6-v6si5806748qvd.58.2018.07.02.18.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 18:11:36 -0700 (PDT)
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <1561585c-7d4d-da4a-e9f9-948198eaa562@redhat.com>
Date: Tue, 3 Jul 2018 09:11:28 +0800
MIME-Version: 1.0
In-Reply-To: <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On 07/03/2018 05:18 AM, Andrew Morton wrote:
> On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com> wrote:
>>> A rogue application can potentially create a large number of negative
>>> dentries in the system consuming most of the memory available if it
>>> is not under the direct control of a memory controller that enforce
>>> kernel memory limit.
>> I certainly don't mind the patch series, but I would like it to be
>> accompanied with some actual example numbers, just to make it all a
>> bit more concrete.
>>
>> Maybe even performance numbers showing "look, I've filled the dentry
>> lists with nasty negative dentries, now it's all slower because we
>> walk those less interesting entries".
>>
> (Please cc linux-mm@kvack.org on this work)
>
> Yup.  The description of the user-visible impact of current behavior is
> far too vague.
>
> In the [5/6] changelog it is mentioned that a large number of -ve
> dentries can lead to oom-killings.  This sounds bad - -ve dentries
> should be trivially reclaimable and we shouldn't be oom-killing in such
> a situation.

The OOM situation was observed in an older distro kernel. It may not be
the case with the upstream kernel. I will double check that.

Cheers,
Longman
