Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D0B916B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 08:04:29 -0500 (EST)
Received: by wwg38 with SMTP id 38so216421wwg.26
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 05:04:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1111211413460.1879@sister.anvils>
References: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
	<alpine.LSU.2.00.1111201923330.1806@sister.anvils>
	<CAJd=RBBa-ZoZ3GhYQ-aM=TJ9Zw6ZSu177PWw+s8+zyFnzyUV_w@mail.gmail.com>
	<alpine.LSU.2.00.1111211413460.1879@sister.anvils>
Date: Tue, 22 Nov 2011 21:04:26 +0800
Message-ID: <CAJd=RBD7OEmuP9HJS9eq2b5KFfNikf61Zi8+UkxQuD_88vRV4g@mail.gmail.com>
Subject: Re: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 22, 2011 at 6:23 AM, Hugh Dickins <hughd@google.com> wrote:
> But what's the point in enlarging the kernel, adding code to make
> break_cow() look more complicated, when there's no way in which the
> addition can make an improvement?
>
Hello Hugh

Thanks for correcting me, there is no real point to complicate the function.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
