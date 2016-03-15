Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 06F646B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 13:16:12 -0400 (EDT)
Received: by mail-lf0-f53.google.com with SMTP id l83so631615lfd.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 10:16:11 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id g8si13368788lbc.141.2016.03.15.10.16.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Mar 2016 10:16:10 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1afsZl-0005jM-HY
	for linux-mm@kvack.org; Tue, 15 Mar 2016 18:16:09 +0100
Received: from proxy-s2.lanl.gov ([192.12.184.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 18:16:09 +0100
Received: from hugegreenbug by proxy-s2.lanl.gov with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 18:16:09 +0100
From: Hugh Greenberg <hugegreenbug@gmail.com>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Date: Tue, 15 Mar 2016 17:16:03 +0000 (UTC)
Message-ID: <loom.20160315T181525-644@post.gmane.org>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com> <20160121161656.GA16564@node.shutemov.name> <loom.20160123T165232-709@post.gmane.org> <20160125103853.GD11095@node.shutemov.name> <loom.20160125T174557-678@post.gmane.org> <20160202135950.GA5026@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

There is also another bug report for the same issue 
that has some good information: 
https://bugzilla.kernel.org/show_bug.cgi?id=65201

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
