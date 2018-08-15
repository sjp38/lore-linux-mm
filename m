Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA566B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:35:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l16-v6so209108edq.18
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 23:35:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b50-v6si5523927eda.285.2018.08.14.23.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 23:34:59 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7F6Y5E8039640
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:34:58 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kve13aa9m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:34:58 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 15 Aug 2018 07:34:56 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: 
Date: Wed, 15 Aug 2018 09:34:47 +0300
Message-Id: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Hi@d06av22.portsmouth.uk.ibm.com, Mike Rapoport <rppt@linux.vnet.ibm.com>

As Vlastimil mentioned at [1], it would be nice to have some guide about
memory allocation. I've drafted an initial version that tries to summarize
"best practices" for allocation functions and GFP usage.

[1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
