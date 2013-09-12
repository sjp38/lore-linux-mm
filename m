Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6E2606B0032
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 02:52:01 -0400 (EDT)
Date: Thu, 12 Sep 2013 15:52:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
Message-ID: <20130912065225.GB8055@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com>
 <20130909043217.GB22390@lge.com>
 <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com>
 <20130910054342.GB24602@lge.com>
 <0000014109c372c6-5f3c49d4-ce8b-4760-b80d-a32e042ec09b-000000@email.amazonses.com>
 <20130911010434.GB24671@lge.com>
 <000001410d66d62b-d6711e2e-31e4-49da-8d20-efba10fc6a54-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001410d66d62b-d6711e2e-31e4-49da-8d20-efba10fc6a54-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 11, 2013 at 02:22:25PM +0000, Christoph Lameter wrote:
> On Wed, 11 Sep 2013, Joonsoo Kim wrote:
> 
> > Anyway, could you review my previous patchset, that is, 'overload struct slab
> > over struct page to reduce memory usage'? I'm not sure whether your answer is
> > ack or not.
> 
> I scanned over it before but I was not able to see if it was correct on
> first glance. I will look at it again.

Sounds good! Thanks :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
