Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B502A6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:37:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so4902047wmg.8
        for <linux-mm@kvack.org>; Tue, 29 May 2018 04:37:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m23-v6si2927680edd.448.2018.05.29.04.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 04:37:37 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4TBYVjL008727
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:37:34 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j93kqq1d0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:37:34 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 29 May 2018 12:37:31 +0100
Date: Tue, 29 May 2018 14:37:25 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] docs/admin-guide/mm: add high level concepts overview
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20180529113725.GB13092@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

The below patch describes some of the concepts in Linux mm. It does not aim
to provide in-depth description of the mm internals, but rather help
unprepared reader to understand cryptic texts, e.g.
Documentation/sysctl/vm.txt.

I covered what seemed to me the essential minimum that is required for
user/administrator to read the existing docs without searching the web for
the explanations for every other term.

--
Sincerely yours,
Mike.
