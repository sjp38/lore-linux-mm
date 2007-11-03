Date: Sat, 3 Nov 2007 18:56:43 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 5/10] use an indexed array for LRU lists and variables
Message-ID: <20071103185643.39c1fc9a@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use an indexed array for LRU variables.  This makes the rest
of the split VM code a lot cleaner.

V1 -> V2 [lts]:
+ Remove extraneous  __dec_zone_state(zone, NR_ACTIVE) pointed
  out by Mel G.
