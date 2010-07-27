Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E357B600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 00:40:09 -0400 (EDT)
Received: by qwk4 with SMTP id 4so752869qwk.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 21:40:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1007261510320.2993@chino.kir.corp.google.com>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com>
	<AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com>
	<AANLkTilmr29Vv3N64n7KVj9fSDpfBHIt8-quxtEwY0_X@mail.gmail.com>
	<alpine.LSU.2.00.1005211410170.14789@sister.anvils> <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com>
	<alpine.DEB.2.00.1006011351400.13136@chino.kir.corp.google.com>
	<AANLkTikUO+WMHXqTMc7jR84UMgKidzX5d5JX6q=DvmpY@mail.gmail.com>
	<alpine.DEB.2.00.1007261510320.2993@chino.kir.corp.google.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 14:39:48 +1000
Message-ID: <AANLkTi=Aswf+Hp+qfsC2sCo32hU3E2D4zt3-R35BZ=MC@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 27 July 2010 08:12, David Rientjes <rientjes@google.com> wrote:
> On Tue, 27 Jul 2010, dave b wrote:
>
>> Actually it turns out on 2.6.34.1 I can trigger this issue. What it
>> really is, is that linux doesn't invoke the oom killer when it should
>> and kill something off. This is *really* annoying.
>>
>
> I'm not exactly sure what you're referring to, it's been two months and
> you're using a new kernel and now you're saying that the oom killer isn't
> being utilized when the original problem statement was that it was killing
> things inappropriately?

Sorry about the timespan :(
Well actually it is the same issue. Originally the oom killer wasn't
being invoked and now the problem is still it isn't invoked - it
doesn't come and kill things - my desktop just sits :)
I have since replaced the hard disk - which I thought could be the
issue. I am thinking that because I have shared graphics not using KMS
- with intel graphics - this may be the root of the cause.

--
All things that are, are with more spirit chased than enjoyed.		--
Shakespeare, "Merchant of Venice"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
