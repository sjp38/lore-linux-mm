Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 016B76B006A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 15:08:34 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n5IJ8kil007791
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 20:08:47 +0100
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by zps75.corp.google.com with ESMTP id n5IJ8h0N028444
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:08:44 -0700
Received: by pxi2 with SMTP id 2so1156180pxi.6
        for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:08:43 -0700 (PDT)
Date: Thu, 18 Jun 2009 12:08:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] Free huge pages round robin to balance across
 nodes
In-Reply-To: <1245259018.6235.59.camel@lts-notebook>
Message-ID: <alpine.DEB.2.00.0906181208280.10979@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090616135236.25248.93692.sendpatchset@lts-notebook> <20090617131833.GG28529@csn.ul.ie> <1245259018.6235.59.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
