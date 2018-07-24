Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B01D86B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w12-v6so4131252oie.12
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:23:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t82-v6si7987639oif.341.2018.07.24.06.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:23:23 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6ODIdGv122085
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:23 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ke49wa0cc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:22 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 14:23:21 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/2] um: switch to NO_BOOTMEM
Date: Tue, 24 Jul 2018 16:23:12 +0300
Message-Id: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches convert UML to use NO_BOOTMEM.
Tested on x86-64.

Mike Rapoport (2):
  um: setup_physmem: stop using global variables
  um: switch to NO_BOOTMEM

 arch/um/Kconfig.common   |  2 ++
 arch/um/kernel/physmem.c | 22 ++++++++++------------
 2 files changed, 12 insertions(+), 12 deletions(-)

-- 
2.7.4
