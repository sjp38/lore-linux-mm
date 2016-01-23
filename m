Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5F46B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 11:00:07 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id m198so63259975lfm.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 08:00:07 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id l76si5352420lfe.241.2016.01.23.08.00.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 08:00:05 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1aN0bc-0006WZ-4y
	for linux-mm@kvack.org; Sat, 23 Jan 2016 17:00:04 +0100
Received: from host.my-tss.com ([host.my-tss.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 17:00:04 +0100
Received: from hugh by host.my-tss.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 17:00:04 +0100
From: Hugh Greenberg <hugh@galliumos.org>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Date: Sat, 23 Jan 2016 15:57:21 +0000 (UTC)
Message-ID: <loom.20160123T165232-709@post.gmane.org>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com> <20160121161656.GA16564@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> 
> Could you try to insert "late_initcall(set_recommended_min_free_kbytes);"
> back and check if makes any difference.
> 

We tested adding late_initcall(set_recommended_min_free_kbytes); 
back in 4.1.14 and it made a huge difference. We aren't sure if the
issue is 100% fixed, but it could be. We will keep testing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
