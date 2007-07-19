Received: by an-out-0708.google.com with SMTP id d33so145766and
        for <linux-mm@kvack.org>; Thu, 19 Jul 2007 07:10:26 -0700 (PDT)
Message-ID: <44c63dc40707190710rcd97947jbb044cb22c73f11b@mail.gmail.com>
Date: Thu, 19 Jul 2007 23:10:26 +0900
From: barrios <barrioskmc@gmail.com>
Subject: __pdflush have an unnecessary code ?
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

When pdflush kernel thread is died, Why do it store current jiffies in
when_i_went_to_sleep variable ?
IMHO, __pdflush function have an unnecessary code although it is trivial.
If my thought is wrong, please give me a answer.

---
 mm/pdflush.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/pdflush.c b/mm/pdflush.c
index 8f6ee07..96aa1da 100644
--- a/mm/pdflush.c
+++ b/mm/pdflush.c
@@ -153,7 +153,6 @@ static int __pdflush(struct pdflush_work *my_work)
                pdf = list_entry(pdflush_list.prev, struct pdflush_work, list);
                if (jiffies - pdf->when_i_went_to_sleep > 1 * HZ) {
                        /* Limit exit rate */
-                       pdf->when_i_went_to_sleep = jiffies;
                        break;                                  /* exeunt */
                }
        }
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
