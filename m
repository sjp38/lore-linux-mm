Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9738D6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 09:11:07 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so5962829obb.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 06:11:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205171329440.12366@router.home>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
	<1337269668-4619-5-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1205171329440.12366@router.home>
Date: Fri, 18 May 2012 22:11:06 +0900
Message-ID: <CAAmzW4Py8-UQmTcgfXzszco=FqGd-FGPA4qMKAmt70NtFwgpQA@mail.gmail.com>
Subject: Re: [PATCH 4/4] slub: refactoring unfreeze_partials()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/5/18 Christoph Lameter <cl@linux.com>:
> The reason the current implementation is so complex is to avoid races. The
> state of the list and the state of the partial pages must be consistent at
> all times.
OK. I got it.

> Looks good. If I can convince myself that this does not open up any
> new races then I may ack it.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
