Date: Wed, 15 Mar 2006 10:14:02 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
Message-Id: <20060315101402.3b19330c.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
	<20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
	<1142270857.5210.50.camel@localhost.localdomain>
	<Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
	<44183B64.3050701@argo.co.il>
	<20060315095426.b70026b8.pj@sgi.com>
	<Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: avi@argo.co.il, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> a page if a certain mapcount is reached.

He said "accessed", not "referenced".

The point was to copy pages that receive many
load and store instructions from far away nodes.

This has only minimal to do with the number of
memory address spaces mapping the region
holding that page.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
