Date: Tue, 29 Jan 2008 19:46:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] SLUB: Fix sysfs refcounting
Message-ID: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

This patch is needed for correct sysfs operation in slub.
