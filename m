Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id EE201828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 11:49:34 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id mw1so13830873igb.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:49:34 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id m9si6259827ige.60.2016.01.15.08.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 08:49:34 -0800 (PST)
Date: Fri, 15 Jan 2016 10:49:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
In-Reply-To: <20160115091051.03715530@redhat.com>
Message-ID: <alpine.DEB.2.20.1601151047420.2707@east.gentwo.org>
References: <yq14meiye92.fsf@sermon.lab.mkp.net> <20160115091051.03715530@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Jan 2016, Jesper Dangaard Brouer wrote:

> I've over the last year optimized the SLAB+SLUB allocators,
> specifically by introducing a bulking API.  This work is almost
> complete, but I have some more ideas in the MM-area that I would like
> to discuss with people.

I think this is pretty good work which can help a lot for subsystems
dealing with large amounts of objects. Given that network speeds and
memory increases we may have to look increasingly at bulk allocation to
make further strides in MM performance by rewriting subsystems to take
advantage of these features.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
