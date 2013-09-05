Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 741D96B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 10:33:57 -0400 (EDT)
Date: Thu, 5 Sep 2013 14:33:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/4] slab: implement byte sized indexes for the freelist
 of a slab
In-Reply-To: <20130905065552.GA6384@lge.com>
Message-ID: <00000140ee8b386a-f9b8a845-58db-482e-8c63-20fb24404dc8-000000@email.amazonses.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com> <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com> <00000140e42dcd61-00e6cf6a-457c-48bd-8bf7-830133923564-000000@email.amazonses.com> <20130904083305.GC16355@lge.com>
 <20130905065552.GA6384@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 5 Sep 2013, Joonsoo Kim wrote:

> I think that all patchsets deserve to be merged, since it reduces memory usage and
> also improves performance. :)

Could you clean things up etc and the repost the patchset? This time do
*not* do this as a response to an earlier email but start the patchset
with new thread id. I think some people are not seeing this patchset.

There is a tool called "quilt" that can help you send the patchset.

	quilt mail

Tools for git to do the same also exist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
