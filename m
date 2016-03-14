Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id A33EF6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:05:09 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id k12so12568456lbb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:05:09 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id 5si10871027lfd.183.2016.03.14.09.05.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Mar 2016 09:05:08 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1afUzS-0001xy-6L
	for linux-mm@kvack.org; Mon, 14 Mar 2016 17:05:06 +0100
Received: from proxy-s2.lanl.gov ([192.12.184.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:05:06 +0100
Received: from hugegreenbug by proxy-s2.lanl.gov with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:05:06 +0100
From: Hugh Greenberg <hugegreenbug@gmail.com>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Date: Mon, 14 Mar 2016 16:00:43 +0000 (UTC)
Message-ID: <loom.20160314T165911-584@post.gmane.org>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com> <20160121161656.GA16564@node.shutemov.name> <loom.20160123T165232-709@post.gmane.org> <20160125103853.GD11095@node.shutemov.name> <loom.20160125T174557-678@post.gmane.org> <20160202135950.GA5026@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Kirill A. Shutemov <kirill <at> shutemov.name> writes:


> In the bugzilla[1], you've mentioned zram. I wounder if we need to
> increase min_free_kbytes when zram is in use as we do for THP.
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=110501
> 

We've tried increasing the min_free_kbytes. It may help for a time, 
but then the issue returns.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
