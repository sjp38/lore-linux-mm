Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B61BE620088
	for <linux-mm@kvack.org>; Thu, 13 May 2010 10:49:50 -0400 (EDT)
Received: by pzk28 with SMTP id 28so1484876pzk.11
        for <linux-mm@kvack.org>; Thu, 13 May 2010 07:49:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273761576_4060@mail4.comsite.net>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273761576_4060@mail4.comsite.net>
From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 13 May 2010 22:49:26 +0800
Message-ID: <AANLkTilanD4PlDpLqtTK7uE5o4aPgLhhYvYvVI37GycU@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Milton Miller <miltonm@bga.com>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 10:39 PM, Milton Miller <miltonm@bga.com> wrote:
> On Thu, 13 May 2010 at 17:51:25 +0800, Changli Gao wrote:
>
>> +static inline void *kvcalloc(size_t n, size_t size)
>> +{
>> + =C2=A0 =C2=A0 return __kvmalloc(n * size, __GFP_ZERO);
>>
>
> This needs multiply overflow checking like kcalloc.
>

Thanks.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
