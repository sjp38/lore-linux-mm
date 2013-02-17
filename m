Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8FB686B00C8
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 01:44:55 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wd20so4750939obb.37
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 22:44:54 -0800 (PST)
MIME-Version: 1.0
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 17 Feb 2013 01:44:33 -0500
Message-ID: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
Subject: [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Sorry for the delay.

I would like to discuss the following topics:



* Hugepage migration =96 Currently, hugepage is not migratable and can=92t
use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
view.

* Remove ZONE_MOVABLE =96Very long term goal. Maybe not suitable in this ye=
ar.

* Mempolicy rebinding rework =96 current mempolicy rebinding has a lot
of limitations.

  - no rebinding when hotplug

  - no rebinding when using shm memplicy

  - broken argument check when MPOL_DEFAULT

* Rework shared mempolicy =96 shared mempolicy don=92t work correctly when
attached from multiple processes. However shmem exist for inter
process  communication.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
