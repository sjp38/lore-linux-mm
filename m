Received: by wa-out-1112.google.com with SMTP id m33so953113wag
        for <linux-mm@kvack.org>; Thu, 07 Jun 2007 21:41:45 -0700 (PDT)
Message-ID: <787b0d920706072141s5a34ecb3n97007ad857ba4dc9@mail.gmail.com>
Date: Fri, 8 Jun 2007 00:41:45 -0400
From: "Albert Cahalan" <acahalan@gmail.com>
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
In-Reply-To: <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <20070607162004.GA27802@vino.hallyn.com>
	 <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbadari@us.ibm.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 6/7/07, Eric W. Biederman <ebiederm@xmission.com> wrote:

> So it looks to me like we need to do three things:
> - Fix the inode number
> - Fix the name on the hugetlbfs dentry to hold the key
> - Add a big fat comment that user space programs depend on this
>   behavior of both the dentry name and the inode number.

Assuming that this proposed fix goes in:

Since the inode number is the shmid, and this is a number
that the kernel randomly chooses AFAIK, there should be
no need to have different shm segments sharing the same
inode number.

The situation with the key is a bit more disturbing, though
we already hit that anyway when IPC_PRIVATE is used.
(why anybody would NOT use IPC_PRIVATE is a mystery)
So having the key in the name doesn't make things worse.

I have some concern about the device minor number.
This should be the same for all shm mappings; I do not
know if the behavior changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
