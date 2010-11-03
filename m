Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ADB876B00B9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:20:35 -0400 (EDT)
Received: by wyf23 with SMTP id 23so800345wyf.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 08:20:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1011030937580.10599@router.home>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
	<AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>
	<20101031173336.GA28141@balbir.in.ibm.com>
	<alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
	<alpine.DEB.2.00.1011030937580.10599@router.home>
Date: Wed, 3 Nov 2010 23:20:32 +0800
Message-ID: <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
From: jovi zhang <bookjovi@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Juhl <jj@chaosbits.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 3, 2010 at 10:38 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 1 Nov 2010, Jesper Juhl wrote:
>
>> On Sun, 31 Oct 2010, Balbir Singh wrote:
>
>> > > There are so many placed need vzalloc.
>> > > Thanks, Jesper.
>
>
> Could we avoid this painful exercise with a "semantic patch"?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
Can we make a grep script to walk all files to find vzalloc usage like this=
?
No need to send patch mail one by one like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
