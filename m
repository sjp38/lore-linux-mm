Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id D02246B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 11:48:57 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id g8so74079977igr.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 08:48:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n7si222876igj.18.2016.04.07.08.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 08:48:57 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160407143854.GA7685@infradead.org>
Date: Thu, 7 Apr 2016 08:48:15 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
References: <1460034425.20949.7.camel@HansenPartnership.com> <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>


> On Apr 7, 2016, at 7:38 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> This is also very interesting for storage targets, which face the same
> issue.  SCST has a mode where it caches some fully constructed SGLs,
> which is probably very similar to what NICs want to do.

+1 for NFS server.


--
Chuck Lever



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
