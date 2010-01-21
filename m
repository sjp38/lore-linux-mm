Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8D4146B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 22:06:07 -0500 (EST)
Received: by pwj10 with SMTP id 10so4415018pwj.6
        for <linux-mm@kvack.org>; Wed, 20 Jan 2010 19:06:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100121013205.GA29808@shareable.org>
References: <20100120174630.4071.A69D9226@jp.fujitsu.com>
	 <20100120095242.GA5672@desktop>
	 <20100121094733.3778.A69D9226@jp.fujitsu.com>
	 <20100121013205.GA29808@shareable.org>
Date: Thu, 21 Jan 2010 11:06:03 +0800
Message-ID: <979dd0561001201906j5acedd8ay42d7bc68beefbb9e@mail.gmail.com>
Subject: Re: cache alias in mmap + write
From: anfei zhou <anfei.zhou@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 9:32 AM, Jamie Lokier <jamie@shareable.org> wrote:
> KOSAKI Motohiro wrote:
>> =A02. Add some commnet. almost developer only have x86 machine. so, arm
>> =A0 =A0 specific trick need additional explicit explanation. otherwise a=
nybody
>> =A0 =A0 might break this code in the future.
>
> That's Documentation/cachetlb.txt.
>
> What's being discussed here is not ARM-specific, although it appears
> maintainers of different architecture (ARM and MIPS for a start) may
> have different ideas about what they are guaranteeing to userspace.
> It sounds like MIPS expects userspace to use msync() sometimes (even
> though Linux msync(MS_INVALIDATE) is quite broken), and ARM expects to
> to keep mappings coherent automatically (which is sometimes slower
> than necessary, but usually very helpful).
>
>> =A03. Resend the patch. original mail isn't good patch format. please
>> =A0consider to reduce akpm suffer.
>
> This type of change in generic code would need review from a number of
> architecture maintainers, I'd expect.
>
So should I broadcast this mail in order to get their attentions,
linux-arch@vger.kernel.org?

Thanks!
> -- Jamie
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
