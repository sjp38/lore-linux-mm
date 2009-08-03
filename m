Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 473B86B005C
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 14:05:15 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n73II6Lv007498
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 12:18:06 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n73IQcA9196028
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 12:26:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n73IQcpD022495
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 12:26:38 -0600
Date: Mon, 3 Aug 2009 13:26:40 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v17][PATCH 16/60] pids 6/7: Define do_fork_with_pids()
Message-ID: <20090803182640.GB7493@us.ibm.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-17-git-send-email-orenl@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248256822-23416-17-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@librato.com):
> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
...
> +struct target_pid_set {
> +	int num_pids;
> +	pid_t *target_pids;
> +};

Oren, I thought you had decided to add an extended flags field
here, to support additional CLONE_ flags - such as CLONE_TIMENS?

I mention it now because if you're still considering that
long-term, then IMO the syscall should not be called clone_with_pids(),
but clone_extended().  Otherwise, to support new clone flags we'll
either have to use unshare2 (without clone support), or add yet
another clone variant, OR use clone_with_pids() which is a poor name
for something which will likely be used in cases without specifying
pids, but specifying flags not support through any other interface.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
