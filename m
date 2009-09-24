Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B28466B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:03:55 -0400 (EDT)
Subject: Re: [PATCH v18 20/80] c/r: basic infrastructure for checkpoint/restart
From: Daniel Walker <dwalker@fifo99.com>
In-Reply-To: <1253749920-18673-21-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	 <1253749920-18673-21-git-send-email-orenl@librato.com>
Content-Type: text/plain
Date: Thu, 24 Sep 2009 09:03:41 -0700
Message-Id: <1253808221.20648.196.camel@desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-09-23 at 19:51 -0400, Oren Laadan wrote:
> /
> +static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *prefmt, char *fmt)
> +{
> +	static int warn_notask = 0;
> +	static int warn_prefmt = 0;

Shouldn't need the initializer since it's static..


> +/* read the checkpoint header */
> +static int restore_read_header(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_header *h;
> +	struct new_utsname *uts = NULL;
> +	int ret;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	ret = -EINVAL;
> +	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
> +	    h->rev != CHECKPOINT_VERSION ||
> +	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
> +	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
> +	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
> +		goto out;

Do you still need this LINUX_VERSION_CODE stuff ? I would think once
it's in mainline you wouldn't need to track that..

These both got flagged by checkpatch .. Your series is marked in a
couple other places with checkpatch errors .. If you haven't already
reviewed those errors, it would be a good idea to review them.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
