From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 18/18] Fakekey: Simplify speakup_fake_key_pressed through this_cpu_ops
Date: Tue, 30 Nov 2010 13:07:25 -0600
Message-ID: <20101130190851.727701203@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=this_cpu_fake_key
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, William Hubbs <w.d.hubbs@gmail.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

The whole function can be expressed as a simple this_cpu_read() operation.
The function overhead is now likely multiple times that of the single
instruction that is executed in it.

Cc: William Hubbs <w.d.hubbs@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 drivers/staging/speakup/fakekey.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

Index: linux-2.6/drivers/staging/speakup/fakekey.c
===================================================================
--- linux-2.6.orig/drivers/staging/speakup/fakekey.c	2010-11-30 12:10:12.000000000 -0600
+++ linux-2.6/drivers/staging/speakup/fakekey.c	2010-11-30 12:14:12.000000000 -0600
@@ -96,10 +96,5 @@ void speakup_fake_down_arrow(void)
 	 */
 bool speakup_fake_key_pressed(void)
 {
-	bool is_pressed;
-
-	is_pressed = get_cpu_var(reporting_keystroke);
-	put_cpu_var(reporting_keystroke);
-
-	return is_pressed;
+	return this_cpu_read(reporting_keystroke);
 }
