Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 749416B020D
	for <linux-mm@kvack.org>; Fri, 14 May 2010 04:13:02 -0400 (EDT)
Received: by pva4 with SMTP id 4so1107840pva.14
        for <linux-mm@kvack.org>; Fri, 14 May 2010 01:13:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273824214.5605.3625.camel@twins>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273756816.5605.3547.camel@twins> <AANLkTinLT5g5SKjqmQlS2kxvvMq1gsi1jPDgOKTnrT-q@mail.gmail.com>
	<1273824214.5605.3625.camel@twins>
From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 14 May 2010 16:12:41 +0800
Message-ID: <AANLkTimAfd5vWURp75galRdoHxszFS7GYsOfGHZLD3h7@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 4:03 PM, Peter Zijlstra <peterz@infradead.org> wrot=
e:
> On Thu, 2010-05-13 at 22:08 +0800, Changli Gao wrote:
>> > NAK, I really utterly dislike that inatomic argument. The alloc side
>> > doesn't function in atomic context either. Please keep the thing
>> > symmetric in that regards.
>> >
>>
>> There are some users, who release memory in atomic context. for
>> example: fs/file.c: fdmem.
>
> urgh, but yeah, aside from not using vmalloc to allocate fd tables one
> needs to deal with this.
>
> But if that is the only one, I'd let them do the workqueue thing that's
> already there. If there really are more people wanting to do this, then
> maybe add: kvfree_atomic().
>

Tetsuo has pointed another one in apparmor.
http://kernel.ubuntu.com/git?p=3Djj/ubuntu-lucid.git;a=3Dblobdiff;f=3Dsecur=
ity/apparmor/match.c;h=3Dd2cd55419acfcae85cb748c8f837a4384a3a0d29;hp=3Dafc2=
dd2260edffcf88521ae86458ad03aa8ea12c;hb=3Df5eba4b0a01cc671affa429ba1512b6de=
7caeb5b;hpb=3Dabdff9ddaf2644d0f9962490f73e030806ba90d3
, though apparmor hasn't been merged into mainline.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
