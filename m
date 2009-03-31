Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF98A6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:43:43 -0400 (EDT)
Received: from smtp4-g21.free.fr (localhost [127.0.0.1])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 32D9C4C8042
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 22:44:16 +0200 (CEST)
Received: from [192.168.0.50] (lns-bzn-57-82-249-54-59.adsl.proxad.net [82.249.54.59])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 3C51D4C811D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 22:44:14 +0200 (CEST)
From: Francois - kml <fckernml@free.fr>
Subject: Migrating SYSV Limits to rlimit ?
Date: Tue, 31 Mar 2009 22:44:13 +0200
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200903312244.13687.fckernml@free.fr>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Most distros sets their own shmmax/shmall values.
DB admins wants and usually sets large values for their processes.
Global limits means there's no guarantee, except the upper limit.

So I'm currently working on a patch moving sysv shm limits to rlimit, which 
would allow a finer grained tuning. Currently:
- Lower by default shmmax/shmall values (at least the mainline ones)
- Allow raising those limits through sysctl, privilegied /proc access or 
setrlimit w/CAP_SYS_RESOURCE
- Limit resources by user with the user accounting struct
- Set the initial values through Kconfig
- Bind of sysctl modifications to init's rlimit hard values

I'm looking for comments.
Is that something that could interest a specific branch ?

Refs: Bugzilla Bug 11381
Some discussion about it:
http://marc.info/?t=112315565600001&r=1&w=2

Francois

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
