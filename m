Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A94B96B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 02:49:56 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2977660obb.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 23:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335778207-6511-1-git-send-email-jack@suse.cz>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
Date: Tue, 1 May 2012 16:49:55 +1000
Message-ID: <CAPa8GCC_w3h8KS5rmQDt=rx1bw10rHVD5Pz_eqLhG3xw5uPUwg@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>

On 30 April 2012 19:30, Jan Kara <jack@suse.cz> wrote:
> This is a long standing problem (or a surprising feature) in our implementation
> of get_user_pages() (used by direct IO). Since several attempts to fix it
> failed (e.g.
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg06542.html, or
> http://lkml.indiana.edu/hypermail/linux/kernel/0903.1/01498.html refused in
> http://comments.gmane.org/gmane.linux.kernel.mm/31569) and it's not completely
> clear whether we really want to fix it given the costs, let's at least document
> it.

In any case, it should be documented even if it is ever fixed in newer
kernels. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
