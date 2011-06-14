Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1F49F6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 07:16:11 -0400 (EDT)
Received: by vxk20 with SMTP id 20so6087242vxk.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 04:16:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106140356240.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140356240.29206@sister.anvils>
Date: Tue, 14 Jun 2011 14:16:09 +0300
Message-ID: <BANLkTinh+C2a4+mWCtMrRb5GcpQqiF5CUw@mail.gmail.com>
Subject: Re: [PATCH 11/12] tmpfs: use kmemdup for short symlinks
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 14, 2011 at 1:57 PM, Hugh Dickins <hughd@google.com> wrote:
> But we've not yet removed the old swp_entry_t i_direct[16] from
> shmem_inode_info. =A0That's because it was still being shared with the
> inline symlink. =A0Remove it now (saving 64 or 128 bytes from shmem inode
> size), and use kmemdup() for short symlinks, say, those up to 128 bytes.
>
> I wonder why mpol_free_shared_policy() is done in shmem_destroy_inode()
> rather than shmem_evict_inode(), where we usually do such freeing? =A0I
> guess it doesn't matter, and I'm not into NUMA mpol testing right now.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
