Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 798AC6B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:35:29 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id i35so8159270ote.12
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 07:35:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o5si2369945oth.344.2018.01.10.07.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 07:35:28 -0800 (PST)
Date: Wed, 10 Jan 2018 10:35:10 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com>
In-Reply-To: <1243932888.5206621.1515594158029.JavaMail.zimbra@redhat.com>
Subject: migrate_pages() of process with same UID in 4.15-rcX
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: otto ebeling <otto.ebeling@iki.fi>, mhocko@suse.com, mtk manpages <mtk.manpages@gmail.com>
Cc: linux-mm@kvack.org, clameter@sgi.com, ebiederm@xmission.com, w@1wt.eu, keescook@chromium.org, ltp@lists.linux.it

Hi,

LTP test migrate_pages02 [1] is failing with 4.15-rcX, presumably as
consequence of:
  313674661925 "Unify migrate_pages and move_pages access checks"

The scenario is that privileged parent forks child, both parent
and child change euid to nobody and then parent tries to migrate
child to different node. Starting with 4.15-rcX it fails with EPERM.

Can anyone comment on accuracy of this sentence from man-pages
after commit 313674661925?

quoting man2/migrate_pages.2:
 "To move pages in another process, the caller must be privileged
 (CAP_SYS_NICE) or the real or effective user ID of the calling 
 process must match the real or saved-set user ID of the target
 process."

Thanks,
Jan

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages02.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
