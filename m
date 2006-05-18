Date: Thu, 18 May 2006 11:21:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC] page migration: patches for later than 2.6.18
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This a selection of patches on top of 2.6.17-rc4-mm1 that may
address additional requirements such as

- Automatic page migration from user space.
- Support for migration memory that has no page_structs.
- Move pages to the correct pages in memory areas with
  MPOL_INTERLEAVE policy.

Plus it does a significant cleanup of the code. All of these
patches will require additional feedback before they can get in.
If any of this code gets in then probably later than 2.6.18.

A test program for page based migration may be found with the patches
on ftp.kernel.org:/pub/linux/kernel/christoph/pmig/patches-2.6.17-rc4-mm1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
