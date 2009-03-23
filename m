Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E6836B0099
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 23:30:34 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1432101rvb.26
        for <linux-mm@kvack.org>; Sun, 22 Mar 2009 21:27:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0903230151140.11883@blonde.anvils>
References: <Pine.LNX.4.64.0903230151140.11883@blonde.anvils>
Date: Mon, 23 Mar 2009 06:27:48 +0200
Message-ID: <84144f020903222127r5982a325o66638bc2bd55d109@mail.gmail.com>
Subject: Re: [PATCH] shmem: writepage directly to swap
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Rohland <hans-christoph.rohland@sap.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 23, 2009 at 3:57 AM, Hugh Dickins <hugh@veritas.com> wrote:
> Synopsis: if shmem_writepage calls swap_writepage directly, most shmem swap
> loads benefit, and a catastrophic interaction between SLUB and some flash
> storage is avoided.

Nice!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
