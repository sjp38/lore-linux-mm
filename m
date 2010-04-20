Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 114C06B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 10:22:53 -0400 (EDT)
Subject: repost - RFC [Patch] Remove "please try 'cgroup_disable=memory'
	option if you don't want memory cgroups" printk at boot time.
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-H/O1OMvkVAiyyec34Fay"
Date: Tue, 20 Apr 2010 10:26:27 -0400
Message-Id: <1271773587.28748.134.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--=-H/O1OMvkVAiyyec34Fay
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Re-posting, cc'ing linux-mm as requested:

We are considering removing this printk at boot time from RHEL because
it will confuse customers, encourage them to change the boot parameters
and generate extraneous support calls.  Its documented in
Documentation/kernel-parameters.txt anyway.  Any thoughts???

Larry Woodman



--=-H/O1OMvkVAiyyec34Fay
Content-Disposition: attachment; filename=rhel6-cgroup.patch
Content-Type: text/x-patch; name=rhel6-cgroup.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 3d535d5..2029fae 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -83,8 +83,6 @@ void __init page_cgroup_init_flatmem(void)
 			goto fail;
 	}
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
-	" don't want memory cgroups\n");
 	return;
 fail:
 	printk(KERN_CRIT "allocation of page_cgroup failed.\n");

--=-H/O1OMvkVAiyyec34Fay--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
