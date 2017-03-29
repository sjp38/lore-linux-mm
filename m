Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B12A6B03A1
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 05:21:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r129so7094771pgr.18
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:21:09 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id p18si6871714pli.174.2017.03.29.02.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 02:21:08 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 81so1913007pgh.3
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:21:08 -0700 (PDT)
Subject: Re: [PATCH V5 16/17] mm: Let arch choose the initial value of task
 size
References: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Anshuman Khandual <anshuman.linux@gmail.com>
Message-ID: <00df9abd-b023-0d1c-6753-654f682cd754@gmail.com>
Date: Wed, 29 Mar 2017 14:50:51 +0530
MIME-Version: 1.0
In-Reply-To: <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: multipart/alternative;
 boundary="------------D1740DB1BDDFFECE9575679A"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

This is a multi-part message in MIME format.
--------------D1740DB1BDDFFECE9575679A
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit



On Wednesday 22 March 2017 09:07 AM, Aneesh Kumar K.V wrote:
> As we start supporting larger address space (>128TB), we want to give
> architecture a control on max task size of an application which is different
> from the TASK_SIZE. For ex: ppc64 needs to track the base page size of a segment
> and it is copied from mm_context_t to PACA on each context switch. If we know that
> application has not used an address range above 128TB we only need to copy
> details about 128TB range to PACA. This will help in improving context switch
> performance by avoiding larger copy operation.
>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>   fs/exec.c | 10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/fs/exec.c b/fs/exec.c
> index 65145a3df065..5550a56d03c3 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1308,6 +1308,14 @@ void would_dump(struct linux_binprm *bprm, struct file *file)
>   }
>   EXPORT_SYMBOL(would_dump);
>   
> +#ifndef arch_init_task_size
> +static inline void arch_init_task_size(void)
> +{
> +	current->mm->task_size = TASK_SIZE;
> +}
> +#define arch_init_task_size arch_init_task_size
> +#endif

Why not a proper CONFIG_ARCH_DEFINED_TASK_SIZE kind of option for this ? 
Also
are there no assumptions about task current->mm->size being TASK_SIZE in 
other
places which might get broken ?

--------------D1740DB1BDDFFECE9575679A
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On Wednesday 22 March 2017 09:07 AM,
      Aneesh Kumar K.V wrote:<br>
    </div>
    <blockquote
cite="mid:1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com"
      type="cite">
      <pre wrap="">As we start supporting larger address space (&gt;128TB), we want to give
architecture a control on max task size of an application which is different
from the TASK_SIZE. For ex: ppc64 needs to track the base page size of a segment
and it is copied from mm_context_t to PACA on each context switch. If we know that
application has not used an address range above 128TB we only need to copy
details about 128TB range to PACA. This will help in improving context switch
performance by avoiding larger copy operation.

Cc: Kirill A. Shutemov <a class="moz-txt-link-rfc2396E" href="mailto:kirill.shutemov@linux.intel.com">&lt;kirill.shutemov@linux.intel.com&gt;</a>
Cc: <a class="moz-txt-link-abbreviated" href="mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>
Cc: Andrew Morton <a class="moz-txt-link-rfc2396E" href="mailto:akpm@linux-foundation.org">&lt;akpm@linux-foundation.org&gt;</a>
Signed-off-by: Aneesh Kumar K.V <a class="moz-txt-link-rfc2396E" href="mailto:aneesh.kumar@linux.vnet.ibm.com">&lt;aneesh.kumar@linux.vnet.ibm.com&gt;</a>
---
 fs/exec.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index 65145a3df065..5550a56d03c3 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1308,6 +1308,14 @@ void would_dump(struct linux_binprm *bprm, struct file *file)
 }
 EXPORT_SYMBOL(would_dump);
 
+#ifndef arch_init_task_size
+static inline void arch_init_task_size(void)
+{
+	current-&gt;mm-&gt;task_size = TASK_SIZE;
+}
+#define arch_init_task_size arch_init_task_size
+#endif</pre>
    </blockquote>
    <br>
    <font size="-1">Why not a proper CONFIG_ARCH_DEFINED_TASK_SIZE kind
      of option for this ? Also<br>
      are there no assumptions about task current-&gt;mm-&gt;size being
      TASK_SIZE in other<br>
      places which might get broken ?<br>
    </font><font size="-1"></font>
  </body>
</html>

--------------D1740DB1BDDFFECE9575679A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
