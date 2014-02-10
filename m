Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D19CD6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:56:03 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm4so3096316wib.1
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:56:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id iy12si7190078wic.81.2014.02.10.09.56.00
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 09:56:02 -0800 (PST)
Date: Mon, 10 Feb 2014 12:55:44 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140210125544.30edd38b@redhat.com>
In-Reply-To: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 10 Feb 2014 12:27:44 -0500
Luiz Capitulino <lcapitulino@redhat.com> wrote:

> The hugepagesnid= option introduced by this commit allows the user
> to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> from node 0 only. More details on patch 3/4 and patch 4/4.

s/2G/1G

I repeatedly did this mistake even when testing... For some reason my
brain insists on typing "2,2G" instead of "2,1G".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
