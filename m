Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26B0E6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:44:49 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j15so10798545wre.15
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 01:44:49 -0800 (PST)
Received: from mout02.posteo.de (mout02.posteo.de. [185.67.36.66])
        by mx.google.com with ESMTPS id p16si8882911wre.553.2017.11.14.01.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 01:44:47 -0800 (PST)
Received: from submission (posteo.de [89.146.220.130])
	by mout02.posteo.de (Postfix) with ESMTPS id 78DA6209F8
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:44:47 +0100 (CET)
From: Martin Kepplinger <martink@posteo.de>
Subject: [PATCH] mm: replace FSF address with web source in license notices
Date: Tue, 14 Nov 2017 10:44:38 +0100
Message-Id: <20171114094438.28224-1-martink@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Kepplinger <martink@posteo.de>

A few years ago the FSF moved and "59 Temple Place" is wrong. Having this
still in our source files feels old and unmaintained.

Let's take the license statement serious and not confuse users.

As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace the
postal address with "<http://www.gnu.org/licenses/>" in the mm directory.

Signed-off-by: Martin Kepplinger <martink@posteo.de>
---
 mm/kmemleak-test.c | 3 +--
 mm/kmemleak.c      | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak-test.c b/mm/kmemleak-test.c
index dd3c23a801b1..9a13ad2c0cca 100644
--- a/mm/kmemleak-test.c
+++ b/mm/kmemleak-test.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
 #define pr_fmt(fmt) "kmemleak: " fmt
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e4738d5e9b8c..e6d6d3c9f543 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  *
  * For more information on the algorithm and kmemleak usage, please see
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
