Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 2AEC56B0044
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 14:07:52 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1981033bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 11:07:50 -0700 (PDT)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [PATCH 0/2] mm/acpi hotplug fixes for hot-remove
Date: Thu,  5 Apr 2012 20:07:00 +0200
Message-Id: <1333649222-24285-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

On memory hot-remove, the acpi_memhotplug driver currently offlines memory but
does not remove section mappings and sysfs entries. Additionally, memory
resource registration is done inconsistently on hot-add and hot-remove. This
series attempts to address the 2 issues.

(Note that testing memory hot-remove with SPARSEMEM_VMEMMAP=y will currently
fail, since freeing the sparse_vmemmap is not yet supported.)

Vasilis Liaskovitis (2):
  acpi: remove section mappings on memory hot-remove
  mm: consistently register / release memory resource

 drivers/acpi/acpi_memhotplug.c |   17 ++++++++++++++++-
 mm/memory_hotplug.c            |    4 ++--
 2 files changed, 18 insertions(+), 3 deletions(-)

-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
