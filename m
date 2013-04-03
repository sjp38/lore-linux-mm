Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BD1E76B0087
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 22:54:47 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hechjie@cn.ibm.com>;
	Wed, 3 Apr 2013 08:21:04 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id D5EFE394002D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 08:24:39 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r332saSc4850158
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 08:24:36 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r332sd33023481
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 13:54:39 +1100
In-Reply-To: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <OFDD089DC3.D9A0310D-ON48257B42.000F1838-48257B42.000FFCA2@cn.ibm.com>
From: Cheng Jie He <hechjie@cn.ibm.com>
Date: Wed, 3 Apr 2013 10:46:27 +0800
MIME-Version: 1.0
Content-type: multipart/alternative;
	Boundary="0__=C7BBF1D1DF9C9EA88f9e8a93df938690918cC7BBF1D1DF9C9EA8"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: hpa@zytor.com, kamaleshb@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, oleg@redhat.com, tglx@linutronix.de, x86@kernel.org

--0__=C7BBF1D1DF9C9EA88f9e8a93df938690918cC7BBF1D1DF9C9EA8
Content-type: text/plain; charset=US-ASCII



Frantisek Hrbata <fhrbata@redhat.com> wrote on 04/02/2013 08:28:53 PM:

 ..snip...

>
> Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>

Signed-off-by: Chengjie He <hechjie@cn.ibm.com>

> ---
>  arch/x86/include/asm/io.h |  4 ++++
>  arch/x86/mm/mmap.c        | 13 +++++++++++++
>  2 files changed, 17 insertions(+)
>
> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index d8e8eef..39607c6 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -242,6 +242,10 @@ static inline void flush_write_buffers(void)
>  #endif
..snip...
--0__=C7BBF1D1DF9C9EA88f9e8a93df938690918cC7BBF1D1DF9C9EA8
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt><font size="2">Frantisek Hrbata &lt;fhrbata@redhat.com&gt; wrote on 04/02/2013 08:28:53 PM:<br>
<br>
 ..snip...</font></tt><br>
<tt><font size="2"><br>
&gt; <br>
&gt; Signed-off-by: Frantisek Hrbata &lt;fhrbata@redhat.com&gt;</font></tt><br>
<br>
<tt><font size="2">Signed-off-by: Chengjie He &lt;hechjie@cn.ibm.com&gt;</font></tt><br>
<tt><font size="2"><br>
&gt; ---<br>
&gt; &nbsp;arch/x86/include/asm/io.h | &nbsp;4 ++++<br>
&gt; &nbsp;arch/x86/mm/mmap.c &nbsp; &nbsp; &nbsp; &nbsp;| 13 +++++++++++++<br>
&gt; &nbsp;2 files changed, 17 insertions(+)<br>
&gt; <br>
&gt; diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h<br>
&gt; index d8e8eef..39607c6 100644<br>
&gt; --- a/arch/x86/include/asm/io.h<br>
&gt; +++ b/arch/x86/include/asm/io.h<br>
&gt; @@ -242,6 +242,10 @@ static inline void flush_write_buffers(void)<br>
&gt; &nbsp;#endif<br>
..snip...</font></tt></body></html>
--0__=C7BBF1D1DF9C9EA88f9e8a93df938690918cC7BBF1D1DF9C9EA8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
