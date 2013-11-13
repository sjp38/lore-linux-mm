Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 17A446B00A3
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 07:09:55 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id q10so324010pdj.29
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 04:09:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id sr5si1398929pab.34.2013.11.13.04.09.52
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 04:09:53 -0800 (PST)
Received: by mail-lb0-f182.google.com with SMTP id w6so257949lbh.13
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 04:09:50 -0800 (PST)
Date: Wed, 13 Nov 2013 16:09:48 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
Message-ID: <20131113120948.GE2834@moon>
References: <20131024224326.GA19654@alpha.arachsys.com>
 <20131025103946.GA30649@alpha.arachsys.com>
 <20131028082825.GA30504@alpha.arachsys.com>
 <52836002.5050901@elastichosts.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52836002.5050901@elastichosts.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alin Dobre <alin.dobre@elastichosts.com>
Cc: linux-mm@kvack.org

On Wed, Nov 13, 2013 at 11:18:26AM +0000, Alin Dobre wrote:
> 
> The above traces seem similar with the ones that were reported by
> Dave couple of months ago in the LKML thread
> https://lkml.org/lkml/2013/8/7/27.
> 
> Any further thoughts on why this happens?

Dave's report has been addressed in commit 6dec97dc9, which is
in 3.11, also you're to have CONFIG_MEM_SOFT_DIRTY=y to trigger
it in former case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
