Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id A60496B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:26:38 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so4491260pbc.40
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:26:37 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1307291511020.29771@chino.kir.corp.google.com>
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com> <alpine.DEB.2.02.1307291511020.29771@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----5DH60NOZLVSVISDZZB1G5WQONMJ8LF"
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
From: zhouxinxing <xinxing2zhou@gmail.com>
Date: Tue, 30 Jul 2013 06:26:58 +0800
Message-ID: <f529c247-704e-4e3a-bb57-888141808eeb@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, SeungHun Lee <waydi1@gmail.com>
Cc: linux-mm@kvack.org

------5DH60NOZLVSVISDZZB1G5WQONMJ8LF
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit

unlikely indeed makes this code more elegant, however, it's difficult to tell how much the performance will be improved.

David Rientjes <rientjes@google.com> wrote:

>On Sun, 28 Jul 2013, SeungHun Lee wrote:
>
>> "order >= MAX_ORDER" case is occur rarely.
>> 
>> So I add unlikely for this check.
>
>This needs your signed-off-by line.
>
>When that's done:
>
>Acked-by: David Rientjes <rientjes@google.com>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Sent from my Android device with Gmail Plus. Please excuse my brevity.
------5DH60NOZLVSVISDZZB1G5WQONMJ8LF
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head/><body><html><head></head><body>unlikely indeed makes this code more elegant, however, it&#39;s difficult to tell how much the performance will be improved.<br><br><div class="gmail_quote">David Rientjes &lt;rientjes@google.com&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<pre style="white-space: pre-wrap; word-wrap:break-word; font-family: sans-serif; margin-top: 0px">On Sun, 28 Jul 2013, SeungHun Lee wrote:<br /><br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #729fcf; padding-left: 1ex;">"order &gt;= MAX_ORDER" case is occur rarely.<br /><br />So I add unlikely for this check.</blockquote><br />This needs your signed-off-by line.<br /><br />When that's done:<br /><br />Acked-by: David Rientjes &lt;rientjes@google.com&gt;<br /><br />--<br />To unsubscribe, send a message with 'unsubscribe linux-mm' in<br />the body to majordomo@kvack.org.  For more info on Linux MM,<br />see: <a href="http://www.linux-mm.org">http://www.linux-mm.org</a>/ .<br />Don't email: &lt;a href=mailto:"dont@kvack.org"&gt; email@kvack.org &lt;/a&gt;<br /></pre></blockquote></div><br>
-- <br>
Sent from my Android device with Gmail Plus. Please excuse my brevity.</body></html></body></html>
------5DH60NOZLVSVISDZZB1G5WQONMJ8LF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
