Message-ID: <3AB9313C.1020909@missioncriticallinux.com>
Date: Wed, 21 Mar 2001 17:54:52 -0500
From: "Patrick O'Rourke" <orourke@missioncriticallinux.com>
MIME-Version: 1.0
Subject: [PATCH] Prevent OOM from killing init
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Since the system will panic if the init process is chosen by
the OOM killer, the following patch prevents select_bad_process()
from picking init.

Pat

--- xxx/linux-2.4.3-pre6/mm/oom_kill.c  Tue Nov 14 13:56:46 2000
+++ linux-2.4.3-pre6/mm/oom_kill.c      Wed Mar 21 15:25:03 2001
@@ -123,7 +123,7 @@

         read_lock(&tasklist_lock);
         for_each_task(p) {
-               if (p->pid) {
+               if (p->pid && p->pid != 1) {
                         int points = badness(p);
                         if (points > maxpoints) {
                                 chosen = p;

-- 
Patrick O'Rourke
978.606.0236
orourke@missioncriticallinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
