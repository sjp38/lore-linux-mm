From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC][PATCH 2/2]: MM: Make Page Tables Relocatable
References: <20080319142016.E048DDC98D@localhost>
Date: Wed, 19 Mar 2008 15:56:13 +0100
In-Reply-To: <20080319142016.E048DDC98D@localhost> (Ross Biro's message of
	"Wed, 19 Mar 2008 07:20:16 -0700 (PDT)")
Message-ID: <87r6e6oj8y.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

rossb@google.com (Ross Biro) writes:

> diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/#gfp.h# 2.6.23a/include/linux/#gfp.h#
> --- 2.6.23/include/linux/#gfp.h#	1969-12-31 16:00:00.000000000 -0800
> +++ 2.6.23a/include/linux/#gfp.h#	2008-01-30 07:39:06.000000000 -0800
> @@ -0,0 +1,198 @@
> +#ifndef __LINUX_GFP_H
> +#define __LINUX_GFP_H

I suppose you use Emacs?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
