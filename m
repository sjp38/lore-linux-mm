Message-Id: <20070726172504.415412586@chello.nl>
Date: Thu, 26 Jul 2007 19:25:04 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/2] refaults
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, riel@redhat.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi,

This is a brush up of the refault patches, as presented by Rik at last
year's OLS:

  http://people.redhat.com/riel/riel-OLS2006.pdf

When talking to people at OLS this year there was a renewed interrest in
the concept.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
