Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF4A6B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 20:49:04 -0400 (EDT)
Received: by patj18 with SMTP id j18so96251545pat.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 17:49:03 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id zp6si1433694pbc.127.2015.04.07.17.49.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 17:49:03 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so95896946pac.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 17:49:02 -0700 (PDT)
Received: from frank-02.cumulusnetworks.com ([216.129.126.126])
        by mx.google.com with ESMTPSA id oh2sm5203113pbb.45.2015.04.07.17.49.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 17:49:00 -0700 (PDT)
From: smtpauth@cumulusnetworks.com
Received: from jenkins-01.cumulusnetworks.com (localhost [IPv6:::1])
	by frank-02.cumulusnetworks.com (Postfix) with ESMTP id 50E7A156002E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:48:59 -0700 (PDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: Please resolve File Modified on merge for
 patches/kernel/kernel-nowarn-sysctl.patch
Message-Id: <20150408004859.50E7A156002E@frank-02.cumulusnetworks.com>
Date: Tue,  7 Apr 2015 17:48:59 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, shm@cumulusnetworks.com, curt@cumulusnetworks.com, nolan@cumulusnetworks.com, sfeldma@cumulusnetworks.com

This is automated email to inform you about source code difference
between releases CumulusLinux-2.5_br and CumulusLinux-2.6_br .

Please continue this email thread to decide how to proceed with these changes.
If multiple committers are identified for this file, please elect or self-elect an owner of the merge action. 
Execute and commit the merge and reply on this email modifying the subject with <CLOSING> prefix.

When a moderator receives this closing email, the corresponding status entry for this file will be deleted as completed.
If no closing email is sent, the reminder email will be triggered again for duration of a week from the original request.
After one week of inactivity the moderator declares that merge for this file is not needed and no further actions required to sync these branches.

Please execute following steps to replicate the git merge environment

git clone ssh://<your name>@dev.cumulusnetworks.com/home/trac/cumulus.git --branch CumulusLinux-2.5_br
git checkout CumulusLinux-2.6_br
git merge CumulusLinux-2.5_br
git status

*
*
*

4c4
< index 313381c..de7701d 100644
---
> index ab98dc6..f206e4b 100644
7c7
< @@ -3493,7 +3493,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
---
> @@ -3496,7 +3496,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
