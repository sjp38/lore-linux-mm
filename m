Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 354586B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:10:08 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id oe12so9229888lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:10:08 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id m4si10878937lfd.107.2016.03.14.09.10.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Mar 2016 09:10:06 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1afV4F-0005v5-U0
	for linux-mm@kvack.org; Mon, 14 Mar 2016 17:10:04 +0100
Received: from proxy-s2.lanl.gov ([192.12.184.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:10:03 +0100
Received: from hugegreenbug by proxy-s2.lanl.gov with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:10:03 +0100
From: Hugh Greenberg <hugegreenbug@gmail.com>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Date: Mon, 14 Mar 2016 16:07:24 +0000 (UTC)
Message-ID: <loom.20160314T170548-176@post.gmane.org>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com> <20160121161656.GA16564@node.shutemov.name> <loom.20160123T165232-709@post.gmane.org> <20160125103853.GD11095@node.shutemov.name> <loom.20160125T174557-678@post.gmane.org> <20160202135950.GA5026@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

A lot of users are still reporting the issue. 
The bugzilla report has some new information.
https://bugzilla.kernel.org/show_bug.cgi?id=110501
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
