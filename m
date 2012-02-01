Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2D4B06B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 02:32:53 -0500 (EST)
Received: by obbta7 with SMTP id ta7so1294112obb.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 23:32:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120201063420.GA10204@darkstar.nay.redhat.com>
References: <20120201063420.GA10204@darkstar.nay.redhat.com>
Date: Wed, 1 Feb 2012 09:32:52 +0200
Message-ID: <CAOJsxLGVS3bK=hiKJu4NwTv-Nf8TCSAEL4reSZoY4=44hPt8rA@mail.gmail.com>
Subject: Re: [PATCH] move vm tools from Documentation/vm/ to tools/
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 1, 2012 at 8:34 AM, Dave Young <dyoung@redhat.com> wrote:
> tools/ is the better place for vm tools which are used by many people.
> Moving them to tools also make them open to more users instead of hide in
> Documentation folder.

For moving the code:

Acked-by: Pekka Enberg <penberg@kernel.org>

> Also fixed several coding style problem.

Can you please make that a separate patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
