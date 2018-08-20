Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D565D6B193A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 10:13:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e23-v6so14309195oii.10
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 07:13:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f2-v6si7676791oih.58.2018.08.20.07.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 07:13:00 -0700 (PDT)
Subject: Re: INFO: task hung in generic_file_write_iter
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz>
 <8248f4e9-3567-b8f5-4751-8b38c1807eff@i-love.sakura.ne.jp>
Message-ID: <e51a7822-3fdc-3f7a-25bd-5d8d8df44749@i-love.sakura.ne.jp>
Date: Mon, 20 Aug 2018 23:12:10 +0900
MIME-Version: 1.0
In-Reply-To: <8248f4e9-3567-b8f5-4751-8b38c1807eff@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 2018/08/06 20:56, Tetsuo Handa wrote:
> On 2018/08/06 19:09, Jan Kara wrote:
>> Looks like some kind of a race where device block size gets changed while
>> getblk() runs (and creates buffers for underlying page). I don't have time
>> to nail it down at this moment can have a look into it later unless someone
>> beats me to it.
>>
> 
> It seems that loop device is relevant to this problem.

Speak of loop device, I'm waiting for Jens for three months
http://lkml.kernel.org/r/1527297408-4428-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
but Jens is too busy to come up with an alternative. Since that is a big patch, I wish we can
start testing that patch before Jan starts writing a patch for fixing getblk() race problem.
