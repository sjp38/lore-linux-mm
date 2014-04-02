Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC7C16B0122
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 18:15:14 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id v15so95583bkz.33
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 15:15:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mb3si1646069bkb.131.2014.04.02.15.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 15:15:13 -0700 (PDT)
Date: Wed, 2 Apr 2014 23:15:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Suggestion, "public process scoped interfaces"
Message-ID: <20140402221508.GB1869@suse.de>
References: <fa9ecac225ee2.533c5ee6@langara.bc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <fa9ecac225ee2.533c5ee6@langara.bc.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Stewart-Gallus <sstewartgallus00@mylangara.bc.ca>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyeoh@au1.ibm.com

On Wed, Apr 02, 2014 at 07:03:02PM +0000, Steven Stewart-Gallus wrote:
> Hello,
> 
> I have been reconsidering requirements and solutions brought up in my
> post "How about allowing processes to expose memory for cross memory
> attaching?".

commit fcf634098c00dd9cd247447368495f0b79be12d1

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
