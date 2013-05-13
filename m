Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 59F3E6B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 09:49:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 May 2013 23:43:42 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0D15A2CE804C
	for <linux-mm@kvack.org>; Mon, 13 May 2013 23:49:01 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DDYrCl24117330
	for <linux-mm@kvack.org>; Mon, 13 May 2013 23:34:54 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DDmxWI032284
	for <linux-mm@kvack.org>; Mon, 13 May 2013 23:48:59 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t pointer
In-Reply-To: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Mon, 13 May 2013 19:18:57 +0530
Message-ID: <871u9b56t2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com


updated one fixing a compile warning.
