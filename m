Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8836B0096
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 12:22:38 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 08 Oct 2009 12:26:43 -0400
Message-Id: <20091008162643.23192.65918.sendpatchset@localhost.localdomain>
In-Reply-To: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
Subject: [PATCH 10/12] mm: clear node in N_HIGH_MEMORY and stop kswapd when all memory is offlined
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

