Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id C85CA6B0253
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:09:13 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id e32so56803746qgf.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 05:09:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i1si7094096qkh.31.2016.01.22.05.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 05:09:13 -0800 (PST)
Date: Fri, 22 Jan 2016 08:09:11 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Persistent Memory Error Handling
Message-ID: <20160122130910.GA28642@bfoster.bfoster>
References: <x49oacee71h.fsf@segfault.boston.devel.redhat.com>
 <56A20A26.1070104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A20A26.1070104@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 22, 2016 at 05:53:26AM -0500, Ric Wheeler wrote:
> On 01/21/2016 08:28 PM, Jeff Moyer wrote:
> >Hi,
> >
> >The SNIA Non-volatile Memory Programming Technical Work Group (NVMP-TWG)
> >is working on more closely defining how errors are reported and
> >cleared for persistent memory.  I'd like to give an overview of that
> >work and open the floor to discussion.  This topic covers file systems,
> >memory management, and the block layer so would be suitable for a
> >plenary session.
> >
> >Thanks,
> >Jeff
> >
> 
> Great topic, very interesting to me as well,
> 

Ditto... along with understanding of the error management mechanism, I'd
like to understand the expectations around at what layer errors should
be handled for what configurations. E.g., my understanding is that while
btt handles this internally and returns an error a la traditional
storage, the story is different for pmem and the expectation is for some
kind of filesystem involvement...

Brian

> ric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
