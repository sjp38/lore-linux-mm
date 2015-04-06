Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AA7966B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:34:55 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so53448869pab.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:34:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v11si7942639pdi.29.2015.04.06.12.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:34:54 -0700 (PDT)
Date: Mon, 6 Apr 2015 12:34:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v7 1/2] mm: prototype: rid swapoff of quadratic complexity
Message-Id: <20150406123452.70ed80c810f1b7e9529b2055@linux-foundation.org>
In-Reply-To: <5522D582.8070408@redhat.com>
References: <20150319105515.GA8140@kelleynnn-virtual-machine>
	<5522D582.8070408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Kelley Nielsen <kelleynnn@gmail.com>, linux-mm@kvack.org, riel@surriel.com, opw-kernel@googlegroups.com, hughd@google.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On Mon, 06 Apr 2015 14:50:42 -0400 Rik van Riel <riel@redhat.com> wrote:

> > * Handle count of unused pages for frontswap.
> >
> > Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>
> 
> Looks good to me.

yup.  These patches are in Hugh's in-tray ;) While that's happening, I
guess we can get them into -next for testing.

Kelley, could you please address Rik's questions, gather up the acks,
refresh and resend?  Shortly after the 4.1 release would be a good time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
