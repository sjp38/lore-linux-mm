Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF156B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 18:15:36 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id hn15so5468906igb.16
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 15:15:36 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id bk8si13867868icc.59.2014.09.23.15.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 15:15:35 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id a13so5482712igq.5
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 15:15:34 -0700 (PDT)
Date: Tue, 23 Sep 2014 15:15:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: build error in dump_mm without CONFIG_COMPACTION
In-Reply-To: <1411440855-27430-1-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.02.1409231515130.22630@chino.kir.corp.google.com>
References: <1411440855-27430-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linuxfoundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 22 Sep 2014, Sasha Levin wrote:

> In the case of CONFIG_NUMA_BALANCING set and CONFIG_COMPACTION isn't,
> we'd fail to put a "," at the end of the formatting string and cause
> a build failure.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Looks like this is being addressed in http://marc.info/?t=141146436200007.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
