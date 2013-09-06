Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 988C46B0039
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:58:36 -0400 (EDT)
Date: Fri, 6 Sep 2013 14:58:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/4] slab: implement byte sized indexes for the freelist
 of a slab
Message-ID: <20130906055838.GA6015@lge.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
 <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140e42dcd61-00e6cf6a-457c-48bd-8bf7-830133923564-000000@email.amazonses.com>
 <20130904083305.GC16355@lge.com>
 <20130905065552.GA6384@lge.com>
 <00000140ee8b386a-f9b8a845-58db-482e-8c63-20fb24404dc8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140ee8b386a-f9b8a845-58db-482e-8c63-20fb24404dc8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 05, 2013 at 02:33:56PM +0000, Christoph Lameter wrote:
> On Thu, 5 Sep 2013, Joonsoo Kim wrote:
> 
> > I think that all patchsets deserve to be merged, since it reduces memory usage and
> > also improves performance. :)
> 
> Could you clean things up etc and the repost the patchset? This time do
> *not* do this as a response to an earlier email but start the patchset
> with new thread id. I think some people are not seeing this patchset.

Okay. I just did that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
