Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 68EF36B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:25:54 -0500 (EST)
Received: by faas10 with SMTP id s10so1469620faa.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 17:25:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CABqxG0dNoXjpOtug62TLX+as0CAt_niQc=msZTh+heLv8zLQyg@mail.gmail.com>
References: <20111115083646.GA21468@darkstar.nay.redhat.com>
	<20111115144943.GJ30922@google.com>
	<CABqxG0dNoXjpOtug62TLX+as0CAt_niQc=msZTh+heLv8zLQyg@mail.gmail.com>
Date: Tue, 15 Nov 2011 17:25:51 -0800
Message-ID: <CAOS58YNk8fymqknAz2autsZF=AFsG0KOef3kAC=avUJiKVPuag@mail.gmail.com>
Subject: Re: [PATCCH percpu: add cpunum param in per_cpu_ptr_to_phys
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Dave Young <dyoung@redhat.com>, gregkh@suse.de, cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Tue, Nov 15, 2011 at 5:15 PM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
>> Does this matter? =A0If it's not a performance critical path, I'd rather
>> keep the generic funtionality.
>
> Hi, why not? the code is redundant, it's an improvement of the code, isn'=
t it?
> Also, kernel code size will be smaller.

(scratching head...) Ummm... I'm not sure whether it's an improvement
or not. The contest is between loss of currently unused functionality
and meaningless optimization. I vote for status quo.

Thanks.

--=20
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
