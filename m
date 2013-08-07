Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A0AE96B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 20:19:06 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1450151pad.33
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 17:19:05 -0700 (PDT)
In-Reply-To: <20130807000154.GA3507@z460>
References: <20130807000154.GA3507@z460>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----N00HUACV1W9UY64SK4X6964RZN431A"
Subject: Re: [PATCH] mm: numa: fix NULL pointer dereference
From: zhouxinxing <xinxing2zhou@gmail.com>
Date: Wed, 07 Aug 2013 08:19:22 +0800
Message-ID: <395f1269-2a31-44be-90ff-d2c470d64ca7@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Dreissig <mukadr@gmail.com>, linux-mm@kvack.org

------N00HUACV1W9UY64SK4X6964RZN431A
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit

Is it possible to check pol if it is equal to NULL prior to access to mode field?

Mauro Dreissig <mukadr@gmail.com> wrote:

>From: Mauro Dreissig <mukadr@gmail.com>
>
>The "pol->mode" field is accessed even when no mempolicy
>is assigned to the "pol" variable.
>
>Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
>---
> mm/mempolicy.c | 12 ++++++++----
> 1 file changed, 8 insertions(+), 4 deletions(-)
>
>diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>index 6b1d426..105fff0 100644
>--- a/mm/mempolicy.c
>+++ b/mm/mempolicy.c
>@@ -127,12 +127,16 @@ static struct mempolicy *get_task_policy(struct
>task_struct *p)
> 
> 	if (!pol) {
> 		node = numa_node_id();
>-		if (node != NUMA_NO_NODE)
>+		if (node != NUMA_NO_NODE) {
> 			pol = &preferred_node_policy[node];
> 
>-		/* preferred_node_policy is not initialised early in boot */
>-		if (!pol->mode)
>-			pol = NULL;
>+			/*
>+			 * preferred_node_policy is not initialised early
>+			 * in boot
>+			 */
>+			if (!pol->mode)
>+				pol = NULL;
>+		}
> 	}
> 
> 	return pol;
>-- 
>1.8.1.2
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Sent from my Android device with Gmail Plus. Please excuse my brevity.
------N00HUACV1W9UY64SK4X6964RZN431A
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head/><body><html><head></head><body>Is it possible to check pol if it is equal to NULL prior to access to mode field?<br><br><div class="gmail_quote">Mauro Dreissig &lt;mukadr@gmail.com&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<pre style="white-space: pre-wrap; word-wrap:break-word; font-family: sans-serif; margin-top: 0px">From: Mauro Dreissig &lt;mukadr@gmail.com&gt;<br /><br />The "pol-&gt;mode" field is accessed even when no mempolicy<br />is assigned to the "pol" variable.<br /><br />Signed-off-by: Mauro Dreissig &lt;mukadr@gmail.com&gt;<br />---<br />mm/mempolicy.c | 12 ++++++++----<br />1 file changed, 8 insertions(+), 4 deletions(-)<br /><br />diff --git a/mm/mempolicy.c b/mm/mempolicy.c<br />index 6b1d426..105fff0 100644<br />--- a/mm/mempolicy.c<br />+++ b/mm/mempolicy.c<br />@@ -127,12 +127,16 @@ static struct mempolicy *get_task_policy(struct task_struct *p)<br /><br /> if (!pol) {<br />  node = numa_node_id();<br />-  if (node != NUMA_NO_NODE)<br />+  if (node != NUMA_NO_NODE) {<br />   pol = &amp;preferred_node_policy[node];<br /><br />-  /* preferred_node_policy is not initialised early in boot */<br />-  if (!pol-&gt;mode)<br />-   pol = NULL;<br />+   /*<br />+    * preferred_node_policy
is not initialised early<br />+    * in boot<br />+    */<br />+   if (!pol-&gt;mode)<br />+    pol = NULL;<br />+  }<br /> }<br /><br /> return pol;</pre></blockquote></div><br>
-- <br>
Sent from my Android device with Gmail Plus. Please excuse my brevity.</body></html></body></html>
------N00HUACV1W9UY64SK4X6964RZN431A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
