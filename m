Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3CC6B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:10:47 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so13628196qeb.31
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:47 -0800 (PST)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id h17si34330489qej.41.2013.12.02.13.10.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 13:10:46 -0800 (PST)
Received: by mail-qa0-f51.google.com with SMTP id o15so4969682qap.3
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:46 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH] - auditing cmdline
Date: Mon,  2 Dec 2013 13:10:36 -0800
Message-Id: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk
Cc: sds@tycho.nsa.gov

This patch series relates to work started on the audit mailing list.
It eventually involved touching other modules, so I am trying to
pull in those owners as well. In a nutshell I add new utility
functions for accessing a processes cmdline value as displayed
in proc/<self>/cmdline, and then refactor procfs to use the
utility functions, and then add the ability to the audit subsystem
to record this value.

Thanks for any feedback and help.

[PATCH 1/3] mm: Create utility functions for accessing a tasks
[PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
[PATCH 3/3] audit: Audit proc cmdline value

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
