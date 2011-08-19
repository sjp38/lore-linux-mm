Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 48C226B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 13:25:10 -0400 (EDT)
From: Chris Ball <cjb@laptop.org>
Subject: Re: [PATCH --mmotm v8 0/3] Make fault injection available for MMC IO
References: <1312891671-28680-1-git-send-email-per.forlin@linaro.org>
	<CAJ0pr1-8Jnk1CKakWcS6T4Q3bAe7sF=5p8+9ou1+SbxsZM_Svw@mail.gmail.com>
Date: Fri, 19 Aug 2011 13:24:55 -0400
In-Reply-To: <CAJ0pr1-8Jnk1CKakWcS6T4Q3bAe7sF=5p8+9ou1+SbxsZM_Svw@mail.gmail.com>
	(Per Forlin's message of "Fri, 19 Aug 2011 11:53:44 +0200")
Message-ID: <m2pqk1mhzs.fsf@bob.laptop.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org

Hi Per,

On Fri, Aug 19 2011, Per Forlin wrote:
> Hi Chris,
>
> It's no longer necessary to merge this through the mm-tree since
> Akinobu's patch "fault-injection: add ability to export fault_attr in
> arbitrary directory" is in mainline.
> Chris, would you mind merging the fault-injection patches in this
> patchset to mmc-next once the mmc part of this patchset is acked and
> accepted?

That's fine -- merged to mmc-next for 3.2 now, with Linus W's review.

Thanks,

- Chris.
-- 
Chris Ball   <cjb@laptop.org>   <http://printf.net/>
One Laptop Per Child

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
