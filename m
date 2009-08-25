Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 25 Aug 2009 15:36:17 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: kvack.org dns outage
Message-ID: <20090825193617.GC25425@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

Sorry about the DNS outage for the past couple of days.  It was a combination 
of a bad glue record plus the secondary nameserver going offline.  I've fixed 
the glue records and added another nameserver to guard against the secondary 
failing again.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
