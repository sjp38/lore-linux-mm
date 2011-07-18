Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1313A9000C2
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 08:14:20 -0400 (EDT)
Received: by vws4 with SMTP id 4so3031748vws.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 05:14:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1310987909-3129-1-git-send-email-amwang@redhat.com>
References: <1310987909-3129-1-git-send-email-amwang@redhat.com>
Date: Mon, 18 Jul 2011 15:14:18 +0300
Message-ID: <CAOJsxLHuqvVEKg84jmRW_yfLic9ytB8GzeAE4YWauxSWryHGzA@mail.gmail.com>
Subject: Re: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, Jul 18, 2011 at 2:18 PM, Amerigo Wang <amwang@redhat.com> wrote:
> On ppc, we got this build error with randconfig:
>
> drivers/built-in.o:(.toc1+0xf90): undefined reference to `vmstat_text': 1 errors in 1 logs
>
> This is due to that it enabled CONFIG_NUMA but not CONFIG_SYSFS.
>
> And the user-space tool numactl depends on sysfs files too.
> So, I think it is very reasonable to make CONFIG_NUMA depend on CONFIG_SYSFS.

Is it? CONFIG_NUMA is useful even without userspace numactl tool, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
