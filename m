Date: Mon, 14 Jul 2008 20:21:02 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH] kmemtrace: SLAB hooks.
Message-ID: <20080714202102.4e2ce7b6@linux360.ro>
In-Reply-To: <487B7F99.4060004@linux-foundation.org>
References: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>
	<1215889471-5734-1-git-send-email-eduard.munteanu@linux360.ro>
	<1216052893.6762.3.camel@penberg-laptop>
	<487B7F99.4060004@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jul 2008 11:32:25 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:
 
> > Looks as if the function calls itself i>>?recursively?
> > 
> 
> Code not tested? Are you sure you configured for slab?

This was a stupid typo on my part. I tested, but only with
CONFIG_KMEMTRACE, which took the 'extern' ifdef branch. I'll resubmit
in a few minutes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
