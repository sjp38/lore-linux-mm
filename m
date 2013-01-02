Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 74C5B6B0068
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 15:40:03 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id h1so13242902oag.20
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 12:40:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1301020201510.18049@eggly.anvils>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils> <alpine.LNX.2.00.1301020201510.18049@eggly.anvils>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 2 Jan 2013 15:39:42 -0500
Message-ID: <CAHGf_=rfmdmC+u48gjPvCTQ9=t5MEKY4DmxUuHrkJf9AN9BZ8w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mempolicy: remove arg from mpol_parse_str, mpol_to_str
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jan 2, 2013 at 5:04 AM, Hugh Dickins <hughd@google.com> wrote:
> Remove the unused argument (formerly no_context) from mpol_parse_str()
> and from mpol_to_str().
>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
