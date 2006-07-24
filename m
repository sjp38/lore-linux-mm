Received: by nf-out-0910.google.com with SMTP id i2so289833nfe
        for <linux-mm@kvack.org>; Mon, 24 Jul 2006 07:56:28 -0700 (PDT)
Message-ID: <9a8748490607240756k75c3ceeepc110cdf216dd3e52@mail.gmail.com>
Date: Mon, 24 Jul 2006 16:56:27 +0200
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] Add linux-mm mailing list for memory management in MAINTAINERS file
In-Reply-To: <1153751558.4002.112.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1153713707.4002.43.camel@localhost.localdomain>
	 <1153749795.23798.19.camel@lappy>
	 <1153751558.4002.112.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On 24/07/06, Steven Rostedt <rostedt@goodmis.org> wrote:
> Since I didn't know about the linux-mm mailing list until I spammed all
> those that had their names anywhere in the mm directory, I'm sending
> this patch to add the linux-mm mailing list to the MAINTAINERS file.
>
> Also, since mm is so broad, it doesn't have a single person to maintain
> it, and thus no maintainer is listed.  I also left the status as
> Maintained, since it obviously is.
>

How about having both the linux-mm list and linux-kernel listed?

> +MEMORY MANAGEMENT
> +L:     linux-mm@kvack.org
+L:     linux-kernel@vger.kernel.org
> +S:     Maintained
> +


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
