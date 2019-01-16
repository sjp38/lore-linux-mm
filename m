Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82B0E8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:56:11 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id p4so5236777iod.17
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:56:11 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i42si4031461jaf.71.2019.01.16.09.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:56:10 -0800 (PST)
Subject: Re: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
 <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <97e179e1-8a3a-5acb-78c1-a4b06b33db4c@oracle.com>
Date: Wed, 16 Jan 2019 09:56:02 -0800
MIME-Version: 1.0
In-Reply-To: <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: multipart/alternative;
 boundary="------------26820907F7F7D3317A5CD494"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------26820907F7F7D3317A5CD494
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit

Hi, Naoya,

On 1/16/2019 1:30 AM, Naoya Horiguchi wrote:
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 7c72f2a95785..831be5ff5f4d 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -372,7 +372,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
>   			if (fail || tk->addr_valid == 0) {
>   				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
>   				       pfn, tk->tsk->comm, tk->tsk->pid);
> -				force_sig(SIGKILL, tk->tsk);
> +				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
> +						 tk->tsk, PIDTYPE_PID);
>   			}
>   

Since we don't care the return from do_send_sig_info(), would you mind to
prefix it with (void) ?

thanks!
-jane


--------------26820907F7F7D3317A5CD494
Content-Type: text/html; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;
      charset=ISO-2022-JP">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <pre>Hi, Naoya,
</pre>
    <div class="moz-cite-prefix">On 1/16/2019 1:30 AM, Naoya Horiguchi
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp">
      <pre class="moz-quote-pre" wrap="">diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7c72f2a95785..831be5ff5f4d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -372,7 +372,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
 			if (fail || tk-&gt;addr_valid == 0) {
 				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
 				       pfn, tk-&gt;tsk-&gt;comm, tk-&gt;tsk-&gt;pid);
-				force_sig(SIGKILL, tk-&gt;tsk);
+				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
+						 tk-&gt;tsk, PIDTYPE_PID);
 			}
 </pre>
    </blockquote>
    <pre>Since we don't care the return from do_send_sig_info(), would you mind to 
prefix it with (void) ?

thanks!
-jane
</pre>
  </body>
</html>

--------------26820907F7F7D3317A5CD494--
