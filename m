Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8330B6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:15:15 -0500 (EST)
Received: by eye4 with SMTP id 4so8357571eye.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 17:15:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111115144943.GJ30922@google.com>
References: <20111115083646.GA21468@darkstar.nay.redhat.com>
	<20111115144943.GJ30922@google.com>
Date: Wed, 16 Nov 2011 09:15:12 +0800
Message-ID: <CABqxG0dNoXjpOtug62TLX+as0CAt_niQc=msZTh+heLv8zLQyg@mail.gmail.com>
Subject: Re: [PATCCH percpu: add cpunum param in per_cpu_ptr_to_phys
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dave Young <dyoung@redhat.com>, gregkh@suse.de, cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 15, 2011 at 10:49 PM, Tejun Heo <tj@kernel.org> wrote:
> On Tue, Nov 15, 2011 at 04:36:46PM +0800, Dave Young wrote:
>> per_cpu_ptr_to_phys iterate all cpu to get the phy addr
>> let's leave the caller to pass the cpu number to it.
>>
>> Actually in the only one user show_crash_notes,
>> cpunum is provided already before calling this.
>>
>> Signed-off-by: Dave Young <dyoung@redhat.com>
>
> Does this matter? =C2=A0If it's not a performance critical path, I'd rath=
er
> keep the generic funtionality.

Hi, why not? the code is redundant, it's an improvement of the code, isn't =
it?
Also, kernel code size will be smaller.

>
> Thanks.
>
> --
> tejun
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Regards
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
