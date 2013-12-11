Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C414F6B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:10:28 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y10so6147894wgg.2
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:10:28 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id l6si2984410wix.62.2013.12.11.08.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 08:10:27 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id z2so7292044wiv.13
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:10:27 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 11 Dec 2013 08:10:27 -0800
Message-ID: <CAFftDdoyr1c91rOdh+M6hZKHi7ovkUvs7qeDDBwiaz1KD5tdmQ@mail.gmail.com>
Subject: [RFC] [PATCH] - auditing cmdline
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, Stephen Smalley <sds@tycho.nsa.gov>

all,

I sent out some patches a while back (12/2) that affect mm, procfs and
audit. The audit patch (PATCH 3/3) was ack'd on by Richard Guy Briggs.
But the other patches I have not heard anything on.

Patches:
[PATCH 1/3] mm: Create utility functions for accessing a tasks commandline value
[PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
[PATCH 3/3  audit: Audit proc cmdline value

Link to mailer archive:
https://www.mail-archive.com/search?l=linux-kernel@vger.kernel.org&q=from:%22William+Roberts%22

Thanks for any help.

-- 
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
