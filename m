Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 98F2C6B008C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:29:49 -0400 (EDT)
Received: by widdi4 with SMTP id di4so147242968wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:29:49 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id dd10si18844670wib.30.2015.04.28.09.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 09:29:48 -0700 (PDT)
Received: by widdi4 with SMTP id di4so147242095wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:29:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADUS3okfhfT3a4gQ7pOKWvLvzoB6Y80EAZe7sh3XT_h3oi5+2Q@mail.gmail.com>
References: <CADUS3okfhfT3a4gQ7pOKWvLvzoB6Y80EAZe7sh3XT_h3oi5+2Q@mail.gmail.com>
Date: Wed, 29 Apr 2015 00:29:47 +0800
Message-ID: <CADUS3onYDQcqniBX_--1a_kmu0=+1GmC92JtBM+wvJp0xuUP8Q@mail.gmail.com>
Subject: Fwd: about memory zone usage
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi all:
in buddy allocator heart function, __alloc_pages_nodemask, I found we
use zonelist-> _zonerefs to iterate all the zone in NUMA or UMA.

My questions are:
1. the advantage of travelling  zonelist-> _zonerefs instead of
iterating zones on each node is because it is faster, right?
2. zonelist-> _zonerefs has recorded information of each zone, under
what circumstances we will iterated zone of node to get zone's data
instead of  zonelist-> _zonerefs

appreciate your help in advance,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
