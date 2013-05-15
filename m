Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id CD7026B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:48:18 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id t12so2148pdi.30
        for <linux-mm@kvack.org>; Wed, 15 May 2013 14:48:18 -0700 (PDT)
Date: Wed, 15 May 2013 14:48:13 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] workqueue: don't perform NUMA-aware allocations on offline
 nodes in wq_numa_init()
Message-ID: <20130515214813.GF26222@htj.dyndns.org>
References: <22600323.7586117.1367826906910.JavaMail.root@redhat.com>
 <5191B101.1070000@redhat.com>
 <20130514183500.GN6795@mtj.dyndns.org>
 <51930FCD.3090001@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51930FCD.3090001@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lingzhu Xiang <lxiang@redhat.com>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

