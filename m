Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06C258D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 05:12:34 -0500 (EST)
Received: by qwd7 with SMTP id 7so2610945qwd.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 02:12:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110310000324.GC22723@ZenIV.linux.org.uk>
References: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
	<20110309145859.dbe31df5.akpm@linux-foundation.org>
	<20110310000324.GC22723@ZenIV.linux.org.uk>
Date: Fri, 11 Mar 2011 18:12:32 +0800
Message-ID: <AANLkTikRyhwOEhPyxKW9G5ST7WJSqi4h0=T9duiYf9Cu@mail.gmail.com>
Subject: Re: [PATCH] shmem: put inode if alloc_file failed
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, hch@lst.de, hughd@google.com, npiggin@kernel.dk

On Thu, Mar 10, 2011 at 8:03 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Wed, Mar 09, 2011 at 02:58:59PM -0800, Andrew Morton wrote:
>
>> > +put_inode:
>> > + =C2=A0 iput(inode);
>> > =C2=A0put_dentry:
>> > =C2=A0 =C2=A0 path_put(&path);
>> > =C2=A0put_memory:
>>
>> Is this correct? =C2=A0We've linked the inode to the dentry with
>> d_instantiate(), so the d_put() will do the iput() on the inode.
>
>
> ITYM path_put() and yes, it will. =C2=A0There's no leak.
>

Hi,

Yes, I also think path_put() should, But it seems iput() can't free
that memory during NO-MMU arch.

Would you please take a look at thread: [BUG?] shmem: memory leak on
NO-MMU arch ?

http://www.spinics.net/lists/linux-mm/msg15668.html

Thanks
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
