Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBCC6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 15:46:45 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7GJkgGx032462
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 12:46:42 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq2.eem.corp.google.com with ESMTP id p7GJkbb3013624
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 12:46:41 -0700
Received: by qwc9 with SMTP id 9so209489qwc.41
        for <linux-mm@kvack.org>; Tue, 16 Aug 2011 12:46:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110816194050.GB4484@csn.ul.ie>
References: <1313441856-1419-1-git-send-email-wad@chromium.org>
 <20110816093303.GA4484@csn.ul.ie> <CAB=4xhqu1FsJnNbHNeokyROvEFpRJYKhcHRLLw5QTVKOkbkWfQ@mail.gmail.com>
 <20110816194050.GB4484@csn.ul.ie>
From: Roland McGrath <mcgrathr@google.com>
Date: Tue, 16 Aug 2011 12:46:17 -0700
Message-ID: <CAB=4xhrStO=ec92KD2W6V3QzjgaET5jvF1PXdAdu_LdFg7G82Q@mail.gmail.com>
Subject: Re: [PATCH] mmap: add sysctl for controlling ~VM_MAYEXEC taint
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Al Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org

On Tue, Aug 16, 2011 at 12:40 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> They might result in the same system call but one of them creates
> the file under /dev/shm which should not have the same permissions
> problem. The library really appears to want to create a shared
> executable object, using shm_open does not appear that unreasonable
> to me.

People do use shm_open.  Some systems mount /dev/shm with noexec.
That's why we're here in the first place.

> Which then needs to be copied in each distro wanting to do the same
> thing and is not backwards compatible where as using shm_open is.

Each distro wanting to set noexec on its /dev/shm mounts has to set the
sysctl (or its default in their kernel builds), yes.  Otherwise they are
not compatible with the expectation of using PROT_EXEC on files opened with
shm_open.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
