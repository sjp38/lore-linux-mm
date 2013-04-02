Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E91FE6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 02:43:48 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id c10so76861wiw.1
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 23:43:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130319051045.GB8858@lge.com>
References: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20130319051045.GB8858@lge.com>
Date: Tue, 2 Apr 2013 09:43:47 +0300
Message-ID: <CAOJsxLH7Vhi1ady+uu5Vn-o5bW4rd6MiJZ1Okjqo2nX-JjgXAQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 19, 2013 at 7:10 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Could you pick up 1/3, 3/3?
> These are already acked by Christoph.
> 2/3 is same effect as Glauber's "slub: correctly bootstrap boot caches",
> so should skip it.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
