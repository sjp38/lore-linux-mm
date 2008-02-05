Received: by wx-out-0506.google.com with SMTP id h31so2212555wxd.11
        for <linux-mm@kvack.org>; Mon, 04 Feb 2008 18:59:39 -0800 (PST)
Message-ID: <804dabb00802041859p3e253b71w7978599101639761@mail.gmail.com>
Date: Tue, 5 Feb 2008 10:59:34 +0800
From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: Compilation errors
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "kernelnewbies@nl.linux.org" <kernelnewbies@nl.linux.org>
List-ID: <linux-mm.kvack.org>

I pulled the git from linux-mm today, and compiled with the following errors:

  CC      arch/x86/kernel/apm_32.o
arch/x86/kernel/apm_32.c: In function 'suspend':
arch/x86/kernel/apm_32.c:1192: warning: 'pm_send_all' is deprecated
(declared at include/linux/pm_legacy.h:16)
arch/x86/kernel/apm_32.c:1227: warning: 'pm_send_all' is deprecated
(declared at include/linux/pm_legacy.h:16)
arch/x86/kernel/apm_32.c: In function 'check_events':
arch/x86/kernel/apm_32.c:1340: warning: 'pm_send_all' is deprecated
(declared at include/linux/pm_legacy.h:16)
  LD      arch/x86/kernel/apm.o
  CC      arch/x86/kernel/smp_32.o

And the following errors:

  CC      arch/x86/mm/ioremap.o
arch/x86/mm/ioremap.c: In function '__ioremap':
arch/x86/mm/ioremap.c:106: error: expected expression before '<<' token
arch/x86/mm/ioremap.c:108: error: expected expression before '==' token
arch/x86/mm/ioremap.c:109:9: error: invalid suffix
"d45b22c079946332bf3825afefe5a981a97b6" on integer constant
arch/x86/mm/ioremap.c:128: error: expected expression before '<<' token
arch/x86/mm/ioremap.c:133:9: error: invalid suffix
"d45b22c079946332bf3825afefe5a981a97b6" on integer constant
arch/x86/mm/ioremap.c:140: error: 'prot' undeclared (first use in this function)
arch/x86/mm/ioremap.c:140: error: (Each undeclared identifier is
reported only once
arch/x86/mm/ioremap.c:140: error: for each function it appears in.)
make[1]: *** [arch/x86/mm/ioremap.o] Error 1

And issuing another "git pull" I got: the following message:

You are in the middle of a conflicted merge.


Please enlighten me here...thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
