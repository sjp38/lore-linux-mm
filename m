Message-Id: <20080221205525.165641000@menage.corp.google.com>
References: <20080221203518.544461000@menage.corp.google.com>
Date: Thu, 21 Feb 2008 12:35:19 -0800
From: menage@google.com
Subject: [PATCH 1/2] ResCounter: Add res_counter_read_uint()
Content-Disposition: inline; filename=resource_counter_read_uint.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, xemul@openvz.org, balbir@in.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adds a function for returning the value of a resource counter member,
in a form suitable for use in a cgroup read_uint control file method.

Signed-off-by: Paul Menage <menage@google.com>

---
 include/linux/res_counter.h |    1 +
 kernel/res_counter.c        |    5 +++++
 2 files changed, 6 insertions(+)

Index: rescounter-2.6.25-rc2-mm1/include/linux/res_counter.h
===================================================================
--- rescounter-2.6.25-rc2-mm1.orig/include/linux/res_counter.h
+++ rescounter-2.6.25-rc2-mm1/include/linux/res_counter.h
@@ -54,6 +54,7 @@ struct res_counter {
 ssize_t res_counter_read(struct res_counter *counter, int member,
 		const char __user *buf, size_t nbytes, loff_t *pos,
 		int (*read_strategy)(unsigned long long val, char *s));
+u64 res_counter_read_uint(struct res_counter *counter, int member);
 ssize_t res_counter_write(struct res_counter *counter, int member,
 		const char __user *buf, size_t nbytes, loff_t *pos,
 		int (*write_strategy)(char *buf, unsigned long long *val));
Index: rescounter-2.6.25-rc2-mm1/kernel/res_counter.c
===================================================================
--- rescounter-2.6.25-rc2-mm1.orig/kernel/res_counter.c
+++ rescounter-2.6.25-rc2-mm1/kernel/res_counter.c
@@ -92,6 +92,11 @@ ssize_t res_counter_read(struct res_coun
 			pos, buf, s - buf);
 }
 
+u64 res_counter_read_uint(struct res_counter *counter, int member)
+{
+	return *res_counter_member(counter, member);
+}
+
 ssize_t res_counter_write(struct res_counter *counter, int member,
 		const char __user *userbuf, size_t nbytes, loff_t *pos,
 		int (*write_strategy)(char *st_buf, unsigned long long *val))

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
